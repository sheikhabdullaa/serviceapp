// import 'package:flutter/material.dart';
// import 'package:service_hub/new/appuser.dart';
// import 'package:service_hub/new/firestore_service.dart';
// import 'package:service_hub/new/primary_buton.dart';
// import 'package:service_hub/new/user_model.dart' hide ProviderService;
// import '../../theme/app_theme.dart';
// import 'add_edit_service_screen.dart';

// class ProviderServicesScreen extends StatelessWidget {
//   final String providerId;

//   const ProviderServicesScreen({
//     super.key,
//     required this.providerId,
//   });

//   Future<void> _deleteService({
//     required BuildContext context,
//     required ProviderService service,
//   }) async {
//     final confirmed = await showConfirmationDialog(
//       context: context,
//       title: 'Delete Service?',
//       message:
//           'Are you sure you want to delete "${service.title}"? This cannot be undone.',
//       confirmLabel: 'Delete',
//       destructive: true,
//     );

//     if (!confirmed) return;

//     try {
//       await FirestoreService.instance.deleteProviderService(
//         serviceId: service.id,
//         providerId: providerId,
//       );

//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Service deleted successfully.'),
//           backgroundColor: AppColors.success,
//         ),
//       );
//     } catch (_) {
//       if (!context.mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Could not delete service. Please try again.',
//           ),
//           backgroundColor: AppColors.danger,
//         ),
//       );
//     }
//   }

//   void _openAddService(BuildContext context) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => AddEditServiceScreen(
//           providerId: providerId,
//           providerProfile: ,
//         ),
//       ),
//     );
//   }

//   void _openEditService(
//     BuildContext context,
//     ProviderService service,
//   ) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => AddEditServiceScreen(
//           providerId: providerId,
//           service: service,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.cardDark,
//       appBar: AppBar(
//         title: const Text('My Services'),
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           _openAddService(context);
//         },
//         backgroundColor: AppColors.primaryYellow,
//         foregroundColor: AppColors.darkBg,
//         icon: const Icon(Icons.add),
//         label: const Text(
//           'Add Service',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: StreamBuilder<List<ProviderService>>(
//           stream: FirestoreService.instance.watchProviderServices(providerId),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }

//             if (snapshot.hasError) {
//               return EmptyStateWidget(
//                 icon: Icons.error_outline,
//                 title: 'Could Not Load Services',
//                 message: snapshot.error.toString(),
//               );
//             }

//             final services = snapshot.data ?? const <ProviderService>[];

//             if (services.isEmpty) {
//               return _EmptyServicesView(
//                 onAddService: () {
//                   _openAddService(context);
//                 },
//               );
//             }

//             return ListView.separated(
//               padding: const EdgeInsets.fromLTRB(
//                 18,
//                 18,
//                 18,
//                 100,
//               ),
//               itemCount: services.length + 1,
//               separatorBuilder: (_, __) => const SizedBox(height: 14),
//               itemBuilder: (context, index) {
//                 if (index == 0) {
//                   return _ServiceInfoBanner(
//                     serviceCount: services.length,
//                   );
//                 }

//                 final service = services[index - 1];

//                 return _ProviderServiceCard(
//                   service: service,
//                   onEdit: () {
//                     _openEditService(
//                       context,
//                       service,
//                     );
//                   },
//                   onDelete: () {
//                     _deleteService(
//                       context: context,
//                       service: service,
//                     );
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// class _ServiceInfoBanner extends StatelessWidget {
//   final int serviceCount;

//   const _ServiceInfoBanner({
//     required this.serviceCount,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(17),
//       decoration: BoxDecoration(
//         color: AppColors.darkBg,
//         borderRadius: BorderRadius.circular(17),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 53,
//             height: 53,
//             decoration: BoxDecoration(
//               color: AppColors.primaryYellow,
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: const Icon(
//               Icons.home_repair_service_outlined,
//               color: AppColors.darkBg,
//               size: 29,
//             ),
//           ),
//           const SizedBox(width: 13),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '$serviceCount Active Service${serviceCount == 1 ? '' : 's'}',
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 17,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 const Text(
//                   'Users can select these services when booking you.',
//                   style: TextStyle(
//                     color: AppColors.textGrey,
//                     fontSize: 12,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _EmptyServicesView extends StatelessWidget {
//   final VoidCallback onAddService;

//   const _EmptyServicesView({
//     required this.onAddService,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(26),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 78,
//               height: 78,
//               decoration: BoxDecoration(
//                 color: AppColors.primaryYellow,
//                 borderRadius: BorderRadius.circular(22),
//               ),
//               child: const Icon(
//                 Icons.home_repair_service_outlined,
//                 color: AppColors.darkBg,
//                 size: 39,
//               ),
//             ),
//             const SizedBox(height: 18),
//             const Text(
//               'No Services Added',
//               style: TextStyle(
//                 color: AppColors.darkBg,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Add your first service so users can send you booking requests.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: AppColors.textGrey,
//                 fontSize: 13,
//                 height: 1.5,
//               ),
//             ),
//             const SizedBox(height: 20),
//             SizedBox(
//               width: 210,
//               child: PrimaryButton(
//                 label: 'Add First Service',
//                 icon: Icons.add,
//                 onPressed: onAddService,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ProviderServiceCard extends StatelessWidget {
//   final ProviderService service;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const _ProviderServiceCard({
//     required this.service,
//     required this.onEdit,
//     required this.onDelete,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final category = serviceCategoryByName(
//       service.category,
//     );

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: AppColors.cardDark,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 48,
//                 width: 48,
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryYellow,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   category.icon,
//                   color: AppColors.darkBg,
//                 ),
//               ),
//               const SizedBox(width: 13),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       service.title,
//                       style: const TextStyle(
//                         color: AppColors.darkBg,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       service.category,
//                       style: const TextStyle(
//                         color: AppColors.textGrey,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               PopupMenuButton<String>(
//                 padding: EdgeInsets.zero,
//                 onSelected: (value) {
//                   if (value == 'edit') {
//                     onEdit();
//                   }

//                   if (value == 'delete') {
//                     onDelete();
//                   }
//                 },
//                 itemBuilder: (context) => const [
//                   PopupMenuItem(
//                     value: 'edit',
//                     child: Row(
//                       children: [
//                         Icon(Icons.edit_outlined),
//                         SizedBox(width: 10),
//                         Text('Edit'),
//                       ],
//                     ),
//                   ),
//                   PopupMenuItem(
//                     value: 'delete',
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.delete_outline,
//                           color: AppColors.danger,
//                         ),
//                         SizedBox(width: 10),
//                         Text(
//                           'Delete',
//                           style: TextStyle(
//                             color: AppColors.danger,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           const SizedBox(height: 13),
//           Text(
//             service.description,
//             style: const TextStyle(
//               color: AppColors.textGrey,
//               fontSize: 13,
//               height: 1.45,
//             ),
//           ),
//           const SizedBox(height: 13),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: [
//               _ServiceDetailChip(
//                 icon: Icons.payments_outlined,
//                 label: 'PKR ${service.hourlyCharge.toStringAsFixed(0)}/hr',
//               ),
//               _ServiceDetailChip(
//                 icon: Icons.workspace_premium_outlined,
//                 label: '${service.experienceYears} years experience',
//               ),
//               _ServiceDetailChip(
//                 icon: Icons.location_on_outlined,
//                 label: service.serviceArea,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ServiceDetailChip extends StatelessWidget {
//   final IconData icon;
//   final String label;

//   const _ServiceDetailChip({
//     required this.icon,
//     required this.label,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: 9,
//         vertical: 6,
//       ),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF8FAFC),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             icon,
//             size: 15,
//             color: AppColors.textGrey,
//           ),
//           const SizedBox(width: 5),
//           ConstrainedBox(
//             constraints: const BoxConstraints(
//               maxWidth: 170,
//             ),
//             child: Text(
//               label,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               style: const TextStyle(
//                 color: AppColors.textGrey,
//                 fontSize: 11,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/user_model.dart'
    hide ProviderService, ProviderProfile;

import '../../theme/app_theme.dart';
import 'add_edit_service_screen.dart';

class ProviderServicesScreen extends StatelessWidget {
  final String providerId;

  const ProviderServicesScreen({
    super.key,
    required this.providerId,
  });

  Future<ProviderProfile?> _getProviderProfile(
    BuildContext context,
  ) async {
    try {
      final providerProfile = await FirestoreService.instance.getProvider(
        providerId,
      );

      if (providerProfile == null) {
        if (!context.mounted) return null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Provider profile could not be found.',
            ),
            backgroundColor: AppColors.danger,
          ),
        );

        return null;
      }

      return providerProfile;
    } catch (error) {
      if (!context.mounted) return null;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load provider profile: $error',
          ),
          backgroundColor: AppColors.danger,
        ),
      );

      return null;
    }
  }

  Future<void> _deleteService({
    required BuildContext context,
    required ProviderService service,
  }) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Delete Service?',
      message:
          'Are you sure you want to delete "${service.title}"? This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );

    if (!confirmed) return;

    try {
      await FirestoreService.instance.deleteProviderService(
        serviceId: service.id,
        providerId: providerId,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Service deleted successfully.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

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

  Future<void> _openAddService(
    BuildContext context,
  ) async {
    final providerProfile = await _getProviderProfile(
      context,
    );

    if (providerProfile == null || !context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          providerId: providerId,
          providerProfile: providerProfile,
        ),
      ),
    );
  }

  Future<void> _openEditService(
    BuildContext context,
    ProviderService service,
  ) async {
    final providerProfile = await _getProviderProfile(
      context,
    );

    if (providerProfile == null || !context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditServiceScreen(
          providerId: providerId,
          providerProfile: providerProfile,
          existingService: service,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardDark,
      appBar: AppBar(
        title: const Text('My Services'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _openAddService(context);
        },
        backgroundColor: AppColors.primaryYellow,
        foregroundColor: AppColors.darkBg,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ProviderService>>(
          stream: FirestoreService.instance.watchProviderServices(providerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Could Not Load Services',
                message: snapshot.error.toString(),
              );
            }

            final services = snapshot.data ?? const <ProviderService>[];

            if (services.isEmpty) {
              return _EmptyServicesView(
                onAddService: () {
                  _openAddService(context);
                },
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                100,
              ),
              itemCount: services.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _ServiceInfoBanner(
                    serviceCount: services.length,
                  );
                }

                final service = services[index - 1];

                return _ProviderServiceCard(
                  service: service,
                  onEdit: () {
                    _openEditService(
                      context,
                      service,
                    );
                  },
                  onDelete: () {
                    _deleteService(
                      context: context,
                      service: service,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ServiceInfoBanner extends StatelessWidget {
  final int serviceCount;

  const _ServiceInfoBanner({
    required this.serviceCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 53,
            height: 53,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.home_repair_service_outlined,
              color: AppColors.darkBg,
              size: 29,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$serviceCount Active Service${serviceCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Users can select these services when booking you.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    height: 1.4,
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

class _EmptyServicesView extends StatelessWidget {
  final VoidCallback onAddService;

  const _EmptyServicesView({
    required this.onAddService,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.home_repair_service_outlined,
                color: AppColors.darkBg,
                size: 39,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Services Added',
              style: TextStyle(
                color: AppColors.darkBg,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first service so users can send you booking requests.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 210,
              child: PrimaryButton(
                label: 'Add First Service',
                icon: Icons.add,
                onPressed: onAddService,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderServiceCard extends StatelessWidget {
  final ProviderService service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProviderServiceCard({
    required this.service,
    required this.onEdit,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.darkBg,
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
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  }

                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                        ),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.danger,
                        ),
                        SizedBox(width: 10),
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
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ServiceDetailChip(
                icon: Icons.payments_outlined,
                label: 'PKR ${service.hourlyCharge.toStringAsFixed(0)}/hr',
              ),
              _ServiceDetailChip(
                icon: Icons.workspace_premium_outlined,
                label: '${service.experienceYears} years experience',
              ),
              _ServiceDetailChip(
                icon: Icons.location_on_outlined,
                label: service.serviceArea,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceDetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceDetailChip({
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppColors.textGrey,
          ),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 170,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
