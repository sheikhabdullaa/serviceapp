// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:service_hub/model/model.dart';
// import 'package:service_hub/sacreens/provider/edit_profile.dart';
// import 'package:service_hub/sacreens/provider/my_booking.dart';
// import 'package:service_hub/sacreens/provider/profile_live.dart';
// import 'package:service_hub/sacreens/role_selection.dart';
// import 'package:service_hub/services/auth_services.dart';
// import 'package:service_hub/services/fire_Store_services.dart';
// import 'package:service_hub/widgets/intial_avater.dart';
// import '../../theme/app_theme.dart';

// class ProviderDashboardScreen extends StatelessWidget {
//   const ProviderDashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser!.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Dashboard'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await AuthService.instance.signOut();
//               if (context.mounted) {
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
//                   (route) => false,
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<ProviderProfile?>(
//         stream: FirestoreService.instance.watchProvider(uid),
//         builder: (context, snap) {
//           if (!snap.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final p = snap.data!;
//           return ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               Row(
//                 children: [
//                   InitialsAvatar(name: p.name, radius: 30),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(p.name,
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 18)),
//                         Row(
//                           children: [
//                             Icon(Icons.circle,
//                                 size: 10,
//                                 color: p.verified
//                                     ? AppColors.success
//                                     : AppColors.textGrey),
//                             const SizedBox(width: 4),
//                             Text(
//                                 p.verified
//                                     ? 'Verified'
//                                     : 'Pending verification',
//                                 style: const TextStyle(fontSize: 12)),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   _StatBox(label: 'Views', value: '${p.totalViews}'),
//                   const SizedBox(width: 10),
//                   _StatBox(label: 'Contacts', value: '${p.totalContacts}'),
//                   const SizedBox(width: 10),
//                   _StatBox(label: 'Bookings', value: '${p.totalBookings}'),
//                 ],
//               ),
//               const SizedBox(height: 24),
//               Container(
//                 padding: const EdgeInsets.all(18),
//                 decoration: BoxDecoration(
//                   color: p.isLive
//                       // ignore: deprecated_member_use
//                       ? AppColors.success.withOpacity(0.1)
//                       : const Color(0xFFF1F5F9),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.podcasts,
//                         color:
//                             p.isLive ? AppColors.success : AppColors.textGrey),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(p.isLive ? 'You are Live!' : 'You are Offline',
//                               style:
//                                   const TextStyle(fontWeight: FontWeight.bold)),
//                           Text(
//                             p.isLive
//                                 ? 'Users can see your profile and contact you.'
//                                 : 'Go live so nearby users can find you.',
//                             style: const TextStyle(
//                                 fontSize: 12, color: AppColors.textGrey),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Switch(
//                       value: p.isLive,
//                       // ignore: deprecated_member_use
//                       activeColor: AppColors.success,
//                       onChanged: (v) =>
//                           FirestoreService.instance.setLive(uid, v),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               _MenuTile(
//                 icon: Icons.edit_outlined,
//                 label: 'Edit Profile',
//                 onTap: () => Navigator.of(context).push(MaterialPageRoute(
//                     builder: (_) => EditProfileScreen(provider: p))),
//               ),
//               _MenuTile(
//                 icon: Icons.event_note_outlined,
//                 label: 'My Bookings',
//                 onTap: () => Navigator.of(context).push(MaterialPageRoute(
//                     builder: (_) => const MyBookingsScreen())),
//               ),
//               _MenuTile(
//                 icon: Icons.ios_share,
//                 label: 'Share Profile Link',
//                 onTap: () => Navigator.of(context).push(MaterialPageRoute(
//                     builder: (_) => ProfileLiveScreen(provider: p))),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class _StatBox extends StatelessWidget {
//   final String label;
//   final String value;
//   const _StatBox({required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF1F5F9),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Column(
//           children: [
//             Text(value,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//             Text(label,
//                 style:
//                     const TextStyle(fontSize: 12, color: AppColors.textGrey)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _MenuTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final VoidCallback onTap;
//   const _MenuTile(
//       {required this.icon, required this.label, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       contentPadding: EdgeInsets.zero,
//       leading: Icon(icon, color: AppColors.darkBg),
//       title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
//       trailing: const Icon(Icons.chevron_right),
//       onTap: onTap,
//     );
//   }
// }
