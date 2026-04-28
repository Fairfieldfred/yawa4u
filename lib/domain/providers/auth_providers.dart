import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/firebase_auth_service.dart';

/// Singleton instance of [FirebaseAuthService].
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

/// Reactive stream of Firebase Auth state changes.
///
/// Emits a [User] when signed in (anonymous or email), null when signed out.
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return authService.authStateChanges;
});

/// The current Firebase user, derived from [authStateProvider].
///
/// Returns null if not yet signed in or if the auth stream hasn't emitted.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

/// Whether the current user has a verified email linked.
///
/// Returns false if anonymous or not signed in.
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified == true;
});

/// Whether the current user can upload content (email verified).
final canUploadProvider = Provider<bool>((ref) {
  return ref.watch(isEmailVerifiedProvider);
});
