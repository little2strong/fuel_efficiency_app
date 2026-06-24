import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/features/fuel/fuel_entry_model.dart';
import 'package:fuel_efficiency_app/features/vehicle/vehicle_model.dart';

/// Remote user profile and settings stored at `users/{uid}`.
class UserCloudProfile {
  const UserCloudProfile({
    this.displayName = '',
    this.email = '',
    this.onboardingComplete = false,
    this.settings = const {},
  });

  final String displayName;
  final String email;
  final bool onboardingComplete;
  final Map<String, dynamic> settings;

  bool get isEmpty =>
      displayName.isEmpty &&
      email.isEmpty &&
      !onboardingComplete &&
      settings.isEmpty;
}

/// Snapshot of a user's Firestore data.
class UserCloudData {
  const UserCloudData({
    this.profile,
    this.vehicles = const [],
    this.entries = const [],
  });

  final UserCloudProfile? profile;
  final List<VehicleModel> vehicles;
  final List<FuelEntryModel> entries;

  bool get hasRemoteData =>
      profile != null || vehicles.isNotEmpty || entries.isNotEmpty;
}

/// Cloud persistence for per-user vehicles, entries, and settings.
class FirestoreService extends GetxService {
  FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _vehiclesRef(String uid) =>
      _userRef(uid).collection('vehicles');

  CollectionReference<Map<String, dynamic>> _entriesRef(String uid) =>
      _userRef(uid).collection('entries');

  Future<FirestoreService> init() async => this;

  Future<UserCloudData> fetchUserData(String uid) async {
    final results = await Future.wait([
      _userRef(uid).get(),
      _vehiclesRef(uid).get(),
      _entriesRef(uid).get(),
    ]);
    final userSnap = results[0] as DocumentSnapshot<Map<String, dynamic>>;
    final vehiclesSnap = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final entriesSnap = results[2] as QuerySnapshot<Map<String, dynamic>>;

    UserCloudProfile? profile;
    if (userSnap.exists) {
      profile = _profileFromFirestore(userSnap.data() ?? {});
    }

    final vehicles = vehiclesSnap.docs
        .map((doc) => VehicleModel.fromJson(doc.data()))
        .toList();

    final entries = entriesSnap.docs
        .map((doc) => _entryFromFirestore(doc.data()))
        .toList();

    return UserCloudData(
      profile: profile,
      vehicles: vehicles,
      entries: entries,
    );
  }

  Future<void> saveUserProfile({
    required String uid,
    required String displayName,
    required String email,
    required bool onboardingComplete,
    required Map<String, dynamic> settings,
  }) {
    return _userRef(uid).set({
      'displayName': displayName,
      'email': email,
      'onboardingComplete': onboardingComplete,
      'settings': settings,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveVehicle(String uid, VehicleModel vehicle) {
    return _vehiclesRef(uid).doc(vehicle.id).set(vehicle.toJson());
  }

  Future<void> deleteVehicle(String uid, String vehicleId) async {
    final batch = _db.batch();
    batch.delete(_vehiclesRef(uid).doc(vehicleId));

    // Query only this vehicle's entries instead of scanning the collection.
    final relatedEntries = await _entriesRef(
      uid,
    ).where('vehicleId', isEqualTo: vehicleId).get();
    for (final doc in relatedEntries.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  Future<void> saveEntry(String uid, FuelEntryModel entry) {
    return _entriesRef(uid).doc(entry.id).set(_entryToFirestore(entry));
  }

  Future<void> deleteEntry(String uid, String entryId) {
    return _entriesRef(uid).doc(entryId).delete();
  }

  Future<void> pushAllData({
    required String uid,
    required String displayName,
    required String email,
    required bool onboardingComplete,
    required Map<String, dynamic> settings,
    required List<VehicleModel> vehicles,
    required List<FuelEntryModel> entries,
  }) async {
    await saveUserProfile(
      uid: uid,
      displayName: displayName,
      email: email,
      onboardingComplete: onboardingComplete,
      settings: settings,
    );

    await _writeInBatches([
      for (final vehicle in vehicles)
        _vehiclesRef(uid).doc(vehicle.id).set(vehicle.toJson()),
      for (final entry in entries)
        _entriesRef(uid).doc(entry.id).set(_entryToFirestore(entry)),
    ]);
  }

  Future<void> deleteAllUserData(String uid) async {
    final vehicles = await _vehiclesRef(uid).get();
    final entries = await _entriesRef(uid).get();

    await _writeInBatches([
      for (final doc in vehicles.docs) doc.reference.delete(),
      for (final doc in entries.docs) doc.reference.delete(),
    ]);

    await _userRef(uid).delete();
  }

  Future<void> _writeInBatches(List<Future<void>> operations) async {
    const chunkSize = 450;
    for (var i = 0; i < operations.length; i += chunkSize) {
      final end = (i + chunkSize < operations.length)
          ? i + chunkSize
          : operations.length;
      await Future.wait(operations.sublist(i, end));
    }
  }

  UserCloudProfile _profileFromFirestore(Map<String, dynamic> data) {
    final settings = data['settings'];
    return UserCloudProfile(
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      settings: settings is Map
          ? Map<String, dynamic>.from(settings)
          : const {},
    );
  }

  Map<String, dynamic> _entryToFirestore(FuelEntryModel entry) {
    final json = entry.toJson();
    json['date'] = Timestamp.fromDate(entry.date);
    return json;
  }

  FuelEntryModel _entryFromFirestore(Map<String, dynamic> data) {
    final map = Map<String, dynamic>.from(data);
    final date = map['date'];
    if (date is Timestamp) {
      map['date'] = date.toDate().toIso8601String();
    }
    return FuelEntryModel.fromJson(map);
  }
}
