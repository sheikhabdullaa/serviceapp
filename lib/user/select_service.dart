// import 'package:flutter/material.dart';
// import 'package:service_hub/user/provider_list.dart';
// import '../../theme/app_theme.dart';

// class SelectServiceScreen extends StatelessWidget {
//   const SelectServiceScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Select Service')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: GridView.builder(
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 2,
//             mainAxisSpacing: 14,
//             crossAxisSpacing: 14,
//             childAspectRatio: 1.1,
//           ),
//           itemCount: kServiceCategories.length,
//           itemBuilder: (context, i) {
//             final cat = kServiceCategories[i];
//             return InkWell(
//               borderRadius: BorderRadius.circular(16),
//               onTap: () => Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => ProviderListScreen(service: cat.name),
//                 ),
//               ),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF1F5F9),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(cat.icon, size: 34, color: AppColors.darkBg),
//                     const SizedBox(height: 10),
//                     Text(
//                       cat.name,
//                       style: const TextStyle(fontWeight: FontWeight.w600),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
