import 'package:flutter/material.dart';
import 'package:service_hub/new/new_role_Selection.dart';
import 'package:service_hub/new/primary_buton.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  void _openRoleSelection(
    BuildContext context,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RoleSelectScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        const KaamSetuLogo(
                          size: 105,
                          darkBackground: true,
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'Fast. Simple. Reliable.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primaryYellow,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: Text(
                            'Connect with trusted local service '
                            'providers or offer your skills and '
                            'grow your work.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 15,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const Spacer(flex: 3),
                        PrimaryButton(
                          label: 'Get Started',
                          icon: Icons.arrow_forward,
                          onPressed: () {
                            _openRoleSelection(
                              context,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {
                              _openRoleSelection(
                                context,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.white,
                              side: const BorderSide(
                                color: AppColors.white,
                              ),
                            ),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: AppColors.success,
                              size: 18,
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Trusted. Simple. Connected.',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
