// import 'package:flutter/material.dart';
// import 'package:service_hub/model/model.dart';
// import 'package:service_hub/user/select_service.dart';
// import '../../services/whatsapp_service.dart';
// import '../../theme/app_theme.dart';
// import '../../widgets/common_widgets.dart';

// class RequestSentScreen extends StatelessWidget {
//   final ProviderProfile provider;
//   const RequestSentScreen({super.key, required this.provider});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(28),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 90,
//                 height: 90,
//                 decoration: const BoxDecoration(
//                     color: AppColors.success, shape: BoxShape.circle),
//                 child: const Icon(Icons.check, color: Colors.white, size: 48),
//               ),
//               const SizedBox(height: 24),
//               const Text('Request Sent!',
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 10),
//               Text(
//                 'You can now chat with ${provider.name} on WhatsApp',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: AppColors.textGrey),
//               ),
//               const SizedBox(height: 30),
//               WhatsAppButton(
//                 label: 'Open WhatsApp',
//                 onPressed: () => WhatsAppService.openChat(provider.whatsapp),
//               ),
//               const SizedBox(height: 12),
//               OutlinedButton(
//                 onPressed: () => Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(
//                       builder: (_) => const SelectServiceScreen()),
//                   (route) => false,
//                 ),
//                 child: const Text('Back to Home'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
