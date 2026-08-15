import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:service_hub/firebase_options.dart';
import 'package:service_hub/new/auth_Service.dart';
import 'package:service_hub/new/complete_profile_creen.dart';
import 'package:service_hub/new/link_sent_screen.dart';
import 'package:service_hub/new/new_splash_screen.dart';
import 'package:service_hub/new/provider_dashbord.dart';
import 'package:service_hub/new/select_Service_Screen.dart';
import 'package:service_hub/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const servicehub());
}

class servicehub extends StatelessWidget {
  const servicehub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'servicehub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  int _refreshKey = 0;

  /// Firestore سے current user کی routing information load کرتا ہے۔
  Future<UserRouteData?> _loadUserRouteData(String uid) async {
    final document =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    final data = document.data()!;

    final role = (data['role'] as String? ?? '').trim().toLowerCase();

    final profileCompleted = data['profileCompleted'] as bool? ?? false;

    if (role != 'user' && role != 'provider') {
      throw Exception('Invalid role "$role" found in Firestore.');
    }

    return UserRouteData(role: role, profileCompleted: profileCompleted);
  }

  void _retry() {
    setState(() {
      _refreshKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingScreen();
        }

        if (authSnapshot.hasError) {
          return AuthErrorScreen(
            message: 'Authentication error:\n${authSnapshot.error}',
            onRetry: _retry,
          );
        }

        final firebaseUser = authSnapshot.data;

        if (firebaseUser == null) {
          return const SplashScreen();
        }

        return FutureBuilder<UserRouteData?>(
          key: ValueKey('${firebaseUser.uid}-$_refreshKey'),
          future: _loadUserRouteData(firebaseUser.uid),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingScreen();
            }

            if (profileSnapshot.hasError) {
              return AuthErrorScreen(
                message: 'Could not load your profile:\n'
                    '${profileSnapshot.error}',
                onRetry: _retry,
              );
            }

            final routeData = profileSnapshot.data;

            /*
             * Firebase Authentication account موجود ہے،
             * لیکن users/{uid} Firestore document نہیں ہے۔
             */
            if (routeData == null) {
              return MissingUserDocumentScreen(firebaseUser: firebaseUser);
            }

            /*
             * Account بنا ہوا ہے مگر Gmail link سے
             * email verify نہیں ہوئی۔
             */
            if (!firebaseUser.emailVerified) {
              return LinkSentScreen(
                email: firebaseUser.email ?? '',
                role: routeData.role,
              );
            }

            /*
             * Provider flow:
             *
             * Provider profile complete نہیں ہے تو
             * CompleteProfileScreen کھلے گی۔
             */
            if (routeData.role == 'provider') {
              if (!routeData.profileCompleted) {
                return CompleteProfileScreen(
                  firebaseUser: firebaseUser,
                  role: 'provider',
                );
              }

              return const ProviderDashboardScreen(providerId: '');
            }

            /*
             * Normal user flow:
             *
             * User service select کر سکتا ہے، providers دیکھ سکتا
             * ہے اور WhatsApp/Call کے ذریعے contact کر سکتا ہے۔
             */
            return const SelectServiceScreen();
          },
        );
      },
    );
  }
}

/// Firestore routing information
class UserRouteData {
  final String role;
  final bool profileCompleted;

  const UserRouteData({required this.role, required this.profileCompleted});
}

/// Loading screen
class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryYellow),
        ),
      ),
    );
  }
}

/// Firebase/Firestore error screen
class AuthErrorScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AuthErrorScreen({
    super.key,
    required this.message,
    required this.onRetry,
  });

  Future<void> _signOut() async {
    await AuthService.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 68,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Something Went Wrong',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(onPressed: _signOut, child: const Text('Logout')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Firebase account موجود ہو لیکن Firestore document نہ ملے۔
class MissingUserDocumentScreen extends StatefulWidget {
  final User firebaseUser;

  const MissingUserDocumentScreen({super.key, required this.firebaseUser});

  @override
  State<MissingUserDocumentScreen> createState() =>
      _MissingUserDocumentScreenState();
}

class _MissingUserDocumentScreenState extends State<MissingUserDocumentScreen> {
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
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'Could not logout: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person_off_outlined,
                  size: 70,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 18),
                const Text(
                  'Profile Not Found',
                  style: TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Firebase account exists for:\n'
                  '${widget.firebaseUser.email ?? ''}\n\n'
                  'but users/${widget.firebaseUser.uid} '
                  'does not exist in Firestore.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    height: 1.5,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _logout,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Logout and Register Again'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
