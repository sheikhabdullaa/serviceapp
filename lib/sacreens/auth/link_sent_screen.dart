// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import 'package:service_hub/sacreens/auth/complete_profle.dart';
// import 'package:service_hub/sacreens/provider/provider_dashbord.dart';
// import 'package:service_hub/sacreens/role_selection.dart';
// import 'package:service_hub/services/auth_services.dart';
// import 'package:service_hub/theme/app_theme.dart';
// import 'package:service_hub/user/select_service.dart';

// class LinkSentScreen extends StatefulWidget {
//   final String email;
//   final String role;

//   const LinkSentScreen({
//     super.key,
//     required this.email,
//     required this.role,
//   });

//   @override
//   State<LinkSentScreen> createState() => _LinkSentScreenState();
// }

// class _LinkSentScreenState extends State<LinkSentScreen>
//     with WidgetsBindingObserver {
//   bool _checking = false;
//   bool _resending = false;
//   bool _success = false;
//   String? _message;

//   bool get _busy => _checking || _resending;

//   @override
//   void initState() {
//     super.initState();

//     /*
//      * User Gmail/browser سے app میں واپس آئے تو
//      * verification status automatically check ہوگا۔
//      */
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void didChangeAppLifecycleState(
//     AppLifecycleState state,
//   ) {
//     super.didChangeAppLifecycleState(state);

//     if (state == AppLifecycleState.resumed && !_busy) {
//       _checkVerification(showUnverifiedMessage: false);
//     }
//   }

//   Future<void> _checkVerification({
//     bool showUnverifiedMessage = true,
//   }) async {
//     if (_busy) return;

//     setState(() {
//       _checking = true;
//       _message = null;
//       _success = false;
//     });

//     try {
//       final bool verified = await AuthService.instance.checkEmailVerification();

//       if (!mounted) return;

//       if (!verified) {
//         if (showUnverifiedMessage) {
//           setState(() {
//             _success = false;
//             _message =
//                 'Email is not verified yet. Open Gmail and tap the verification link.';
//           });
//         }

//         return;
//       }

//       /*
//        * Screen کو دیا ہوا widget.role استعمال کرکے
//        * dashboard decide نہیں ہوگا۔
//        *
//        * اصل role Firestore users/{uid} سے آئے گا۔
//        */
//       final String? savedRole = await AuthService.instance.getCurrentUserRole();

//       if (!mounted) return;

//       if (savedRole == null) {
//         setState(() {
//           _success = false;
//           _message =
//               'Email is verified, but your Firestore account profile was not found.';
//         });
//         return;
//       }

//       final User? currentUser = AuthService.instance.currentUser;

//       if (currentUser == null) {
//         setState(() {
//           _success = false;
//           _message = 'Your session has expired. Please login again.';
//         });
//         return;
//       }

//       setState(() {
//         _success = true;
//         _message = 'Email verified successfully.';
//       });

//       /*
//        * Normal user flow
//        */
//       if (savedRole == 'user') {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(
//             builder: (_) => const SelectServiceScreen(),
//           ),
//           (route) => false,
//         );

//         return;
//       }

//       /*
//        * Provider flow
//        */
//       if (savedRole == 'provider') {
//         final bool profileCompleted =
//             await AuthService.instance.isCurrentUserProfileCompleted();

//         if (!mounted) return;

//         if (profileCompleted) {
//           Navigator.of(context).pushAndRemoveUntil(
//             MaterialPageRoute(
//               builder: (_) => const ProviderDashboardScreen(),
//             ),
//             (route) => false,
//           );

//           return;
//         }

//         /*
//          * نئے provider نے ابھی name, WhatsApp,
//          * service اور CNIC details نہیں دیں۔
//          */
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(
//             builder: (_) => CompleteProfileScreen(
//               firebaseUser: currentUser,
//               role: 'provider',
//             ),
//           ),
//           (route) => false,
//         );

//         return;
//       }

//       setState(() {
//         _success = false;
//         _message = 'Invalid account role found: $savedRole';
//       });
//     } on FirebaseAuthException catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _success = false;
//         _message = _firebaseErrorMessage(error);
//       });
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _success = false;
//         _message = 'Could not check email verification. Please try again.';
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           _checking = false;
//         });
//       }
//     }
//   }

//   Future<void> _resendLink() async {
//     if (_busy) return;

//     setState(() {
//       _resending = true;
//       _message = null;
//       _success = false;
//     });

//     try {
//       await AuthService.instance.resendVerificationEmail();

//       if (!mounted) return;

//       setState(() {
//         _success = true;
//         _message =
//             'A new verification email has been sent. Check Inbox, Spam and Promotions.';
//       });
//     } on FirebaseAuthException catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _success = false;
//         _message = _firebaseErrorMessage(error);
//       });
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _success = false;
//         _message = 'Could not resend the verification email.';
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           _resending = false;
//         });
//       }
//     }
//   }

//   Future<void> _backToLogin() async {
//     if (_busy) return;

//     setState(() {
//       _checking = true;
//       _message = null;
//     });

//     try {
//       await AuthService.instance.signOut();

//       if (!mounted) return;

//       /*
//        * پہلے role select ہوگا، پھر اسی role کی
//        * login screen کھلے گی۔
//        */
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (_) => const RoleSelectScreen(),
//         ),
//         (route) => false,
//       );
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _checking = false;
//         _success = false;
//         _message = 'Could not logout. Please try again.';
//       });
//     }
//   }

//   String _firebaseErrorMessage(
//     FirebaseAuthException error,
//   ) {
//     switch (error.code) {
//       case 'no-current-user':
//         return 'Your login session has expired. Please login again.';

//       case 'email-already-verified':
//         return 'Your email is already verified. Press the verification button to continue.';

//       case 'too-many-requests':
//         return 'Too many requests. Wait a few minutes before trying again.';

//       case 'network-request-failed':
//         return 'Please check your internet connection.';

//       case 'user-disabled':
//         return 'This account has been disabled.';

//       default:
//         return error.message ?? 'Could not complete this operation.';
//     }
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String roleName =
//         widget.role.trim().toLowerCase() == 'provider' ? 'Provider' : 'User';

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('Verify Email'),
//         backgroundColor: AppColors.white,
//         surfaceTintColor: AppColors.white,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(28),
//           child: Column(
//             children: [
//               const SizedBox(height: 35),

//               /*
//                * Email icon
//                */
//               Container(
//                 width: 88,
//                 height: 88,
//                 decoration: const BoxDecoration(
//                   color: AppColors.success,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.mark_email_unread_outlined,
//                   color: Colors.white,
//                   size: 44,
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text(
//                 'Check your Gmail',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.darkBg,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 '$roleName account verification',
//                 style: const TextStyle(
//                   color: AppColors.primaryYellow,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 14),
//               Text(
//                 'We sent an email verification link to:',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   color: AppColors.textGrey,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 8),

//               /*
//                * User email
//                */
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 12,
//                 ),
//                 decoration: BoxDecoration(
//                   // ignore: deprecated_member_use
//                   color: AppColors.primaryYellow.withOpacity(0.10),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   widget.email,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     color: AppColors.darkBg,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Open Gmail and tap the verification link. '
//                 'Then return to Service Hub and press the button below.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: AppColors.textGrey,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 20),

//               /*
//                * Spam information
//                */
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFF7E0),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: const Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Icon(
//                       Icons.info_outline,
//                       color: AppColors.primaryYellow,
//                     ),
//                     SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         'If you cannot find the email, check your Spam and Promotions folders.',
//                         style: TextStyle(
//                           fontSize: 13,
//                           height: 1.4,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               /*
//                * Success/error message
//                */
//               if (_message != null) ...[
//                 const SizedBox(height: 18),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: (_success ? Colors.green : AppColors.danger)
//                         .withOpacity(0.08),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(
//                         _success
//                             ? Icons.check_circle_outline
//                             : Icons.error_outline,
//                         color: _success ? Colors.green : AppColors.danger,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Text(
//                           _message!,
//                           style: TextStyle(
//                             color: _success ? Colors.green : AppColors.danger,
//                             fontWeight: FontWeight.w500,
//                             height: 1.4,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 28),

//               /*
//                * Verification check button
//                */
//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton(
//                   onPressed: _busy
//                       ? null
//                       : () {
//                           _checkVerification();
//                         },
//                   child: _checking
//                       ? const SizedBox(
//                           width: 22,
//                           height: 22,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text(
//                           'I Have Verified My Email',
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               /*
//                * Resend email
//                */
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: OutlinedButton(
//                   onPressed: _busy ? null : _resendLink,
//                   child: _resending
//                       ? const SizedBox(
//                           width: 20,
//                           height: 20,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : const Text(
//                           'Resend Verification Email',
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 10),

//               /*
//                * Logout and return
//                */
//               TextButton(
//                 onPressed: _busy ? null : _backToLogin,
//                 child: const Text(
//                   'Use Another Account',
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
