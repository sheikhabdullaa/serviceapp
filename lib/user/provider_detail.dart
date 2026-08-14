// import 'package:flutter/material.dart';
// import 'package:service_hub/model/model.dart';
// import 'package:service_hub/services/fire_Store_services.dart';
// import 'package:service_hub/user/confirm_booking.dart';
// import 'package:service_hub/widgets/intial_avater.dart';
// import '../../services/whatsapp_service.dart';
// import '../../theme/app_theme.dart';
// import '../../widgets/common_widgets.dart';

// class ProviderDetailsScreen extends StatelessWidget {
//   final ProviderProfile provider;
//   const ProviderDetailsScreen({super.key, required this.provider});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(provider.service)),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 InitialsAvatar(name: provider.name, radius: 34),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(provider.name,
//                           style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                       Row(
//                         children: [
//                           const Icon(Icons.star, size: 16, color: AppColors.primaryYellow),
//                           Text(' ${provider.rating.toStringAsFixed(1)} (${provider.reviewCount} Reviews)'),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SectionTitle('About'),
//             Text(provider.about.isEmpty ? 'No description added yet.' : provider.about),
//             const SectionTitle('Service'),
//             Chip(label: Text(provider.service)),
//             const SizedBox(height: 28),
//             Row(
//               children: [
//                 Expanded(
//                   child: WhatsAppButton(
//                     onPressed: () {
//                       FirestoreService.instance.incrementCounter(provider.uid, 'totalContacts');
//                       WhatsAppService.openChat(
//                         provider.whatsapp,
//                         message: "Hi ${provider.name}, I found you on KaamSetu for ${provider.service}.",
//                       );
//                     },
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: OutlinedButton.icon(
//                     onPressed: () => WhatsAppService.call(provider.whatsapp),
//                     icon: const Icon(Icons.call),
//                     label: const Text('Call'),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             PrimaryButton(
//               label: 'Book / Confirm Booking',
//               onPressed: () => Navigator.of(context).push(MaterialPageRoute(
//                 builder: (_) => ConfirmBookingScreen(provider: provider),
//               )),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
