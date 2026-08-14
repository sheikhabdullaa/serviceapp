// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:flutter/material.dart';
// // import 'package:service_hub/sacreens/email_register.dart';
// // import 'package:service_hub/sacreens/provider/provider_dashbord.dart';
// // import 'package:service_hub/services/auth_services.dart';

// // import '../../theme/app_theme.dart';
// // import '../../widgets/common_widgets.dart';

// // class EmailLoginScreen extends StatefulWidget {
// //   final String role;

// //   const EmailLoginScreen({
// //     super.key,
// //     required this.role,
// //   });

// //   @override
// //   State<EmailLoginScreen> createState() => _EmailLoginScreenState();
// // }

// // class _EmailLoginScreenState extends State<EmailLoginScreen> {
// //   final _formKey = GlobalKey<FormState>();

// //   final _emailController = TextEditingController();
// //   final _passwordController = TextEditingController();

// //   bool _loading = false;
// //   bool _obscurePassword = true;
// //   String? _error;

// //   Future<void> _login() async {
// //     if (_loading) return;

// //     FocusScope.of(context).unfocus();

// //     if (!_formKey.currentState!.validate()) return;

// //     final email = _emailController.text.trim().toLowerCase();
// //     final password = _passwordController.text.trim();

// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });

// //     String? savedRole;

// //     try {
// //       // Firebase Authentication login.
// //       await AuthService.instance.loginWithEmailPassword(
// //         email: email,
// //         password: password,
// //       );

// //       // Firestore users document se role load hoga.
// //       savedRole = await AuthService.instance.getCurrentUserRole();
// //     } on FirebaseAuthException catch (e) {
// //       if (!mounted) return;

// //       if (e.code == 'email-not-verified') {
// //         await _showEmailNotVerifiedDialog(
// //           email: email,
// //           password: password,
// //         );
// //       } else {
// //         setState(() {
// //           _error = _getFirebaseError(e);
// //         });
// //       }

// //       return;
// //     } catch (e) {
// //       if (!mounted) return;

// //       setState(() {
// //         _error = 'Login failed: $e';
// //       });

// //       return;
// //     } finally {
// //       if (mounted) {
// //         setState(() => _loading = false);
// //       }
// //     }

// //     // ignore: unnecessary_null_comparison
// //     if (!mounted || savedRole == null) return;

// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(
// //         content: Text('Login successful'),
// //         backgroundColor: Colors.green,
// //       ),
// //     );

// //     if (savedRole == 'provider') {
// //       Navigator.of(context).pushAndRemoveUntil(
// //         MaterialPageRoute(
// //           builder: (_) => const ProviderDashboardScreen(),
// //         ),
// //         (route) => false,
// //       );
// //     } else {
// //       /*
// //        * Yahan apni user home screen open karein.
// //        *
// //        * Example:
// //        *
// //        * Navigator.of(context).pushAndRemoveUntil(
// //        *   MaterialPageRoute(
// //        *     builder: (_) => const UserHomeScreen(),
// //        *   ),
// //        *   (route) => false,
// //        * );
// //        */

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text(
// //             'User login successful. Add your UserHomeScreen here.',
// //           ),
// //         ),
// //       );
// //     }
// //   }

// //   Future<void> _showEmailNotVerifiedDialog({
// //     required String email,
// //     required String password,
// //   }) async {
// //     await showDialog<void>(
// //       context: context,
// //       builder: (dialogContext) {
// //         bool sendingLink = false;
// //         String? dialogError;

// //         return StatefulBuilder(
// //           builder: (context, setDialogState) {
// //             return AlertDialog(
// //               title: const Text('Email Not Verified'),
// //               content: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Please verify your email before logging in.\n\n'
// //                     'Verification link was sent to:\n$email',
// //                   ),
// //                   if (dialogError != null) ...[
// //                     const SizedBox(height: 12),
// //                     Text(
// //                       dialogError!,
// //                       style: const TextStyle(
// //                         color: AppColors.danger,
// //                       ),
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //               actions: [
// //                 TextButton(
// //                   onPressed: sendingLink
// //                       ? null
// //                       : () {
// //                           Navigator.of(
// //                             dialogContext,
// //                           ).pop();
// //                         },
// //                   child: const Text('Close'),
// //                 ),
// //                 TextButton(
// //                   onPressed: sendingLink
// //                       ? null
// //                       : () async {
// //                           setDialogState(() {
// //                             sendingLink = true;
// //                             dialogError = null;
// //                           });

// //                           try {
// //                             await AuthService.instance.resendVerificationEmail(
// //                               email: email,
// //                               password: password,
// //                             );

// //                             if (!dialogContext.mounted) {
// //                               return;
// //                             }

// //                             Navigator.of(
// //                               dialogContext,
// //                             ).pop();

// //                             ScaffoldMessenger.of(
// //                               this.context,
// //                             ).showSnackBar(
// //                               const SnackBar(
// //                                 content: Text(
// //                                   'Verification link sent. '
// //                                   'Please check Inbox and Spam folder.',
// //                                 ),
// //                                 backgroundColor: Colors.green,
// //                               ),
// //                             );
// //                           } on FirebaseAuthException catch (e) {
// //                             if (!dialogContext.mounted) {
// //                               return;
// //                             }

// //                             setDialogState(() {
// //                               sendingLink = false;
// //                               dialogError = _getFirebaseError(e);
// //                             });
// //                           } catch (e) {
// //                             if (!dialogContext.mounted) {
// //                               return;
// //                             }

// //                             setDialogState(() {
// //                               sendingLink = false;
// //                               dialogError = 'Could not send verification link.';
// //                             });
// //                           }
// //                         },
// //                   child: sendingLink
// //                       ? const SizedBox(
// //                           width: 18,
// //                           height: 18,
// //                           child: CircularProgressIndicator(
// //                             strokeWidth: 2,
// //                           ),
// //                         )
// //                       : const Text('Resend Link'),
// //                 ),
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   Future<void> _forgotPassword() async {
// //     if (_loading) return;

// //     FocusScope.of(context).unfocus();

// //     final email = _emailController.text.trim().toLowerCase();

// //     if (email.isEmpty) {
// //       setState(() {
// //         _error = 'Enter your email before pressing Forgot Password.';
// //       });
// //       return;
// //     }

// //     if (!_isValidEmail(email)) {
// //       setState(() {
// //         _error = 'Please enter a valid email address.';
// //       });
// //       return;
// //     }

// //     setState(() {
// //       _loading = true;
// //       _error = null;
// //     });

// //     try {
// //       await AuthService.instance.sendPasswordResetEmail(email);

// //       if (!mounted) return;

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(
// //             'Password reset link sent to $email',
// //           ),
// //           backgroundColor: Colors.green,
// //           duration: const Duration(seconds: 5),
// //         ),
// //       );
// //     } on FirebaseAuthException catch (e) {
// //       if (!mounted) return;

// //       setState(() {
// //         _error = _getFirebaseError(e);
// //       });
// //     } catch (e) {
// //       if (!mounted) return;

// //       setState(() {
// //         _error = 'Could not send password reset link.';
// //       });
// //     } finally {
// //       if (mounted) {
// //         setState(() => _loading = false);
// //       }
// //     }
// //   }

// //   bool _isValidEmail(String email) {
// //     return RegExp(
// //       r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
// //     ).hasMatch(email);
// //   }

// //   String _getFirebaseError(
// //     FirebaseAuthException exception,
// //   ) {
// //     switch (exception.code) {
// //       case 'invalid-email':
// //         return 'Please enter a valid email address.';

// //       case 'user-not-found':
// //       case 'wrong-password':
// //       case 'invalid-credential':
// //         return 'Incorrect email or password.';

// //       case 'email-not-verified':
// //         return 'Please verify your email before logging in.';

// //       case 'email-already-verified':
// //         return 'Your email is already verified. Please login.';

// //       case 'user-disabled':
// //         return 'This account has been disabled.';

// //       case 'network-request-failed':
// //         return 'Please check your internet connection.';

// //       case 'too-many-requests':
// //         return 'Too many attempts. Please try again later.';

// //       case 'operation-not-allowed':
// //         return 'Email/password authentication is not enabled.';

// //       default:
// //         return exception.message ?? 'Firebase operation failed.';
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     _passwordController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: AppColors.white,
// //       appBar: AppBar(
// //         title: const Text('Login'),
// //         backgroundColor: AppColors.white,
// //         surfaceTintColor: AppColors.white,
// //       ),
// //       body: SafeArea(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(24),
// //           child: Form(
// //             key: _formKey,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text(
// //                   'Welcome Back!',
// //                   style: TextStyle(
// //                     fontSize: 26,
// //                     fontWeight: FontWeight.bold,
// //                     color: AppColors.darkBg,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 const Text(
// //                   'Login with your email and password.',
// //                   style: TextStyle(
// //                     color: AppColors.textGrey,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 30),
// //                 TextFormField(
// //                   controller: _emailController,
// //                   keyboardType: TextInputType.emailAddress,
// //                   textInputAction: TextInputAction.next,
// //                   autofillHints: const [
// //                     AutofillHints.email,
// //                   ],
// //                   decoration: const InputDecoration(
// //                     labelText: 'Email Address',
// //                     hintText: 'example@gmail.com',
// //                     prefixIcon: Icon(
// //                       Icons.email_outlined,
// //                     ),
// //                   ),
// //                   validator: (value) {
// //                     final email = value?.trim().toLowerCase() ?? '';

// //                     if (email.isEmpty) {
// //                       return 'Please enter your email';
// //                     }

// //                     if (!_isValidEmail(email)) {
// //                       return 'Please enter a valid email';
// //                     }

// //                     return null;
// //                   },
// //                 ),
// //                 const SizedBox(height: 18),
// //                 TextFormField(
// //                   controller: _passwordController,
// //                   obscureText: _obscurePassword,
// //                   textInputAction: TextInputAction.done,
// //                   autofillHints: const [
// //                     AutofillHints.password,
// //                   ],
// //                   decoration: InputDecoration(
// //                     labelText: 'Password',
// //                     hintText: 'Enter your password',
// //                     prefixIcon: const Icon(
// //                       Icons.lock_outline,
// //                     ),
// //                     suffixIcon: IconButton(
// //                       icon: Icon(
// //                         _obscurePassword
// //                             ? Icons.visibility_off_outlined
// //                             : Icons.visibility_outlined,
// //                       ),
// //                       onPressed: () {
// //                         setState(() {
// //                           _obscurePassword = !_obscurePassword;
// //                         });
// //                       },
// //                     ),
// //                   ),
// //                   onFieldSubmitted: (_) {
// //                     _login();
// //                   },
// //                   validator: (value) {
// //                     final password = value?.trim() ?? '';

// //                     if (password.isEmpty) {
// //                       return 'Please enter your password';
// //                     }

// //                     if (password.length < 6) {
// //                       return 'Password must be at least 6 characters';
// //                     }

// //                     return null;
// //                   },
// //                 ),
// //                 Align(
// //                   alignment: Alignment.centerRight,
// //                   child: TextButton(
// //                     onPressed: _loading ? null : _forgotPassword,
// //                     child: const Text('Forgot Password?'),
// //                   ),
// //                 ),
// //                 if (_error != null) ...[
// //                   Container(
// //                     width: double.infinity,
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       // ignore: deprecated_member_use
// //                       color: AppColors.danger.withOpacity(0.08),
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                     child: Text(
// //                       _error!,
// //                       style: const TextStyle(
// //                         color: AppColors.danger,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                 ] else
// //                   const SizedBox(height: 10),
// //                 PrimaryButton(
// //                   label: 'Login',
// //                   onPressed: _login,
// //                   loading: _loading,
// //                 ),
// //                 const SizedBox(height: 22),
// //                 Center(
// //                   child: GestureDetector(
// //                     onTap: _loading
// //                         ? null
// //                         : () {
// //                             Navigator.of(context).push(
// //                               MaterialPageRoute(
// //                                 builder: (_) => EmailRegisterScreen(
// //                                   role: widget.role,
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                     child: RichText(
// //                       text: const TextSpan(
// //                         style: TextStyle(
// //                           color: AppColors.darkBg,
// //                         ),
// //                         children: [
// //                           TextSpan(
// //                             text: "Don't have an account? ",
// //                           ),
// //                           TextSpan(
// //                             text: 'Create Account',
// //                             style: TextStyle(
// //                               color: AppColors.primaryYellow,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:service_hub/sacreens/auth/link_sent_screen.dart';
// import 'package:service_hub/sacreens/email_register.dart';
// import 'package:service_hub/sacreens/provider/provider_dashbord.dart';
// import 'package:service_hub/services/auth_services.dart';
// import 'package:service_hub/theme/app_theme.dart';
// import 'package:service_hub/user/select_service.dart';

// class EmailLoginScreen extends StatefulWidget {
//   final String role;

//   const EmailLoginScreen({
//     super.key,
//     required this.role,
//   });

//   @override
//   State<EmailLoginScreen> createState() => _EmailLoginScreenState();
// }

// class _EmailLoginScreenState extends State<EmailLoginScreen> {
//   final _formKey = GlobalKey<FormState>();

//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   bool _loading = false;
//   bool _obscurePassword = true;
//   String? _error;

//   bool _isValidEmail(String email) {
//     return RegExp(
//       r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
//     ).hasMatch(email);
//   }

//   Future<void> _login() async {
//     if (_loading) return;

//     FocusScope.of(context).unfocus();

//     if (!_formKey.currentState!.validate()) return;

//     final email = _emailController.text.trim().toLowerCase();

//     // Password کو trim نہ کریں۔
//     final password = _passwordController.text;

//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       final credential = await AuthService.instance.loginWithEmailPassword(
//         email: email,
//         password: password,
//       );

//       final user = credential.user;

//       if (user == null) {
//         throw FirebaseAuthException(
//           code: 'user-not-found',
//           message: 'Account not found.',
//         );
//       }

//       await user.reload();

//       final refreshedUser = FirebaseAuth.instance.currentUser;

//       if (refreshedUser?.emailVerified != true) {
//         if (!mounted) return;

//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(
//             builder: (_) => LinkSentScreen(
//               email: email,
//               role: widget.role,
//             ),
//           ),
//         );

//         return;
//       }

//       final savedRole = await AuthService.instance.getCurrentUserRole();

//       if (!mounted) return;

//       if (savedRole == null) {
//         setState(() {
//           _error = 'Account exists, but Firestore profile was not found.';
//         });
//         return;
//       }

//       if (savedRole == 'provider') {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(
//             builder: (_) => const ProviderDashboardScreen(),
//           ),
//           (route) => false,
//         );
//       } else {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(
//             builder: (_) => const SelectServiceScreen(),
//           ),
//           (route) => false,
//         );
//       }
//     } on FirebaseAuthException catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _error = _getFirebaseError(e);
//       });
//     } catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _error = 'Login failed: $e';
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   Future<void> _forgotPassword() async {
//     if (_loading) return;

//     final email = _emailController.text.trim().toLowerCase();

//     if (email.isEmpty || !_isValidEmail(email)) {
//       setState(() {
//         _error = 'Enter your correct email, then press Forgot Password.';
//       });
//       return;
//     }

//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       await AuthService.instance.sendPasswordResetEmail(email);

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Password reset email sent to $email',
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } on FirebaseAuthException catch (e) {
//       if (!mounted) return;

//       setState(() {
//         _error = _getFirebaseError(e);
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _loading = false);
//       }
//     }
//   }

//   String _getFirebaseError(FirebaseAuthException e) {
//     switch (e.code) {
//       case 'invalid-email':
//         return 'Please enter a valid email address.';

//       case 'invalid-credential':
//       case 'wrong-password':
//       case 'user-not-found':
//         return 'Email or password is incorrect.';

//       case 'user-disabled':
//         return 'This account has been disabled.';

//       case 'network-request-failed':
//         return 'Please check your internet connection.';

//       case 'too-many-requests':
//         return 'Too many login attempts. Try again later.';

//       case 'operation-not-allowed':
//         return 'Enable Email/Password authentication in Firebase Console.';

//       default:
//         return e.message ?? 'Could not login.';
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         title: const Text('Login'),
//         backgroundColor: AppColors.white,
//         surfaceTintColor: AppColors.white,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Welcome Back!',
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.darkBg,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 const Text(
//                   'Enter the email and password used during registration.',
//                   style: TextStyle(
//                     color: AppColors.textGrey,
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   textInputAction: TextInputAction.next,
//                   autofillHints: const [
//                     AutofillHints.email,
//                   ],
//                   decoration: const InputDecoration(
//                     labelText: 'Email Address',
//                     hintText: 'example@gmail.com',
//                     prefixIcon: Icon(Icons.email_outlined),
//                   ),
//                   validator: (value) {
//                     final email = value?.trim().toLowerCase() ?? '';

//                     if (email.isEmpty) {
//                       return 'Please enter your email';
//                     }

//                     if (!_isValidEmail(email)) {
//                       return 'Please enter a valid email';
//                     }

//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 18),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   textInputAction: TextInputAction.done,
//                   autofillHints: const [
//                     AutofillHints.password,
//                   ],
//                   onFieldSubmitted: (_) => _login(),
//                   decoration: InputDecoration(
//                     labelText: 'Password',
//                     hintText: 'Enter your password',
//                     prefixIcon: const Icon(Icons.lock_outline),
//                     suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off_outlined
//                             : Icons.visibility_outlined,
//                       ),
//                     ),
//                   ),
//                   validator: (value) {
//                     final password = value ?? '';

//                     if (password.isEmpty) {
//                       return 'Please enter your password';
//                     }

//                     if (password.length < 6) {
//                       return 'Password must contain at least 6 characters';
//                     }

//                     return null;
//                   },
//                 ),
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: _loading ? null : _forgotPassword,
//                     child: const Text('Forgot Password?'),
//                   ),
//                 ),
//                 if (_error != null) ...[
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: AppColors.danger.withOpacity(0.08),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       _error!,
//                       style: const TextStyle(
//                         color: AppColors.danger,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 18),
//                 ],
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: _loading ? null : _login,
//                     child: _loading
//                         ? const SizedBox(
//                             width: 22,
//                             height: 22,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : const Text('Login'),
//                   ),
//                 ),
//                 const SizedBox(height: 18),
//                 Center(
//                   child: TextButton(
//                     onPressed: _loading
//                         ? null
//                         : () {
//                             Navigator.of(context).push(
//                               MaterialPageRoute(
//                                 builder: (_) => EmailRegisterScreen(
//                                   role: widget.role,
//                                 ),
//                               ),
//                             );
//                           },
//                     child: const Text(
//                       "Don't have an account? Create Account",
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
