import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/auth_Service.dart';
import 'package:service_hub/new/confirm_booking_screen.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/provider_service_screen.dart';
import 'package:service_hub/new/user_model.dart'
    hide ProviderService, ProviderProfile;
import '../../theme/app_theme.dart';
import 'edit_provider_profile_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  final String providerId;
  final bool ownerView;

  const ProviderProfileScreen({
    super.key,
    required this.providerId,
    this.ownerView = false,
  });

  bool get _isCurrentProvider {
    return AuthService.instance.currentUser?.uid == providerId;
  }

  void _openBookingScreen(
    BuildContext context,
    ProviderProfile provider,
    ProviderService service,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConfirmBookingScreen(
          provider: provider,
          service: service,
        ),
      ),
    );
  }

  void _openEditProfile(
    BuildContext context,
    ProviderProfile provider,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProviderProfileScreen(
          providerProfile: provider,
        ),
      ),
    );
  }

  void _openManageServices(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProviderServicesScreen(
          providerId: providerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showOwnerActions = ownerView || _isCurrentProvider;

    return Scaffold(
      backgroundColor: AppColors.cardDark,
      appBar: AppBar(
        title: const Text('Provider Profile'),
        actions: [
          if (showOwnerActions)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'services') {
                  _openManageServices(context);
                  return;
                }

                if (value == 'edit') {
                  final provider =
                      await FirestoreService.instance.getProvider(providerId);

                  if (provider != null && context.mounted) {
                    _openEditProfile(context, provider);
                  }
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit Profile'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'services',
                  child: Row(
                    children: [
                      Icon(Icons.home_repair_service_outlined),
                      SizedBox(width: 10),
                      Text('Manage Services'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<ProviderProfile?>(
          stream: FirestoreService.instance.watchProvider(
            providerId,
          ),
          builder: (context, providerSnapshot) {
            if (providerSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (providerSnapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Could Not Load Profile',
                message: providerSnapshot.error.toString(),
              );
            }

            final provider = providerSnapshot.data;

            if (provider == null) {
              return const EmptyStateWidget(
                icon: Icons.person_off_outlined,
                title: 'Provider Not Found',
                message: 'This provider profile is no longer available.',
              );
            }

            return StreamBuilder<List<ProviderService>>(
              stream:
                  FirestoreService.instance.watchProviderServices(provider.uid),
              builder: (context, servicesSnapshot) {
                if (servicesSnapshot.hasError) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Could Not Load Services',
                    message: servicesSnapshot.error.toString(),
                  );
                }

                final services =
                    servicesSnapshot.data ?? const <ProviderService>[];

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    18,
                    18,
                    28,
                  ),
                  children: [
                    _ProviderProfileHeader(
                      provider: provider,
                    ),
                    const SizedBox(height: 18),
                    _AboutCard(
                      about: provider.about,
                      address: provider.address,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Services',
                            style: TextStyle(
                              color: AppColors.darkBg,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (showOwnerActions)
                          TextButton.icon(
                            onPressed: () {
                              _openManageServices(context);
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 17,
                            ),
                            label: const Text('Manage'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (servicesSnapshot.connectionState ==
                        ConnectionState.waiting)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (services.isEmpty)
                      _NoServicesCard(
                        ownerView: showOwnerActions,
                        onManageServices: () {
                          _openManageServices(context);
                        },
                      )
                    else
                      ...services.map(
                        (service) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: 13,
                          ),
                          child: _ProfileServiceCard(
                            service: service,
                            ownerView: showOwnerActions,
                            onSelect: () {
                              _openBookingScreen(
                                context,
                                provider,
                                service,
                              );
                            },
                          ),
                        ),
                      ),
                    if (!showOwnerActions && !provider.isLive) ...[
                      const SizedBox(height: 18),
                      const InfoMessageBox(
                        message:
                            'This provider is currently offline. Please check again later.',
                      ),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProviderProfileHeader extends StatelessWidget {
  final ProviderProfile provider;

  const _ProviderProfileHeader({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              InitialsAvatar(
                name: provider.name,
                radius: 45,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: provider.isLive
                        ? AppColors.success
                        : AppColors.textGrey,
                    border: Border.all(
                      color: AppColors.darkBg,
                      width: 3,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Text(
            provider.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            provider.mainService,
            style: const TextStyle(
              color: AppColors.primaryYellow,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          VerificationBadge(
            verified: provider.verified,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.primaryYellow,
                size: 22,
              ),
              const SizedBox(width: 4),
              Text(
                provider.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' (${provider.reviewCount} reviews)',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: provider.isLive
                  // ignore: deprecated_member_use
                  ? AppColors.success.withOpacity(0.18)
                  // ignore: deprecated_member_use
                  : AppColors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              provider.isLive ? 'Available Now' : 'Currently Offline',
              style: TextStyle(
                color: provider.isLive ? AppColors.success : AppColors.textGrey,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final String about;
  final String address;

  const _AboutCard({
    required this.about,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About Provider',
            style: TextStyle(
              color: AppColors.darkBg,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            about.isEmpty ? 'No introduction has been added yet.' : about,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.success,
                size: 19,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoServicesCard extends StatelessWidget {
  final bool ownerView;
  final VoidCallback onManageServices;

  const _NoServicesCard({
    required this.ownerView,
    required this.onManageServices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardDark,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.home_repair_service_outlined,
            color: AppColors.textGrey,
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(
            ownerView
                ? 'You have not added a service yet.'
                : 'No services available yet.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
            ),
          ),
          if (ownerView) ...[
            const SizedBox(height: 13),
            TextButton(
              onPressed: onManageServices,
              child: const Text('Add Service'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileServiceCard extends StatelessWidget {
  final ProviderService service;
  final bool ownerView;
  final VoidCallback onSelect;

  const _ProfileServiceCard({
    required this.service,
    required this.ownerView,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final category = serviceCategoryByName(
      service.category,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.darkBg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        color: AppColors.darkBg,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service.category,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'PKR ${service.hourlyCharge.toStringAsFixed(0)}/hr',
                style: const TextStyle(
                  color: AppColors.primaryYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            service.description,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 11),
          Text(
            '${service.experienceYears} years experience • ${service.serviceArea}',
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
            ),
          ),
          if (!ownerView) ...[
            const SizedBox(height: 15),
            PrimaryButton(
              label: 'Select Service',
              icon: Icons.calendar_month_outlined,
              onPressed: onSelect,
            ),
          ],
        ],
      ),
    );
  }
}
