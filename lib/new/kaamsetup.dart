import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:service_hub/firebase_options.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/auth_Service.dart';
import 'package:service_hub/new/complete_profile_creen.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/link_sent_screen.dart';
import 'package:service_hub/new/new_splash_screen.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/provider_dashbord.dart';
import 'package:service_hub/new/select_Service_Screen.dart';
import 'package:service_hub/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const KaamSetuApp());
}

class KaamSetuApp extends StatelessWidget {
  const KaamSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KaamSetu',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}

// =========================================================
// AUTH GATE
// =========================================================

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  int _refreshKey = 0;

  void _retry() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    /*
     * userChanges استعمال کیا ہے تاکہ email verification
     * reload ہونے پر AuthGate دوبارہ build ہوسکے۔
     */
    return StreamBuilder<User?>(
      stream: AuthService.instance.userChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingScreen(
            message: 'Checking your account...',
          );
        }

        if (authSnapshot.hasError) {
          return AuthProblemScreen(
            title: 'Authentication Error',
            message: authSnapshot.error.toString(),
            onRetry: _retry,
          );
        }

        final firebaseUser = authSnapshot.data;

        /*
         * User Firebase میں login نہیں ہے۔
         */
        if (firebaseUser == null) {
          return const SplashScreen();
        }

        /*
         * users/{uid} document load کریں۔
         */
        return FutureBuilder<AppUser?>(
          key: ValueKey(
            '${firebaseUser.uid}-$_refreshKey',
          ),
          future: FirestoreService.instance.getUser(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingScreen(
                message: 'Loading your profile...',
              );
            }

            if (userSnapshot.hasError) {
              return AuthProblemScreen(
                title: 'Could Not Load Profile',
                message: userSnapshot.error.toString(),
                onRetry: _retry,
              );
            }

            final appUser = userSnapshot.data;

            /*
             * Firebase Authentication account موجود ہے،
             * مگر users/{uid} document موجود نہیں۔
             */
            if (appUser == null) {
              return MissingAccountProfileScreen(
                firebaseUser: firebaseUser,
              );
            }

            /*
             * Gmail verification مکمل نہیں ہوئی۔
             */
            if (!firebaseUser.emailVerified) {
              return LinkSentScreen(
                email: firebaseUser.email ?? '',
                role: appUser.role,
              );
            }

            final role = appUser.role.trim().toLowerCase();

            /*
             * Provider flow۔
             */
            if (role == 'provider') {
              if (!appUser.profileCompleted) {
                return CompleteProfileScreen(
                  firebaseUser: firebaseUser,
                  role: 'provider',
                );
              }

              return const ProviderDashboardScreen(
                providerId: '',
              );
            }

            /*
             * Normal user flow۔
             */
            if (role == 'user') {
              return const SelectServiceScreen();
            }

            return AuthProblemScreen(
              title: 'Invalid Account Role',
              message: 'The role "$role" is not supported. '
                  'Role must be user or provider.',
              onRetry: _retry,
            );
          },
        );
      },
    );
  }
}

// =========================================================
// AUTH ERROR SCREEN
// =========================================================

class AuthProblemScreen extends StatefulWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const AuthProblemScreen({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  State<AuthProblemScreen> createState() => _AuthProblemScreenState();
}

class _AuthProblemScreenState extends State<AuthProblemScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;

    setState(() {
      _loggingOut = true;
    });

    try {
      await AuthService.instance.signOut();
    } finally {
      if (mounted) {
        setState(() {
          _loggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: AppColors.danger,
                    size: 43,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 26),
                PrimaryButton(
                  label: 'Try Again',
                  icon: Icons.refresh,
                  onPressed: widget.onRetry,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Logout',
                  icon: Icons.logout,
                  onPressed: _logout,
                  loading: _loggingOut,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================
// MISSING FIRESTORE ACCOUNT
// =========================================================

class MissingAccountProfileScreen extends StatefulWidget {
  final User firebaseUser;

  const MissingAccountProfileScreen({
    super.key,
    required this.firebaseUser,
  });

  @override
  State<MissingAccountProfileScreen> createState() =>
      _MissingAccountProfileScreenState();
}

class _MissingAccountProfileScreenState
    extends State<MissingAccountProfileScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _logout() async {
    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.instance.signOut();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not logout. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_off_outlined,
                    color: AppColors.danger,
                    size: 43,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Account Profile Not Found',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A Firebase account exists for:\n'
                  '${widget.firebaseUser.email ?? ''}\n\n'
                  'However, its Firestore user document '
                  'could not be found. Logout and register '
                  'again using the updated signup screen.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  ErrorMessageBox(
                    message: _error!,
                  ),
                ],
                SizedBox(height: 26),
                PrimaryButton(
                  label: 'Logout and Register Again',
                  icon: Icons.logout,
                  onPressed: _logout,
                  loading: _loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
