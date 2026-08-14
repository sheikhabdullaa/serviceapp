// import 'package:flutter/material.dart';
// import 'package:service_hub/sacreens/login%20screen.dart';
// import 'package:service_hub/theme/app_theme.dart';

// class RoleSelectScreen extends StatelessWidget {
//   const RoleSelectScreen({super.key});

//   void _openLoginScreen({
//     required BuildContext context,
//     required String role,
//   }) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => EmailLoginScreen(
//           role: role,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         title: const Text('Choose Your Role'),
//         backgroundColor: AppColors.white,
//         surfaceTintColor: AppColors.white,
//       ),
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//               padding: const EdgeInsets.all(20),
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: constraints.maxHeight - 40,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 12),
//                     const Text(
//                       'How do you want to use KaamSetu?',
//                       style: TextStyle(
//                         color: AppColors.darkBg,
//                         fontSize: 25,
//                         fontWeight: FontWeight.bold,
//                         height: 1.2,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     const Text(
//                       'Choose the option that best describes you.',
//                       style: TextStyle(
//                         color: AppColors.textGrey,
//                         fontSize: 15,
//                         height: 1.4,
//                       ),
//                     ),
//                     const SizedBox(height: 30),

//                     /*
//                      * Normal user:
//                      * Service لینے والا
//                      */
//                     RoleCard(
//                       icon: Icons.person_search_outlined,
//                       title: 'Find a Service',
//                       roleLabel: 'Service Lene Wala',
//                       subtitle:
//                           'Find plumbers, electricians, drivers and other trusted providers.',
//                       buttonLabel: 'Continue as User',
//                       onTap: () {
//                         _openLoginScreen(
//                           context: context,
//                           role: 'user',
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 18),

//                     /*
//                      * Provider:
//                      * Service دینے والا
//                      */
//                     RoleCard(
//                       icon: Icons.handyman_outlined,
//                       title: 'Offer a Service',
//                       roleLabel: 'Service Dene Wala',
//                       subtitle:
//                           'Create your provider profile, offer your skills and get more work.',
//                       buttonLabel: 'Continue as Provider',
//                       onTap: () {
//                         _openLoginScreen(
//                           context: context,
//                           role: 'provider',
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 28),

//                     /*
//                      * Information note
//                      */
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryYellow.withOpacity(0.10),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             color: AppColors.primaryYellow,
//                             size: 22,
//                           ),
//                           SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               'Your selected role will be saved with your account. '
//                               'After login, KaamSetu will open the correct experience automatically.',
//                               style: TextStyle(
//                                 color: AppColors.darkBg,
//                                 fontSize: 13,
//                                 height: 1.4,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
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

// class RoleCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String roleLabel;
//   final String subtitle;
//   final String buttonLabel;
//   final VoidCallback onTap;

//   const RoleCard({
//     super.key,
//     required this.icon,
//     required this.title,
//     required this.roleLabel,
//     required this.subtitle,
//     required this.buttonLabel,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(18),
//         child: Ink(
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: const Color(0xFFF8FAFC),
//             borderRadius: BorderRadius.circular(18),
//             border: Border.all(
//               color: const Color(0xFFE2E8F0),
//             ),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 58,
//                     height: 58,
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryYellow,
//                       borderRadius: BorderRadius.circular(
//                         16,
//                       ),
//                     ),
//                     child: Icon(
//                       icon,
//                       color: AppColors.darkBg,
//                       size: 31,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: const TextStyle(
//                             color: AppColors.darkBg,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           roleLabel,
//                           style: const TextStyle(
//                             color: AppColors.primaryYellow,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const Icon(
//                     Icons.chevron_right_rounded,
//                     color: AppColors.textGrey,
//                     size: 28,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 subtitle,
//                 style: const TextStyle(
//                   color: AppColors.textGrey,
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 18),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.darkBg,
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Text(
//                   buttonLabel,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
