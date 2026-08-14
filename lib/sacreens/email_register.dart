// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import 'package:service_hub/sacreens/auth/link_sent_screen.dart';
// import 'package:service_hub/services/auth_services.dart';
// import 'package:service_hub/theme/app_theme.dart';

// class EmailRegisterScreen extends StatefulWidget {
//   final String role;

//   const EmailRegisterScreen({
//     super.key,
//     required this.role,
//   });

//   @override
//   State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
// }

// class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _emailController = TextEditingController();

//   final TextEditingController _passwordController = TextEditingController();

//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   bool _loading = false;
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   String? _error;

//   String get _normalizedRole => widget.role.trim().toLowerCase();

//   bool get _isProvider => _normalizedRole == 'provider';

//   bool _isValidEmail(String email) {
//     return RegExp(
//       r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
//     ).hasMatch(email);
//   }

//   Future<void> _createAccount() async {
//     if (_loading) return;

//     FocusManager.instance.primaryFocus?.unfocus();

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_normalizedRole != 'user' && _normalizedRole != 'provider') {
//       setState(() {
//         _error = 'Invalid role. Please go back and select User or Provider.';
//       });
//       return;
//     }

//     final String email = _emailController.text.trim().toLowerCase();

//     /*
//      * Password کو trim نہیں کرنا۔
//      * Signup اور login دونوں میں exact same password
//      * Firebase کو جانا چاہیے۔
//      */
//     final String password = _passwordController.text;

//     setState(() {
//       _loading = true;
//       _error = null;
//     });

//     try {
//       await AuthService.instance.registerWithEmailPassword(
//         email: email,
//         password: password,
//         role: _normalizedRole,
//       );

//       if (!mounted) return;

//       /*
//        * Account create ہونے کے بعد Firebase user login
//        * رہتا ہے، اس لیے LinkSentScreen verification
//        * status check اور resend link کر سکتی ہے۔
//        */
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (_) => LinkSentScreen(
//             email: email,
//             role: _normalizedRole,
//           ),
//         ),
//       );
//     } on FirebaseAuthException catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _error = _firebaseErrorMessage(error);
//       });
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _error = 'Could not create your account. Please try again.';
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           _loading = false;
//         });
//       }
//     }
//   }

//   String _firebaseErrorMessage(
//     FirebaseAuthException error,
//   ) {
//     switch (error.code) {
//       case 'email-already-in-use':
//         return 'This email is already registered. Please login or use Forgot Password.';

//       case 'invalid-email':
//         return 'Please enter a valid email address.';

//       case 'weak-password':
//         return 'Password must contain at least 6 characters.';

//       case 'operation-not-allowed':
//         return 'Email/Password authentication is not enabled in Firebase Console.';

//       case 'network-request-failed':
//         return 'Please check your internet connection.';

//       case 'too-many-requests':
//         return 'Too many attempts. Please wait and try again later.';

//       case 'permission-denied':
//         return 'Firestore permission denied. Please check Firestore security rules.';

//       case 'invalid-role':
//         return 'Please select User or Provider role.';

//       case 'user-creation-failed':
//         return 'Firebase could not create this account.';

//       case 'registration-failed':
//         return error.message ?? 'Could not complete registration.';

//       default:
//         return error.message ?? 'Could not create your account.';
//     }
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String roleTitle = _isProvider ? 'Provider' : 'User';

//     return Scaffold(
//       backgroundColor: AppColors.white,
//       appBar: AppBar(
//         title: const Text('Create Account'),
//         backgroundColor: AppColors.white,
//         surfaceTintColor: AppColors.white,
//       ),
//       body: SafeArea(
//         child: AutofillGroup(
//           child: SingleChildScrollView(
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Create your account',
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: AppColors.darkBg,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Registering as $roleTitle',
//                     style: const TextStyle(
//                       color: AppColors.textGrey,
//                       fontSize: 15,
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   /*
//                    * Role indicator
//                    */
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 14,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       // ignore: deprecated_member_use
//                       color: AppColors.primaryYellow.withOpacity(0.12),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           _isProvider
//                               ? Icons.engineering_outlined
//                               : Icons.person_outline,
//                           color: AppColors.primaryYellow,
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           '$roleTitle Account',
//                           style: const TextStyle(
//                             color: AppColors.darkBg,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 28),

//                   /*
//                    * Email
//                    */
//                   TextFormField(
//                     controller: _emailController,
//                     enabled: !_loading,
//                     keyboardType: TextInputType.emailAddress,
//                     textInputAction: TextInputAction.next,
//                     autofillHints: const [
//                       AutofillHints.email,
//                     ],
//                     autocorrect: false,
//                     enableSuggestions: false,
//                     decoration: const InputDecoration(
//                       labelText: 'Email Address',
//                       hintText: 'example@gmail.com',
//                       prefixIcon: Icon(Icons.email_outlined),
//                     ),
//                     validator: (value) {
//                       final email = value?.trim().toLowerCase() ?? '';

//                       if (email.isEmpty) {
//                         return 'Please enter your email';
//                       }

//                       if (!_isValidEmail(email)) {
//                         return 'Please enter a valid email address';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 18),

//                   /*
//                    * Password
//                    */
//                   TextFormField(
//                     controller: _passwordController,
//                     enabled: !_loading,
//                     obscureText: _obscurePassword,
//                     textInputAction: TextInputAction.next,
//                     autofillHints: const [
//                       AutofillHints.newPassword,
//                     ],
//                     autocorrect: false,
//                     enableSuggestions: false,
//                     decoration: InputDecoration(
//                       labelText: 'Password',
//                       hintText: 'Minimum 6 characters',
//                       prefixIcon: const Icon(
//                         Icons.lock_outline,
//                       ),
//                       suffixIcon: IconButton(
//                         onPressed: _loading
//                             ? null
//                             : () {
//                                 setState(() {
//                                   _obscurePassword = !_obscurePassword;
//                                 });
//                               },
//                         icon: Icon(
//                           _obscurePassword
//                               ? Icons.visibility_off_outlined
//                               : Icons.visibility_outlined,
//                         ),
//                       ),
//                     ),
//                     validator: (value) {
//                       final password = value ?? '';

//                       if (password.isEmpty) {
//                         return 'Please enter a password';
//                       }

//                       if (password.length < 6) {
//                         return 'Password must be at least 6 characters';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 18),

//                   /*
//                    * Confirm Password
//                    */
//                   TextFormField(
//                     controller: _confirmPasswordController,
//                     enabled: !_loading,
//                     obscureText: _obscureConfirmPassword,
//                     textInputAction: TextInputAction.done,
//                     autofillHints: const [
//                       AutofillHints.newPassword,
//                     ],
//                     autocorrect: false,
//                     enableSuggestions: false,
//                     onFieldSubmitted: (_) {
//                       _createAccount();
//                     },
//                     decoration: InputDecoration(
//                       labelText: 'Confirm Password',
//                       hintText: 'Enter the same password',
//                       prefixIcon: const Icon(
//                         Icons.lock_outline,
//                       ),
//                       suffixIcon: IconButton(
//                         onPressed: _loading
//                             ? null
//                             : () {
//                                 setState(() {
//                                   _obscureConfirmPassword =
//                                       !_obscureConfirmPassword;
//                                 });
//                               },
//                         icon: Icon(
//                           _obscureConfirmPassword
//                               ? Icons.visibility_off_outlined
//                               : Icons.visibility_outlined,
//                         ),
//                       ),
//                     ),
//                     validator: (value) {
//                       final confirmPassword = value ?? '';

//                       if (confirmPassword.isEmpty) {
//                         return 'Please confirm your password';
//                       }

//                       if (confirmPassword != _passwordController.text) {
//                         return 'Passwords do not match';
//                       }

//                       return null;
//                     },
//                   ),

//                   /*
//                    * Firebase error
//                    */
//                   if (_error != null) ...[
//                     const SizedBox(height: 16),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         // ignore: deprecated_member_use
//                         color: AppColors.danger.withOpacity(0.08),
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           // ignore: deprecated_member_use
//                           color: AppColors.danger.withOpacity(0.20),
//                         ),
//                       ),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Icon(
//                             Icons.error_outline,
//                             color: AppColors.danger,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Text(
//                               _error!,
//                               style: const TextStyle(
//                                 color: AppColors.danger,
//                                 height: 1.4,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 26),

//                   /*
//                    * Create account button
//                    */
//                   SizedBox(
//                     width: double.infinity,
//                     height: 52,
//                     child: ElevatedButton(
//                       onPressed: _loading ? null : _createAccount,
//                       child: _loading
//                           ? const SizedBox(
//                               width: 22,
//                               height: 22,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                               ),
//                             )
//                           : const Text(
//                               'Create Account',
//                             ),
//                     ),
//                   ),
//                   const SizedBox(height: 18),

//                   /*
//                    * Existing account
//                    */
//                   Center(
//                     child: TextButton(
//                       onPressed: _loading
//                           ? null
//                           : () {
//                               Navigator.of(context).pop();
//                             },
//                       child: const Text(
//                         'Already have an account? Login',
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
