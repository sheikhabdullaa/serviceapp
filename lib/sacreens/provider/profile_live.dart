// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:service_hub/model/model.dart';
// import 'package:service_hub/widgets/intial_avater.dart';
// import '../../services/whatsapp_service.dart';
// import '../../theme/app_theme.dart';
// import '../../widgets/common_widgets.dart';

// /// Simple shareable profile link. Point this at any lightweight public
// /// web page you host (e.g. Firebase Hosting) that reads providers/{uid}
// /// from Firestore and renders a read-only profile.
// class ProfileLiveScreen extends StatelessWidget {
//   final ProviderProfile provider;
//   const ProfileLiveScreen({super.key, required this.provider});

//   String get _link => 'https://kaamsetu.app/p/${provider.uid}';

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Share Your Profile')),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           children: [
//             InitialsAvatar(name: provider.name, radius: 40),
//             const SizedBox(height: 14),
//             Text(provider.name,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             Text(provider.service,
//                 style: const TextStyle(color: AppColors.textGrey)),
//             const SizedBox(height: 28),
//             Container(
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF1F5F9),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(child: Text(_link, overflow: TextOverflow.ellipsis)),
//                   IconButton(
//                     icon: const Icon(Icons.copy, size: 20),
//                     onPressed: () {
//                       Clipboard.setData(ClipboardData(text: _link));
//                       ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Link copied!')));
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             WhatsAppButton(
//               label: 'Share on WhatsApp',
//               onPressed: () => WhatsAppService.openChat(
//                 provider.whatsapp,
//                 message: 'Check out my KaamSetu profile: $_link',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
