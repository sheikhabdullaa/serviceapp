// import 'package:flutter/material.dart';
// import 'package:service_hub/model/model.dart';
// import 'package:service_hub/services/fire_Store_services.dart';
// import 'package:service_hub/user/provider_detail.dart';
// import 'package:service_hub/widgets/intial_avater.dart';
// import '../../theme/app_theme.dart';

// class ProviderListScreen extends StatelessWidget {
//   final String service;
//   const ProviderListScreen({super.key, required this.service});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(service)),
//       body: StreamBuilder<List<ProviderProfile>>(
//         stream: FirestoreService.instance.watchProvidersForService(service),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final providers = snap.data ?? [];
//           if (providers.isEmpty) {
//             return const Center(
//                 child: Text('No providers online for this service yet.'));
//           }
//           return ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: providers.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, i) {
//               final p = providers[i];
//               return InkWell(
//                 borderRadius: BorderRadius.circular(14),
//                 onTap: () {
//                   FirestoreService.instance
//                       .incrementCounter(p.uid, 'totalViews');
//                   Navigator.of(context).push(MaterialPageRoute(
//                     builder: (_) => ProviderDetailsScreen(provider: p),
//                   ));
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: const Color(0xFFE2E8F0)),
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                   child: Row(
//                     children: [
//                       InitialsAvatar(name: p.name, radius: 26),
//                       const SizedBox(width: 14),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(p.name,
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.bold)),
//                                 if (p.verified) ...[
//                                   const SizedBox(width: 6),
//                                   const Icon(Icons.verified,
//                                       size: 16, color: AppColors.success),
//                                 ],
//                               ],
//                             ),
//                             const SizedBox(height: 2),
//                             Text(p.service,
//                                 style:
//                                     const TextStyle(color: AppColors.textGrey)),
//                             const SizedBox(height: 2),
//                             Row(
//                               children: [
//                                 const Icon(Icons.star,
//                                     size: 14, color: AppColors.primaryYellow),
//                                 Text(
//                                     ' ${p.rating.toStringAsFixed(1)} (${p.reviewCount})',
//                                     style: const TextStyle(fontSize: 12)),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                       const Icon(Icons.chevron_right),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
