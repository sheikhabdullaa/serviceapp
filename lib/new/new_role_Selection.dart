// ignore: file_names
import 'package:flutter/material.dart';
import 'package:service_hub/new/email_login_screen.dart';

import '../theme/app_theme.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  void _openLogin({
    required BuildContext context,
    required String role,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmailLoginScreen(
          role: role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Choose Your Role'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'How do you want to use Service Hub?',
                style: TextStyle(
                  color: AppColors.darkBg,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Select the option that best describes you.',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              RoleSelectionCard(
                icon: Icons.person_search_outlined,
                title: 'Find a Service',
                roleLabel: 'Service Lene Wala',
                description:
                    'Find trusted plumbers, electricians, drivers, carpenters and other local service providers.',
                buttonLabel: 'Continue as User',
                onTap: () {
                  _openLogin(
                    context: context,
                    role: 'user',
                  );
                },
              ),
              const SizedBox(height: 18),
              RoleSelectionCard(
                icon: Icons.handyman_outlined,
                title: 'Offer a Service',
                roleLabel: 'Service Dene Wala',
                description:
                    'Create your provider profile, add your services, go live and get more work.',
                buttonLabel: 'Continue as Provider',
                onTap: () {
                  _openLogin(
                    context: context,
                    role: 'provider',
                  );
                },
              ),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryYellow,
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Your selected role will be saved in your account. '
                        'After login, Service Hub will automatically open the correct app experience.',
                        style: TextStyle(
                          color: AppColors.darkBg,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleSelectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String roleLabel;
  final String description;
  final String buttonLabel;
  final VoidCallback onTap;

  const RoleSelectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.roleLabel,
    required this.description,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.darkBg,
            ),
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: AppColors.darkBg.withOpacity(0.05),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow,
                      borderRadius: BorderRadius.circular(
                        16,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.darkBg,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.darkBg,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          roleLabel,
                          style: const TextStyle(
                            color: AppColors.primaryYellow,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textGrey,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  buttonLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
