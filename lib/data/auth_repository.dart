import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Firebase Auth so the rest of the app only ever
/// talks to this class, not the Firebase SDK directly.
///
/// Registering removes ads (see AdBannerPlaceholder / welcome_screen).
/// Once signed in, Firebase Auth caches the session on-device, so the
/// ad-free state keeps working with no internet after the first login.
class AuthRepository extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;

  /// [firebaseAuth] is injectable so tests can pass a fake instead of
  /// touching the real Firebase SDK (which needs Firebase.initializeApp()).
  AuthRepository({FirebaseAuth? firebaseAuth}) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    _firebaseAuth.authStateChanges().listen((_) => notifyListeners());
  }

  bool get isSignedIn => _firebaseAuth.currentUser != null;
  String? get email => _firebaseAuth.currentUser?.email;

  Future<String?> signUp(String email, String password) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not create an account.';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not sign in.';
    }
  }

  Future<String?> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not send reset email.';
    }
  }

  Future<void> signOut() => _firebaseAuth.signOut();
}
