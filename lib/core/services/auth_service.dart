import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

/// Firebase Authentication wrapper synced with [AppDataController].
class AuthService extends GetxService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AuthService> init() async {
    return this;
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
    }

    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() => _auth.signOut();

  /// Mirrors the Firebase user into local session storage.
  Future<void> syncSession(AppDataController data, {User? user}) async {
    final firebaseUser = user ?? _auth.currentUser;
    if (firebaseUser == null) {
      await data.clearAuthSession();
      return;
    }

    await data.syncAuthUser(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? data.userName.value,
      email: firebaseUser.email ?? data.userEmail.value,
    );
  }
}
