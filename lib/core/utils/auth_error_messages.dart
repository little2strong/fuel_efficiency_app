import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'user-disabled' => 'This account has been disabled.',
      'user-not-found' => 'No account found for that email.',
      'wrong-password' => 'Incorrect password. Try again.',
      'email-already-in-use' => 'An account already exists for this email.',
      'weak-password' => 'Password must be at least 6 characters.',
      'too-many-requests' => 'Too many attempts. Please wait and try again.',
      'network-request-failed' => 'Network error. Check your connection.',
      'invalid-credential' => 'Invalid email or password.',
      _ => error.message ?? 'Authentication failed. Please try again.',
    };
  }
  return 'Something went wrong. Please try again.';
}
