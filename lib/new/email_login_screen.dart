import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_hub/new/auth_Service.dart';
import 'package:service_hub/new/complete_profile_creen.dart';
import 'package:service_hub/new/email_register_screen.dart';
import 'package:service_hub/new/link_sent_screen.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/provider_dashbord.dart';
import 'package:service_hub/new/select_Service_Screen.dart';

import '../services/old_auth.dart' hide AuthService;
import '../../theme/app_theme.dart';
import '../../user/select_service.dart';
import '../../widgets/common_widgets.dart' hide PrimaryButton;

class EmailLoginScreen extends StatefulWidget {
  final String role;

  const EmailLoginScreen({
    super.key,
    required this.role,
  });

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  String get selectedRole => widget.role.trim().toLowerCase();

  String get roleTitle => selectedRole == 'provider' ? 'Provider' : 'User';

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    ).hasMatch(email);
  }

  Future<void> _login() async {
    if (_loading) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim().toLowerCase();

    /*
     * Password کو trim نہ کریں۔
     */
    final password = _passwordController.text;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.instance.loginWithEmailPassword(
        email: email,
        password: password,
      );

      final currentUser = AuthService.instance.currentUser;

      if (currentUser == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'Login session could not be created.',
        );
      }

      /*
       * Unverified user verification screen پر جائے گا۔
       */
      if (!currentUser.emailVerified) {
        if (!mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => LinkSentScreen(
              email: currentUser.email ?? email,
              role: selectedRole,
            ),
          ),
          (route) => false,
        );

        return;
      }

      /*
       * اصل role Firestore سے آئے گا۔
       */
      final savedRole = await AuthService.instance.getCurrentUserRole();

      if (!mounted) return;

      if (savedRole == null) {
        await AuthService.instance.signOut();

        if (!mounted) return;

        setState(() {
          _error =
              'Account exists, but its Firestore profile was not found. Please register again.';
        });

        return;
      }

      if (savedRole == 'user') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const SelectServiceScreen(),
          ),
          (route) => false,
        );

        return;
      }

      if (savedRole == 'provider') {
        final profileCompleted =
            await AuthService.instance.isCurrentUserProfileCompleted();

        if (!mounted) return;

        if (!profileCompleted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => CompleteProfileScreen(
                firebaseUser: currentUser,
                role: 'provider',
              ),
            ),
            (route) => false,
          );

          return;
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const ProviderDashboardScreen(
              providerId: '',
            ),
          ),
          (route) => false,
        );

        return;
      }

      await AuthService.instance.signOut();

      if (!mounted) return;

      setState(() {
        _error = 'Invalid account role: $savedRole';
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _error = _firebaseErrorMessage(error);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not login. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (_loading) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() {
        _error = 'Enter your email before pressing Forgot Password.';
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _error = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.instance.sendPasswordResetEmail(email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email sent to $email. Check Inbox and Spam.',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _error = _firebaseErrorMessage(error);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not send password reset email.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _openRegistration() {
    if (_loading) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmailRegisterScreen(
          role: selectedRole,
        ),
      ),
    );
  }

  String _firebaseErrorMessage(
    FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'operation-not-allowed':
        return 'Email/Password login is not enabled in Firebase Console.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'too-many-requests':
        return 'Too many login attempts. Please wait and try again.';

      case 'empty-password':
        return 'Please enter your password.';

      case 'no-current-user':
        return 'Your login session has expired. Please login again.';

      default:
        return error.message ?? 'Could not complete login.';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: AutofillGroup(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: AppColors.darkBg,
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to your $roleTitle account.',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          selectedRole == 'provider'
                              ? Icons.handyman_outlined
                              : Icons.person_outline,
                          color: AppColors.primaryYellow,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          '$roleTitle Login',
                          style: const TextStyle(
                            color: AppColors.darkBg,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_loading,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [
                      AutofillHints.email,
                    ],
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'example@gmail.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (email.isEmpty) {
                        return 'Please enter your email';
                      }

                      if (!_isValidEmail(email)) {
                        return 'Please enter a valid email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_loading,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [
                      AutofillHints.password,
                    ],
                    autocorrect: false,
                    enableSuggestions: false,
                    onFieldSubmitted: (_) {
                      _login();
                    },
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: IconButton(
                        onPressed: _loading
                            ? null
                            : () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      final password = value ?? '';

                      if (password.isEmpty) {
                        return 'Please enter your password';
                      }

                      if (password.length < 6) {
                        return 'Password must contain at least 6 characters';
                      }

                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading ? null : _forgotPassword,
                      child: const Text(
                        'Forgot Password?',
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    ErrorMessageBox(
                      message: _error!,
                    ),
                    const SizedBox(height: 18),
                  ] else
                    const SizedBox(height: 8),
                  PrimaryButton(
                    label: 'Login',
                    icon: Icons.login,
                    onPressed: _login,
                    loading: _loading,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: _loading ? null : _openRegistration,
                      child: const Text(
                        "Don't have an account? Create Account",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
