import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/skins/skins.dart';
import '../../../domain/providers/auth_providers.dart';

/// Ensures the user has a verified email before uploading.
///
/// First reloads the Firebase user to pick up any verification that happened
/// outside the app. If already verified, returns `true` immediately without
/// showing any UI.
///
/// Otherwise shows a bottom sheet to link an email (if anonymous) or to
/// check verification status (if linked but unverified).
///
/// Returns `true` when verified, `false` / null if cancelled.
Future<bool?> showEmailLinkPrompt(BuildContext context) async {
  // Reload user to pick up verification that happened outside the app.
  // authStateChanges doesn't fire on email verification alone.
  final container = ProviderScope.containerOf(context);
  final authService = container.read(firebaseAuthServiceProvider);
  await authService.reloadUser();

  // After reload, if already verified, short-circuit — no sheet needed.
  // Force an ID token refresh so Firestore security rules see the updated
  // email_verified claim. reload() only updates the local User object; the
  // cached token can lag behind by up to 60 minutes.
  if (authService.isEmailVerified) {
    await authService.forceTokenRefresh();
    container.invalidate(authStateProvider);
    return true;
  }

  if (!context.mounted) return false;

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _EmailLinkSheet(),
  );
}

class _EmailLinkSheet extends ConsumerStatefulWidget {
  const _EmailLinkSheet();

  @override
  ConsumerState<_EmailLinkSheet> createState() => _EmailLinkSheetState();
}

class _EmailLinkSheetState extends ConsumerState<_EmailLinkSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _error;

  /// True if the user already linked an email but hasn't verified yet.
  bool _awaitingVerification = false;

  /// True when the user should sign in with an existing account rather than
  /// linking a new email to their anonymous account. Activates automatically
  /// when [linkWithEmail] returns `email-already-in-use`, or manually via
  /// the "Sign in instead" toggle.
  bool _isSignInMode = false;

  @override
  void initState() {
    super.initState();
    final authService = ref.read(firebaseAuthServiceProvider);
    // If the user already has an email provider linked (regardless of
    // isAnonymous flag), skip the link form and go to verification view.
    if (authService.hasEmailProvider) {
      _awaitingVerification = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _linkEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authService = ref.read(firebaseAuthServiceProvider);
    final result = await authService.linkWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (result != null) {
      // If the email is already in use, switch to sign-in mode so the user
      // can authenticate with the existing account.
      if (result.contains('already registered')) {
        setState(() {
          _isLoading = false;
          _isSignInMode = true;
          _error = null;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = result;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _awaitingVerification = true;
      });
    }
  }

  /// Signs in with an existing email/password account. Replaces the current
  /// anonymous user — local data (Drift DB, SharedPreferences) is unaffected
  /// because it's not keyed by Firebase UID.
  Future<void> _signInEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authService = ref.read(firebaseAuthServiceProvider);
    final result = await authService.signInWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _isLoading = false;
        _error = result;
      });
      return;
    }

    // Sign-in succeeded. Reload to get current verification status.
    await authService.reloadUser();
    if (!mounted) return;

    if (authService.isEmailVerified) {
      await authService.forceTokenRefresh();
      ref.invalidate(authStateProvider);
      if (mounted) Navigator.of(context).pop(true);
    } else {
      // Signed in but not yet verified — show verification view.
      setState(() {
        _isLoading = false;
        _awaitingVerification = true;
      });
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);

    final authService = ref.read(firebaseAuthServiceProvider);
    await authService.reloadUser();

    if (!mounted) return;

    if (authService.isEmailVerified) {
      // Force ID token refresh so Firestore rules see email_verified: true.
      await authService.forceTokenRefresh();
      // Refresh auth state in providers.
      ref.invalidate(authStateProvider);
      if (mounted) Navigator.of(context).pop(true);
      return;
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Email not yet verified. Check your inbox and spam folder.';
      });
    }
  }

  Future<void> _resendEmail() async {
    final authService = ref.read(firebaseAuthServiceProvider);
    final result = await authService.resendVerificationEmail();
    if (!mounted) return;

    if (result != null) {
      setState(() => _error = result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email sent')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: _awaitingVerification
          ? _buildVerificationView(colorScheme)
          : _buildLinkForm(colorScheme),
    );
  }

  Widget _buildLinkForm(ColorScheme colorScheme) {
    final onSubmit = _isSignInMode ? _signInEmail : _linkEmail;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Icon(
            _isSignInMode ? Icons.login : Icons.verified_user_outlined,
            size: 48,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),

          Text(
            _isSignInMode ? 'Sign In' : 'Verify to Upload',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isSignInMode
                ? 'Sign in with the email and password you used on '
                    'your other device.'
                : 'Link an email to your account to share content with the '
                    'community. Your anonymous data is preserved.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outlined),
            ),
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 8),

          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: context.errorColor, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 8),
          FilledButton(
            onPressed: _isLoading ? null : onSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_isSignInMode
                    ? 'SIGN IN'
                    : 'LINK EMAIL & VERIFY'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _isSignInMode = !_isSignInMode;
                _error = null;
              });
            },
            child: Text(_isSignInMode
                ? 'CREATE NEW ACCOUNT'
                : 'SIGN IN WITH EXISTING ACCOUNT'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationView(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Handle
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Icon(Icons.mark_email_unread_outlined, size: 48, color: colorScheme.primary),
        const SizedBox(height: 16),

        Text(
          'Check Your Inbox',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a verification email. Open the link in the email, then '
          'come back here and tap the button below.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        if (_error != null) ...[
          Text(
            _error!,
            style: TextStyle(color: context.errorColor, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
        ],

        FilledButton(
          onPressed: _isLoading ? null : _checkVerification,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text("I'VE VERIFIED MY EMAIL"),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _resendEmail,
          child: const Text('RESEND VERIFICATION EMAIL'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('CANCEL'),
        ),
      ],
    );
  }
}
