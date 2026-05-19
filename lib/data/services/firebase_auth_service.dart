import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Wraps [FirebaseAuth] with the methods the community sharing feature needs.
///
/// Anonymous sign-in happens at app init — invisible to the user. When a user
/// wants to upload content, they link an email/password credential to their
/// existing anonymous account (preserving UID and downloaded content).
class FirebaseAuthService {
  FirebaseAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// The currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Whether the current user has a verified email linked.
  bool get isEmailVerified => _auth.currentUser?.emailVerified == true;

  /// Whether the current user is signed in (anonymous or otherwise).
  bool get isSignedIn => _auth.currentUser != null;

  /// Whether the current user is anonymous (no email linked).
  bool get isAnonymous => _auth.currentUser?.isAnonymous == true;

  /// Whether the current user has an email/password provider linked.
  bool get hasEmailProvider =>
      _auth.currentUser?.providerData.any(
        (info) => info.providerId == 'password',
      ) ??
      false;

  /// Stream of auth state changes for reactive providers.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Signs in anonymously. Safe to call multiple times — if the user is
  /// already signed in, this is a no-op.
  Future<User?> ensureSignedIn() async {
    if (_auth.currentUser != null) return _auth.currentUser;
    try {
      final credential = await _auth.signInAnonymously();
      debugPrint('Firebase Auth: anonymous sign-in uid=${credential.user?.uid}');
      return credential.user;
    } catch (e, stack) {
      debugPrint('Firebase Auth: anonymous sign-in failed: $e');
      Sentry.captureException(e, stackTrace: stack);
      return null;
    }
  }

  /// Links an email/password credential to the current anonymous account.
  ///
  /// After linking, the user keeps their UID but is no longer anonymous.
  /// A verification email is sent automatically.
  ///
  /// Returns null on success, or an error message string on failure.
  Future<String?> linkWithEmail(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) return 'Not signed in';

    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.linkWithCredential(credential);
      await user.sendEmailVerification();
      debugPrint('Firebase Auth: linked email $email, verification sent');
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth: link failed: ${e.code} ${e.message}');
      switch (e.code) {
        case 'provider-already-linked':
          // Email provider already linked — not an error. Resend verification
          // if the email isn't verified yet, then let the caller proceed to
          // the verification view.
          if (!isEmailVerified) {
            try {
              await user.sendEmailVerification();
            } catch (_) {
              // Ignore send failures — user can still tap "resend" later.
            }
          }
          return null;
        case 'email-already-in-use':
          return 'That email is already registered. Try signing in instead.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'credential-already-in-use':
          return 'This credential is already associated with another account.';
        default:
          return e.message ?? 'An unknown error occurred.';
      }
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      return 'An unexpected error occurred.';
    }
  }

  /// Signs in with email/password (for users who already linked an email
  /// on a different device or after reinstall).
  Future<String?> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found with that email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This account has been disabled.';
        default:
          return e.message ?? 'An unknown error occurred.';
      }
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      return 'An unexpected error occurred.';
    }
  }

  /// Resends the email verification to the current user.
  Future<String?> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      return null;
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);
      return 'Failed to send verification email.';
    }
  }

  /// Reloads the current user to pick up changes (e.g., email verified).
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  /// Forces a refresh of the Firebase ID token.
  ///
  /// Call this after `reloadUser()` detects that `isEmailVerified` changed.
  /// The ID token contains the `email_verified` claim that Firestore security
  /// rules check — `reload()` alone only updates the local [User] object, not
  /// the token. Without this, Firestore may reject writes for up to 60 minutes
  /// after verification.
  Future<void> forceTokenRefresh() async {
    await _auth.currentUser?.getIdToken(true);
  }

  /// Signs out completely.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
