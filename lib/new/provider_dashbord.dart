import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/auth_Service.dart';
import 'package:service_hub/new/edit_provider_profile_screen.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/my_service_screen.dart';
import 'package:service_hub/new/new_role_Selection.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/provider_booking_screen.dart';
import 'package:service_hub/new/provider_profile_screen.dart';

import '../../theme/app_theme.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({
    super.key,
    required String providerId,
  });

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  bool _changingLiveStatus = false;
  bool _loggingOut = false;

  String? get _currentProviderId => AuthService.instance.currentUser?.uid;

  Future<void> _changeLiveStatus({
    required ProviderProfile provider,
    required bool isLive,
  }) async {
    if (_changingLiveStatus) return;

    setState(() {
      _changingLiveStatus = true;
    });

    try {
      await FirestoreService.instance.setProviderLive(
        providerId: provider.uid,
        isLive: isLive,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLive ? 'Your profile is now live' : 'Your profile is now offline',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } on StateError catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppColors.danger,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update live status: $error',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _changingLiveStatus = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    if (_loggingOut) return;

    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Logout?',
      message: 'Are you sure you want to logout from your provider account?',
      confirmLabel: 'Logout',
      destructive: true,
    );

    if (!confirmed) return;

    setState(() {
      _loggingOut = true;
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not logout. Please try again.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loggingOut = false;
        });
      }
    }
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Help & Support'),
          content: const Text(
            'For help with your provider account, '
            'services or verification, contact the '
            'Service Hub support team.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerId = _currentProviderId;

    if (providerId == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: EmptyStateWidget(
          icon: Icons.login,
          title: 'Session Expired',
          message: 'Please login again to access your provider dashboard.',
          buttonLabel: 'Return to Login',
          onButtonPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (_) => const RoleSelectScreen(),
              ),
              (route) => false,
            );
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _loggingOut ? null : _logout,
            icon: _loggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.logout_outlined,
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<ProviderProfile?>(
          stream: FirestoreService.instance.watchProvider(providerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Could Not Load Dashboard',
                message: snapshot.error.toString(),
              );
            }

            final provider = snapshot.data;

            if (provider == null) {
              return const EmptyStateWidget(
                icon: Icons.person_off_outlined,
                title: 'Provider Profile Not Found',
                message: 'Your provider profile could not be found.',
              );
            }

            return _DashboardContent(
              provider: provider,
              changingLiveStatus: _changingLiveStatus,
              onLiveStatusChanged: (value) {
                _changeLiveStatus(
                  provider: provider,
                  isLive: value,
                );
              },
              onViewProfile: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProviderProfileScreen(
                      providerId: provider.uid,
                      ownerView: true,
                    ),
                  ),
                );
              },
              onEditProfile: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditProviderProfileScreen(
                      providerProfile: provider,
                    ),
                  ),
                );
              },
              onServices: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MyServicesScreen(
                      providerProfile: provider,
                    ),
                  ),
                );
              },
              onBookings: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProviderBookingsScreen(
                      providerId: provider.uid,
                    ),
                  ),
                );
              },
              onHelp: _showHelpDialog,
              onLogout: _logout,
            );
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final ProviderProfile provider;
  final bool changingLiveStatus;
  final ValueChanged<bool> onLiveStatusChanged;
  final VoidCallback onViewProfile;
  final VoidCallback onEditProfile;
  final VoidCallback onServices;
  final VoidCallback onBookings;
  final VoidCallback onHelp;
  final VoidCallback onLogout;

  const _DashboardContent({
    required this.provider,
    required this.changingLiveStatus,
    required this.onLiveStatusChanged,
    required this.onViewProfile,
    required this.onEditProfile,
    required this.onServices,
    required this.onBookings,
    required this.onHelp,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProviderStatusCard(
            provider: provider,
            changingLiveStatus: changingLiveStatus,
            onLiveStatusChanged: onLiveStatusChanged,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DashboardStatCard(
                  icon: Icons.visibility_outlined,
                  value: '${provider.totalViews}',
                  label: 'Total Views',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashboardStatCard(
                  icon: Icons.phone_outlined,
                  value: '${provider.totalContacts}',
                  label: 'Contacts',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DashboardStatCard(
                  icon: Icons.calendar_month_outlined,
                  value: '${provider.totalBookings}',
                  label: 'Bookings',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Manage Account',
            style: TextStyle(
              color: AppColors.darkBg,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.cardDark,
              ),
            ),
            child: Column(
              children: [
                _DashboardMenuItem(
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  subtitle: 'View your public profile',
                  onTap: onViewProfile,
                ),
                const Divider(height: 1),
                _DashboardMenuItem(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update provider information',
                  onTap: onEditProfile,
                ),
                const Divider(height: 1),
                _DashboardMenuItem(
                  icon: Icons.home_repair_service_outlined,
                  title: 'My Services',
                  subtitle: 'Add and manage your services',
                  onTap: onServices,
                ),
                const Divider(height: 1),
                _DashboardMenuItem(
                  icon: Icons.calendar_month_outlined,
                  title: 'Booking Requests',
                  subtitle: 'View and manage user requests',
                  onTap: onBookings,
                ),
                const Divider(height: 1),
                _DashboardMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help with Service Hub',
                  onTap: onHelp,
                ),
                const Divider(height: 1),
                _DashboardMenuItem(
                  icon: Icons.logout,
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  textColor: AppColors.danger,
                  onTap: onLogout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProviderStatusCard extends StatelessWidget {
  final ProviderProfile provider;
  final bool changingLiveStatus;
  final ValueChanged<bool> onLiveStatusChanged;

  const _ProviderStatusCard({
    required this.provider,
    required this.changingLiveStatus,
    required this.onLiveStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InitialsAvatar(
                name: provider.name,
                radius: 30,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      provider.mainService,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              VerificationBadge(
                verified: provider.verified,
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: provider.isLive
                        ? AppColors.success
                        : AppColors.textGrey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    provider.isLive
                        ? 'Your profile is live'
                        : 'Your profile is offline',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (changingLiveStatus)
                  const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                else
                  Switch(
                    value: provider.isLive,
                    // ignore: deprecated_member_use
                    activeColor: AppColors.success,
                    onChanged: onLiveStatusChanged,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _DashboardStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cardDark,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.primaryYellow,
            size: 25,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.darkBg,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color textColor;
  final VoidCallback onTap;

  const _DashboardMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor = AppColors.darkBg,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: textColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(
          icon,
          color: textColor,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: textColor,
      ),
    );
  }
}
