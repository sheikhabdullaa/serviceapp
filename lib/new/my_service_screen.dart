import 'package:flutter/material.dart';
import 'package:service_hub/new/add_edit_Service_screen.dart';
import 'package:service_hub/new/add_edit_service.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/profile_live_screen.dart';
import 'package:service_hub/new/user_model.dart'
    hide ProviderService, ProviderProfile;

import '../../theme/app_theme.dart';

class MyServicesScreen extends StatefulWidget {
  final ProviderProfile? providerProfile;
  final bool isInitialSetup;

  const MyServicesScreen({
    super.key,
    this.providerProfile,
    this.isInitialSetup = false,
  });

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  late Future<ProviderProfile?> _providerFuture;

  @override
  void initState() {
    super.initState();

    _providerFuture = widget.providerProfile != null
        ? Future.value(
            widget.providerProfile,
          )
        : FirestoreService.instance.getCurrentProvider();
  }

  void _reloadProvider() {
    setState(() {
      _providerFuture = FirestoreService.instance.getCurrentProvider();
    });
  }

  Future<void> _openAddService(
    ProviderProfile provider,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          providerProfile: provider,
          providerId: '',
          existingService: ProviderService.empty(),
        ),
      ),
    );

    if (mounted) {
      _reloadProvider();
    }
  }

  Future<void> _openEditService({
    required ProviderProfile provider,
    required ProviderService service,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          providerProfile: provider,
          existingService: service,
          providerId: '',
        ),
      ),
    );
  }

  Future<void> _toggleService(
    ProviderService service,
  ) async {
    try {
      await FirestoreService.instance.setServiceActive(
        providerId: service.providerId,
        serviceId: service.id,
        isActive: !service.isActive,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            service.isActive ? 'Service deactivated' : 'Service activated',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update service: $error',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _deleteService(
    ProviderService service,
  ) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Service?',
      message:
          'Are you sure you want to delete "${service.title}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (!confirmed) return;

    try {
      await FirestoreService.instance.deleteProviderService(
        providerId: service.providerId,
        serviceId: service.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service deleted'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete service: $error',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _openGoLive(
    ProviderProfile provider,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileLiveScreen(
          providerProfile: provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProviderProfile?>(
      future: _providerFuture,
      builder: (context, providerSnapshot) {
        if (providerSnapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingScreen(
            message: 'Loading your services...',
          );
        }

        if (providerSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Services'),
            ),
            body: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Could Not Load Profile',
              message: providerSnapshot.error.toString(),
              buttonLabel: 'Try Again',
              onButtonPressed: _reloadProvider,
            ),
          );
        }

        final provider = providerSnapshot.data;

        if (provider == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('My Services'),
            ),
            body: EmptyStateWidget(
              icon: Icons.person_off_outlined,
              title: 'Provider Profile Not Found',
              message: 'Complete your provider profile before adding services.',
              buttonLabel: 'Try Again',
              onButtonPressed: _reloadProvider,
            ),
          );
        }

        return _buildServicesScreen(provider);
      },
    );
  }

  Widget _buildServicesScreen(
    ProviderProfile provider,
  ) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      appBar: AppBar(
        automaticallyImplyLeading: !widget.isInitialSetup,
        title: Text(
          widget.isInitialSetup ? 'Add Your Services' : 'My Services',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openAddService(provider);
        },
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.darkBg,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Service',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ProviderService>>(
          stream: FirestoreService.instance.watchProviderServices(
            provider.uid,
          ),
          builder: (context, serviceSnapshot) {
            if (serviceSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (serviceSnapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Could Not Load Services',
                message: serviceSnapshot.error.toString(),
              );
            }

            final services = serviceSnapshot.data ?? const <ProviderService>[];

            final activeServices = services
                .where(
                  (service) => service.isActive,
                )
                .length;

            return Column(
              children: [
                if (widget.isInitialSetup)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(
                      18,
                      16,
                      18,
                      0,
                    ),
                    child: InfoMessageBox(
                      message:
                          'Add at least one active service before making your provider profile live.',
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: _ServiceSummary(
                    totalServices: services.length,
                    activeServices: activeServices,
                  ),
                ),
                Expanded(
                  child: services.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.home_repair_service_outlined,
                          title: 'No Services Added',
                          message:
                              'Add your first service so users can find and contact you.',
                          buttonLabel: 'Add First Service',
                          onButtonPressed: () {
                            _openAddService(
                              provider,
                            );
                          },
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            18,
                            0,
                            18,
                            120,
                          ),
                          itemCount: services.length,
                          separatorBuilder: (context, index) => const SizedBox(
                            height: 13,
                          ),
                          itemBuilder: (context, index) {
                            final service = services[index];

                            return _ServiceCard(
                              service: service,
                              onEdit: () {
                                _openEditService(
                                  provider: provider,
                                  service: service,
                                );
                              },
                              onToggle: () {
                                _toggleService(
                                  service,
                                );
                              },
                              onDelete: () {
                                _deleteService(
                                  service,
                                );
                              },
                            );
                          },
                        ),
                ),
                if (widget.isInitialSetup && services.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      12,
                      18,
                      18,
                    ),
                    color: AppColors.white,
                    child: PrimaryButton(
                      label: 'Continue to Go Live',
                      icon: Icons.rocket_launch_outlined,
                      onPressed: activeServices > 0
                          ? () {
                              _openGoLive(
                                provider,
                              );
                            }
                          : null,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ServiceSummary extends StatelessWidget {
  final int totalServices;
  final int activeServices;

  const _ServiceSummary({
    required this.totalServices,
    required this.activeServices,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              value: '$totalServices',
              label: 'Total Services',
            ),
          ),
          Container(
            width: 1,
            height: 42,
            // ignore: deprecated_member_use
            color: AppColors.white.withOpacity(0.18),
          ),
          Expanded(
            child: _SummaryItem(
              value: '$activeServices',
              label: 'Active Services',
              valueColor: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _SummaryItem({
    required this.value,
    required this.label,
    this.valueColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ProviderService service;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ServiceCard({
    required this.service,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
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
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: service.isActive
              // ignore: deprecated_member_use
              ? AppColors.success.withOpacity(0.25)
              : AppColors.cardDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.darkBg,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
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
                    const SizedBox(height: 4),
                    Text(
                      service.category,
                      style: const TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                      break;

                    case 'toggle':
                      onToggle();
                      break;

                    case 'delete':
                      onDelete();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                        ),
                        SizedBox(width: 9),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          service.isActive
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          service.isActive ? 'Deactivate' : 'Activate',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.danger,
                          size: 20,
                        ),
                        SizedBox(width: 9),
                        Text(
                          'Delete',
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
          const SizedBox(height: 13),
          Text(
            service.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ServiceChip(
                icon: Icons.work_history_outlined,
                label: '${service.experienceYears} years',
              ),
              _ServiceChip(
                icon: Icons.payments_outlined,
                label: 'PKR ${service.hourlyCharge.toStringAsFixed(0)}/hr',
              ),
              _ServiceChip(
                icon: Icons.location_on_outlined,
                label: service.serviceArea,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: (service.isActive
                          ? AppColors.success
                          : AppColors.textGrey)
                      // ignore: deprecated_member_use
                      .withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  service.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: service.isActive
                        ? AppColors.success
                        : AppColors.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 17,
                ),
                label: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textGrey,
          ),
          const SizedBox(width: 5),
          Text(
            label,
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
