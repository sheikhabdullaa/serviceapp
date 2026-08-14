// import 'package:flutter/material.dart';

// import 'package:service_hub/sacreens/role_selection.dart';
// import 'package:service_hub/theme/app_theme.dart';
// import 'package:service_hub/widgets/common_widgets.dart';

// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});

//   void _openRoleSelection(
//     BuildContext context,
//   ) {
//     Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (_) => const RoleSelectScreen(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.darkBg,
//       body: SafeArea(
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             return SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   minHeight: constraints.maxHeight,
//                 ),
//                 child: IntrinsicHeight(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 28,
//                       vertical: 24,
//                     ),
//                     child: Column(
//                       children: [
//                         const Spacer(flex: 2),

//                         /*
//                          * KaamSetu logo
//                          */
//                         Container(
//                           width: 104,
//                           height: 104,
//                           decoration: BoxDecoration(
//                             color: AppColors.primaryYellow,
//                             shape: BoxShape.circle,
//                             boxShadow: [
//                               BoxShadow(
//                                 color:
//                                     // ignore: deprecated_member_use
//                                     AppColors.primaryYellow.withOpacity(0.25),
//                                 blurRadius: 30,
//                                 spreadRadius: 4,
//                               ),
//                             ],
//                           ),
//                           child: const Icon(
//                             Icons.engineering,
//                             size: 56,
//                             color: AppColors.darkBg,
//                           ),
//                         ),
//                         const SizedBox(height: 22),

//                         /*
//                          * App name
//                          */
//                         RichText(
//                           textAlign: TextAlign.center,
//                           text: const TextSpan(
//                             style: TextStyle(
//                               fontSize: 32,
//                               fontWeight: FontWeight.bold,
//                             ),
//                             children: [
//                               TextSpan(
//                                 text: 'Kaam',
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: 'Setu',
//                                 style: TextStyle(
//                                   color: AppColors.primaryYellow,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           'Har Kaam, Aasan.',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: AppColors.primaryYellow,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 22),
//                         const Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 10,
//                           ),
//                           child: Text(
//                             'Connect with trusted service providers '
//                             'or offer your skills and grow your work.',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: AppColors.white,
//                               fontSize: 15,
//                               height: 1.5,
//                             ),
//                           ),
//                         ),
//                         const Spacer(flex: 3),

//                         /*
//                          * Role selection screen
//                          */
//                         PrimaryButton(
//                           label: 'Get Started',
//                           onPressed: () {
//                             _openRoleSelection(
//                               context,
//                             );
//                           },
//                         ),
//                         const SizedBox(height: 14),

//                         /*
//                          * Existing users بھی role select کرکے
//                          * اپنی login screen پر جائیں گے۔
//                          */
//                         TextButton(
//                           onPressed: () {
//                             _openRoleSelection(
//                               context,
//                             );
//                           },
//                           child: const Text(
//                             'Already have an account? Login',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 12),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
