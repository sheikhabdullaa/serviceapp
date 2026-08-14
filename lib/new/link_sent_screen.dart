import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_hub/new/auth_Service.dart';
import 'package:service_hub/new/complete_profile_creen.dart';
import 'package:service_hub/new/new_role_Selection.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/provider_dashbord.dart';
import 'package:service_hub/new/select_Service_Screen.dart';
import '../../theme/app_theme.dart';

class LinkSentScreen extends StatefulWidget {
  final String email;
  final String role;

  const LinkSentScreen({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  State<LinkSentScreen> createState() => _LinkSentScreenState();
}

class _LinkSentScreenState extends State<LinkSentScreen>
    with WidgetsBindingObserver {
  bool _checking = false;
  bool _resending = false;
  bool _success = false;
  String? _message;

  bool get _busy => _checking || _resending;

  String get roleTitle =>
      widget.role.trim().toLowerCase() == 'provider' ? 'Provider' : 'User';

  @override
  void initState() {
    super.initState();

    /*
     * Gmail/browser سے app میں واپس آنے پر
     * verification automatically check ہوگی۔
     */
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && !_busy) {
      _checkVerification(
        showUnverifiedMessage: false,
      );
    }
  }

  Future<void> _checkVerification({
    bool showUnverifiedMessage = true,
  }) async {
    if (_busy) return;

    setState(() {
      _checking = true;
      _success = false;
      _message = null;
    });

    try {
      final verified = await AuthService.instance.checkEmailVerification();

      if (!mounted) return;

      if (!verified) {
        if (showUnverifiedMessage) {
          setState(() {
            _message =
                'Email is not verified yet. Open Gmail and tap the verification link.';
          });
        }

        return;
      }

      final savedRole = await AuthService.instance.getCurrentUserRole();

      if (!mounted) return;

      if (savedRole == null) {
        setState(() {
          _message =
              'Email is verified, but the Firestore account profile was not found.';
        });
        return;
      }

      final currentUser = AuthService.instance.currentUser;

      if (currentUser == null) {
        setState(() {
          _message = 'Your session has expired. Please login again.';
        });
        return;
      }

      setState(() {
        _success = true;
        _message = 'Email verified successfully.';
      });

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

      setState(() {
        _success = false;
        _message = 'Invalid account role: $savedRole';
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _message = _firebaseErrorMessage(error);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _message = 'Could not check email verification. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _checking = false;
        });
      }
    }
  }

  Future<void> _resendEmail() async {
    if (_busy) return;

    setState(() {
      _resending = true;
      _success = false;
      _message = null;
    });

    try {
      await AuthService.instance.resendVerificationEmail();

      if (!mounted) return;

      setState(() {
        _success = true;
        _message =
            'A new verification email has been sent. Check Inbox, Spam and Promotions.';
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _message = _firebaseErrorMessage(error);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _message = 'Could not resend the verification email.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _resending = false;
        });
      }
    }
  }

  Future<void> _useAnotherAccount() async {
    if (_busy) return;

    setState(() {
      _checking = true;
      _message = null;
    });

    try {
      await AuthService.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const RoleSelectScreen(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _checking = false;
        _message = 'Could not logout. Please try again.';
      });
    }
  }

  String _firebaseErrorMessage(
    FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'no-current-user':
        return 'Your session has expired. Please login again.';

      case 'email-already-verified':
        return 'Your email is already verified. Press the verification button to continue.';

      case 'too-many-requests':
        return 'Too many requests. Wait a few minutes before trying again.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      case 'user-disabled':
        return 'This account has been disabled.';

      default:
        return error.message ?? 'Could not complete this operation.';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Verify Email'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(27),
          child: Column(
            children: [
              const SizedBox(height: 35),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.20),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  color: AppColors.white,
                  size: 46,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Check Your Gmail',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.darkBg,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$roleTitle account verification',
                style: const TextStyle(
                  color: AppColors.primaryYellow,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'We sent an email verification link to:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkBg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Open Gmail and tap the verification link. '
                'Then return to KaamSetu and press the button below.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 20),
              const InfoMessageBox(
                message:
                    'If you cannot find the email, check your Spam and Promotions folders.',
              ),
              if (_message != null) ...[
                const SizedBox(height: 17),
                if (_success)
                  SuccessMessageBox(
                    message: _message!,
                  )
                else
                  ErrorMessageBox(
                    message: _message!,
                  ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'I Have Verified My Email',
                icon: Icons.verified_outlined,
                onPressed: () {
                  _checkVerification();
                },
                loading: _checking,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Resend Verification Email',
                icon: Icons.refresh,
                onPressed: _resendEmail,
                loading: _resending,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _busy ? null : _useAnotherAccount,
                child: const Text(
                  'Use Another Account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
