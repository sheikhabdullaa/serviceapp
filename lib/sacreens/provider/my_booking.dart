// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:service_hub/model/model.dart';
// import 'package:service_hub/services/fire_Store_services.dart';
// import '../../theme/app_theme.dart';

// class MyBookingsScreen extends StatelessWidget {
//   const MyBookingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser!.uid;
//     return Scaffold(
//       appBar: AppBar(title: const Text('My Bookings')),
//       body: StreamBuilder<List<BookingRequest>>(
//         stream: FirestoreService.instance.watchProviderBookings(uid),
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           final bookings = snap.data ?? [];
//           if (bookings.isEmpty) {
//             return const Center(child: Text('No booking requests yet.'));
//           }
//           return ListView.separated(
//             padding: const EdgeInsets.all(16),
//             itemCount: bookings.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 10),
//             itemBuilder: (context, i) {
//               final b = bookings[i];
//               return Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: const Color(0xFFE2E8F0)),
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             b.userName,
//                             style: const TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '${b.service} • ${b.date.day}/${b.date.month}/${b.date.year} • ${b.time}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: AppColors.textGrey,
//                             ),
//                           ),
//                           if (b.note.isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 4),
//                               child: Text(
//                                 b.note,
//                                 style: const TextStyle(fontSize: 12),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     Chip(
//                       label: Text(b.status),
//                       backgroundColor: const Color(0xFFF1F5F9),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
