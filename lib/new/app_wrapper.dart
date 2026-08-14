import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/auth_Service.dart';
import 'package:service_hub/new/new_role_Selection.dart';
import 'package:service_hub/new/provider_dashbord.dart';
import 'package:service_hub/new/select_Service_Screen.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'firestore_service.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.instance.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _LoadingScreen();
        }

        final firebaseUser = authSnapshot.data;

        if (firebaseUser == null) {
          return const RoleSelectScreen();
        }

        return StreamBuilder<AppUser?>(
          stream: FirestoreService.instance.watchUser(
            firebaseUser.uid,
          ),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingScreen();
            }

            if (userSnapshot.hasError) {
              return _AppErrorScreen(
                title: 'Could Not Load Account',
                message:
                    'We could not load your account information. Please try again.',
                onLogout: () async {
                  await AuthService.instance.signOut();
                },
              );
            }

            final appUser = userSnapshot.data;

            if (appUser == null) {
              return _AppErrorScreen(
                title: 'Account Setup Required',
                message:
                    'Your account information was not found. Please login again or complete registration.',
                onLogout: () async {
                  await AuthService.instance.signOut();
                },
              );
            }

            if (appUser.role.toLowerCase() == 'provider') {
              return ProviderDashboardScreen(
                providerId: firebaseUser.uid,
              );
            }

            return const SelectServiceScreen();
          },
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _AppErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final Future<void> Function() onLogout;

  const _AppErrorScreen({
    required this.title,
    required this.message,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardDark,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: AppColors.darkBg,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: 190,
                  child: PrimaryButton(
                    label: 'Logout',
                    icon: Icons.logout,
                    onPressed: onLogout,
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
