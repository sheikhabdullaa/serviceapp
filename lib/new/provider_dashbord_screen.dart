import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/auth_Service.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/new_role_Selection.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/provider_booking_screen.dart';
import 'package:service_hub/new/provider_service_screen.dart';
import '../../theme/app_theme.dart';
import 'edit_provider_profile_screen.dart';
import 'provider_profile_screen.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final String providerId;

  const ProviderDashboardScreen({
    super.key,
    required this.providerId,
  });

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  bool _updatingStatus = false;
  bool _loggingOut = false;

  Future<void> _changeLiveStatus(
    ProviderProfile provider,
    bool isLive,
  ) async {
    if (_updatingStatus) return;

    setState(() {
      _updatingStatus = true;
    });

    try {
      await FirestoreService.instance.updateProviderFields(
        uid: provider.uid,
        data: {
          'isLive': isLive,
        },
        providerId: widget.providerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isLive ? 'You are now live for bookings.' : 'You are now offline.',
          ),
          backgroundColor: isLive ? AppColors.success : AppColors.textGrey,
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not update availability. Please try again.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingStatus = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    if (_loggingOut) return;

    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Logout?',
      message: 'Are you sure you want to logout from Service Hub?',
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
    } catch (_) {
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

  void _openBookings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderBookingsScreen(
          providerId: widget.providerId,
        ),
      ),
    );
  }

  void _openServices() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderServicesScreen(
          providerId: widget.providerId,
        ),
      ),
    );
  }

  void _openProfile(
    ProviderProfile provider,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderProfileScreen(
          providerId: provider.uid,
          ownerView: true,
        ),
      ),
    );
  }

  void _editProfile(
    ProviderProfile provider,
  ) async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProviderProfileScreen(
          providerProfile: provider,
        ),
      ),
    );

    if (updated == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardDark,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Provider Dashboard'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                FirestoreService.instance
                    .getProvider(widget.providerId)
                    .then((provider) {
                  if (provider != null && mounted) {
                    _openProfile(provider);
                  }
                });
              }

              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline),
                    SizedBox(width: 10),
                    Text('My Profile'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<ProviderProfile?>(
          stream: FirestoreService.instance.watchProvider(widget.providerId),
          builder: (context, providerSnapshot) {
            if (providerSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (providerSnapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Could Not Load Dashboard',
                message: providerSnapshot.error.toString(),
              );
            }

            final provider = providerSnapshot.data;

            if (provider == null) {
              return const EmptyStateWidget(
                icon: Icons.person_off_outlined,
                title: 'Provider Profile Not Found',
                message: 'Please complete your provider profile first.',
              );
            }

            return StreamBuilder<List<BookingRequest>>(
              stream:
                  FirestoreService.instance.watchProviderBookings(provider.uid),
              builder: (context, bookingSnapshot) {
                final bookings =
                    bookingSnapshot.data ?? const <BookingRequest>[];

                final requestedCount = bookings
                    .where(
                      (booking) => booking.status == 'requested',
                    )
                    .length;

                final acceptedCount = bookings
                    .where(
                      (booking) => booking.status == 'accepted',
                    )
                    .length;

                final completedCount = bookings
                    .where(
                      (booking) => booking.status == 'completed',
                    )
                    .length;

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      18,
                      18,
                      28,
                    ),
                    children: [
                      _ProviderWelcomeCard(
                        provider: provider,
                        updatingStatus: _updatingStatus,
                        onLiveChanged: (isLive) {
                          _changeLiveStatus(
                            provider,
                            isLive,
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: AppColors.darkBg,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 13),
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardStatCard(
                              title: 'New Requests',
                              value: requestedCount.toString(),
                              icon: Icons.notifications_outlined,
                              color: AppColors.primaryYellow,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DashboardStatCard(
                              title: 'Accepted',
                              value: acceptedCount.toString(),
                              icon: Icons.calendar_month_outlined,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _DashboardStatCard(
                        title: 'Completed Jobs',
                        value: completedCount.toString(),
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                        fullWidth: true,
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
                      const SizedBox(height: 13),
                      _DashboardActionCard(
                        icon: Icons.calendar_month_outlined,
                        title: 'Booking Requests',
                        subtitle: requestedCount == 0
                            ? 'View customer requests'
                            : '$requestedCount new request${requestedCount == 1 ? '' : 's'} waiting',
                        badgeText: requestedCount == 0
                            ? null
                            : requestedCount.toString(),
                        onTap: _openBookings,
                      ),
                      const SizedBox(height: 12),
                      _DashboardActionCard(
                        icon: Icons.home_repair_service_outlined,
                        title: 'My Services',
                        subtitle: 'Add, update or remove your services',
                        onTap: _openServices,
                      ),
                      const SizedBox(height: 12),
                      _DashboardActionCard(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        subtitle: 'Update contact details and service area',
                        onTap: () {
                          _editProfile(provider);
                        },
                      ),
                      const SizedBox(height: 12),
                      _DashboardActionCard(
                        icon: Icons.person_outline,
                        title: 'View Public Profile',
                        subtitle: 'See how customers see your profile',
                        onTap: () {
                          _openProfile(provider);
                        },
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: _loggingOut ? null : _logout,
                        icon: _loggingOut
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProviderWelcomeCard extends StatelessWidget {
  final ProviderProfile provider;
  final bool updatingStatus;
  final ValueChanged<bool> onLiveChanged;

  const _ProviderWelcomeCard({
    required this.provider,
    required this.updatingStatus,
    required this.onLiveChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InitialsAvatar(
                name: provider.name,
                radius: 29,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assalam-o-Alaikum, ${provider.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
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
            ],
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: AppColors.white.withOpacity(0.10),
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
                        ? 'You are live and visible to users'
                        : 'You are offline and hidden from users',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                Switch(
                  value: provider.isLive,
                  onChanged: updatingStatus ? null : onLiveChanged,
                  // ignore: deprecated_member_use
                  activeColor: AppColors.success,
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
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.cardDark,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: AppColors.cardDark,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.darkBg,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.darkBg,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeText != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
