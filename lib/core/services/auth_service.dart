import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import 'package:fuel_efficiency_app/features/shared/app_data_controller.dart';

/// Firebase Authentication wrapper synced with [AppDataController].
class AuthService extends GetxService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  bool _initialized = false;

  Future<AuthService> init() async {
    await ensureInitialized();
    return this;
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    await _auth.authStateChanges().first;
    _initialized = true;
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

    // Best-effort: send a verification email. Never block sign-up if it fails
    // (e.g. transient network error) — the account is still created.
    try {
      final user = credential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (_) {}

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

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    await user.updateDisplayName(trimmed);
    await user.reload();
  }

  /// Mirrors the Firebase user into local session storage, then syncs cloud data.
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
    await data.syncFromCloud();
  }
}
