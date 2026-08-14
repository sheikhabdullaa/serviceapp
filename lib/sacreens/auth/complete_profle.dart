// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import 'package:service_hub/model/model.dart';
// import 'package:service_hub/sacreens/provider/provider_dashbord.dart';
// import 'package:service_hub/services/fire_Store_services.dart';
// import 'package:service_hub/theme/app_theme.dart';
// import 'package:service_hub/user/select_service.dart';
// import 'package:service_hub/widgets/common_widgets.dart';

// class CompleteProfileScreen extends StatefulWidget {
//   final User firebaseUser;
//   final String role;

//   const CompleteProfileScreen({
//     super.key,
//     required this.firebaseUser,
//     required this.role,
//   });

//   @override
//   State<CompleteProfileScreen> createState() =>
//       _CompleteProfileScreenState();
// }

// class _CompleteProfileScreenState
//     extends State<CompleteProfileScreen> {
//   final GlobalKey<FormState> _formKey =
//       GlobalKey<FormState>();

//   final TextEditingController _nameController =
//       TextEditingController();

//   final TextEditingController _whatsappController =
//       TextEditingController();

//   final TextEditingController _idCardController =
//       TextEditingController();

//   final TextEditingController _aboutController =
//       TextEditingController();

//   late String _selectedService;

//   bool _saving = false;
//   bool _loadingProfile = true;
//   String? _error;

//   String get _normalizedRole =>
//       widget.role.trim().toLowerCase();

//   bool get isProvider =>
//       _normalizedRole == 'provider';

//   @override
//   void initState() {
//     super.initState();

//     _selectedService =
//         kServiceCategories.first.name;

//     _loadExistingInformation();
//   }

//   /// اگر user نے پہلے کچھ information save کی ہو تو
//   /// fields میں واپس دکھائیں۔
//   Future<void> _loadExistingInformation() async {
//     try {
//       final AppUser? appUser =
//           await FirestoreService.instance
//               .getUser(widget.firebaseUser.uid);

//       if (appUser != null) {
//         _nameController.text = appUser.name;
//         _whatsappController.text =
//             appUser.whatsapp;
//       }

//       if (isProvider) {
//         final ProviderProfile? provider =
//             await FirestoreService.instance
//                 .getProvider(widget.firebaseUser.uid);

//         if (provider != null) {
//           if (_nameController.text.trim().isEmpty) {
//             _nameController.text = provider.name;
//           }

//           if (_whatsappController.text
//               .trim()
//               .isEmpty) {
//             _whatsappController.text =
//                 provider.whatsapp;
//           }

//           _idCardController.text =
//               provider.idCardNumber;

//           _aboutController.text =
//               provider.about;

//           final serviceExists =
//               kServiceCategories.any(
//             (category) =>
//                 category.name == provider.service,
//           );

//           if (serviceExists) {
//             _selectedService =
//                 provider.service;
//           }
//         }
//       }
//     } catch (error) {
//       _error =
//           'Could not load existing profile information.';
//     } finally {
//       if (mounted) {
//         setState(() {
//           _loadingProfile = false;
//         });
//       }
//     }
//   }

//   bool _isValidWhatsAppNumber(String value) {
//     /*
//      * Spaces, brackets اور hyphens remove کرکے
//      * صرف phone digits check ہوں گے۔
//      */
//     final cleanedNumber = value.replaceAll(
//       RegExp(r'[\s\-\(\)]'),
//       '',
//     );

//     return RegExp(
//       r'^\+?[0-9]{8,15}$',
//     ).hasMatch(cleanedNumber);
//   }

//   bool _isValidIdCard(String value) {
//     final cleanedId = value.replaceAll(
//       RegExp(r'[\s\-]'),
//       '',
//     );

//     /*
//      * مختلف countries کے ID cards support کرنے
//      * کے لیے letters اور numbers دونوں allowed ہیں۔
//      */
//     return RegExp(
//       r'^[A-Za-z0-9]{5,20}$',
//     ).hasMatch(cleanedId);
//   }

//   Future<void> _saveProfile() async {
//     if (_saving) return;

//     FocusManager.instance.primaryFocus?.unfocus();

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_normalizedRole != 'user' &&
//         _normalizedRole != 'provider') {
//       setState(() {
//         _error =
//             'Invalid account role. Please register again.';
//       });
//       return;
//     }

//     setState(() {
//       _saving = true;
//       _error = null;
//     });

//     final String uid =
//         widget.firebaseUser.uid;

//     final String email =
//         widget.firebaseUser.email
//                 ?.trim()
//                 .toLowerCase() ??
//             '';

//     final String name =
//         _nameController.text.trim();

//     final String whatsapp =
//         _whatsappController.text.trim();

//     try {
//       /*
//        * users/{uid} document پہلے ہی signup کے وقت
//        * بن چکا ہے۔ یہاں صرف profile fields update
//        * ہوں گی، createdAt overwrite نہیں ہوگا۔
//        */
//       await FirestoreService.instance
//           .updateUserFields(
//         uid: uid,
//         data: {
//           'uid': uid,
//           'email': email,
//           'name': name,
//           'whatsapp': whatsapp,
//           'role': _normalizedRole,
//           'emailVerified':
//               widget.firebaseUser.emailVerified,
//         },
//       );

//       if (isProvider) {
//         final ProviderProfile providerProfile =
//             ProviderProfile(
//           uid: uid,
//           name: name,
//           whatsapp: whatsapp,
//           idCardNumber:
//               _idCardController.text.trim(),
//           service: _selectedService,
//           about: _aboutController.text.trim(),
//           verified: false,
//           isLive: false,
//         );

//         /*
//          * یہ method:
//          *
//          * providers/{uid} میں profile save کرے گا۔
//          * users/{uid} میں profileCompleted true کرے گا۔
//          */
//         await FirestoreService.instance
//             .saveCompletedProviderProfile(
//           providerProfile,
//         );

//         if (!mounted) return;

//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(
//             builder: (_) =>
//                 const ProviderDashboardScreen(),
//           ),
//           (route) => false,
//         );

//         return;
//       }

//       /*
//        * Normal user کے لیے profile complete۔
//        */
//       await FirestoreService.instance
//           .updateProfileCompletion(
//         uid: uid,
//         profileCompleted: true,
//       );

//       if (!mounted) return;

//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (_) =>
//               const SelectServiceScreen(),
//         ),
//         (route) => false,
//       );
//     } on FirebaseException catch (error) {
//       if (!mounted) return;

//       setState(() {
//         if (error.code == 'permission-denied') {
//           _error =
//               'Firestore permission denied. Please check your Firestore rules.';
//         } else if (error.code ==
//             'network-request-failed') {
//           _error =
//               'Please check your internet connection.';
//         } else {
//           _error = error.message ??
//               'Could not save your profile.';
//         }
//       });
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _error =
//             'Could not save your profile. Please try again.';
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           _saving = false;
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _whatsappController.dispose();
//     _idCardController.dispose();
//     _aboutController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_loadingProfile) {
//       return const Scaffold(
//         backgroundColor: AppColors.white,
//         body: SafeArea(
//           child: Center(
//             child: CircularProgressIndicator(
//               color: AppColors.primaryYellow,
//             ),
//           ),
//         ),
//       );
//     }

//     return PopScope(
//       canPop: false,
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: Text(
//             isProvider
//                 ? 'Complete Provider Profile'
//                 : 'Complete Your Profile',
//           ),
//           backgroundColor: AppColors.white,
//           surfaceTintColor: AppColors.white,
//         ),
//         body: SafeArea(
//           child: AutofillGroup(
//             child: SingleChildScrollView(
//               keyboardDismissBehavior:
//                   ScrollViewKeyboardDismissBehavior
//                       .onDrag,
//               padding: const EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment:
//                       CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       isProvider
//                           ? 'Tell customers about your service'
//                           : 'Add your basic information',
//                       style: const TextStyle(
//                         color: AppColors.darkBg,
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       isProvider
//                           ? 'Complete your profile before going live.'
//                           : 'Complete your profile to continue.',
//                       style: const TextStyle(
//                         color: AppColors.textGrey,
//                         height: 1.4,
//                       ),
//                     ),
//                     const SizedBox(height: 26),

//                     /*
//                      * Full name
//                      */
//                     TextFormField(
//                       controller: _nameController,
//                       enabled: !_saving,
//                       textInputAction:
//                           TextInputAction.next,
//                       textCapitalization:
//                           TextCapitalization.words,
//                       autofillHints: const [
//                         AutofillHints.name,
//                       ],
//                       decoration:
//                           const InputDecoration(
//                         labelText: 'Full Name',
//                         hintText: 'Enter your full name',
//                         prefixIcon: Icon(
//                           Icons.person_outline,
//                         ),
//                       ),
//                       validator: (value) {
//                         final name =
//                             value?.trim() ?? '';

//                         if (name.isEmpty) {
//                           return 'Please enter your full name';
//                         }

//                         if (name.length < 3) {
//                           return 'Name must contain at least 3 characters';
//                         }

//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),

//                     /*
//                      * WhatsApp
//                      */
//                     TextFormField(
//                       controller:
//                           _whatsappController,
//                       enabled: !_saving,
//                       keyboardType:
//                           TextInputType.phone,
//                       textInputAction: isProvider
//                           ? TextInputAction.next
//                           : TextInputAction.done,
//                       autofillHints: const [
//                         AutofillHints.telephoneNumber,
//                       ],
//                       decoration:
//                           const InputDecoration(
//                         labelText:
//                             'WhatsApp Number',
//                         hintText: '+923001234567',
//                         prefixIcon: Icon(
//                           Icons.chat_outlined,
//                         ),
//                       ),
//                       onFieldSubmitted: (_) {
//                         if (!isProvider) {
//                           _saveProfile();
//                         }
//                       },
//                       validator: (value) {
//                         final phone =
//                             value?.trim() ?? '';

//                         if (phone.isEmpty) {
//                           return 'Please enter your WhatsApp number';
//                         }

//                         if (!_isValidWhatsAppNumber(
//                           phone,
//                         )) {
//                           return 'Enter a valid number with country code';
//                         }

//                         return null;
//                       },
//                     ),

//                     if (isProvider) ...[
//                       const SizedBox(height: 16),

//                       /*
//                        * CNIC / ID card
//                        */
//                       TextFormField(
//                         controller:
//                             _idCardController,
//                         enabled: !_saving,
//                         keyboardType:
//                             TextInputType.text,
//                         textInputAction:
//                             TextInputAction.next,
//                         decoration:
//                             const InputDecoration(
//                           labelText:
//                               'CNIC / ID Card Number',
//                           hintText:
//                               '35202-1234567-1',
//                           prefixIcon: Icon(
//                             Icons.badge_outlined,
//                           ),
//                         ),
//                         validator: (value) {
//                           final idCard =
//                               value?.trim() ?? '';

//                           if (idCard.isEmpty) {
//                             return 'Please enter your CNIC or ID card number';
//                           }

//                           if (!_isValidIdCard(
//                             idCard,
//                           )) {
//                             return 'Enter a valid ID card number';
//                           }

//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       /*
//                        * Service
//                        */
//                       DropdownButtonFormField<String>(
//                         initialValue:
//                             _selectedService,
//                         isExpanded: true,
//                         decoration:
//                             const InputDecoration(
//                           labelText:
//                               'Your Main Service',
//                           prefixIcon: Icon(
//                             Icons
//                                 .home_repair_service_outlined,
//                           ),
//                         ),
//                         items: kServiceCategories
//                             .map(
//                               (service) =>
//                                   DropdownMenuItem<
//                                       String>(
//                                 value: service.name,
//                                 child: Text(
//                                   service.name,
//                                   overflow:
//                                       TextOverflow
//                                           .ellipsis,
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                         onChanged: _saving
//                             ? null
//                             : (value) {
//                                 if (value == null) {
//                                   return;
//                                 }

//                                 setState(() {
//                                   _selectedService =
//                                       value;
//                                 });
//                               },
//                         validator: (value) {
//                           if (value == null ||
//                               value.trim().isEmpty) {
//                             return 'Please select your service';
//                           }

//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 16),

//                       /*
//                        * About provider
//                        */
//                       TextFormField(
//                         controller:
//                             _aboutController,
//                         enabled: !_saving,
//                         maxLines: 4,
//                         minLines: 3,
//                         maxLength: 300,
//                         textCapitalization:
//                             TextCapitalization
//                                 .sentences,
//                         textInputAction:
//                             TextInputAction.newline,
//                         decoration:
//                             const InputDecoration(
//                           labelText: 'About You',
//                           hintText:
//                               'Write about your experience and specialties',
//                           alignLabelWithHint: true,
//                           prefixIcon: Padding(
//                             padding:
//                                 EdgeInsets.only(
//                               bottom: 65,
//                             ),
//                             child: Icon(
//                               Icons
//                                   .description_outlined,
//                             ),
//                           ),
//                         ),
//                         validator: (value) {
//                           final about =
//                               value?.trim() ?? '';

//                           if (about.isEmpty) {
//                             return 'Please write a short introduction';
//                           }

//                           if (about.length < 15) {
//                             return 'Introduction must contain at least 15 characters';
//                           }

//                           return null;
//                         },
//                       ),
//                     ],

//                     /*
//                      * Firebase error
//                      */
//                     if (_error != null) ...[
//                       const SizedBox(height: 16),
//                       Container(
//                         width: double.infinity,
//                         padding:
//                             const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: AppColors.danger
//                               .withOpacity(0.08),
//                           borderRadius:
//                               BorderRadius.circular(
//                             10,
//                           ),
//                           border: Border.all(
//                             color: AppColors.danger
//                                 .withOpacity(0.20),
//                           ),
//                         ),
//                         child: Row(
//                           crossAxisAlignment:
//                               CrossAxisAlignment
//                                   .start,
//                           children: [
//                             const Icon(
//                               Icons.error_outline,
//                               color:
//                                   AppColors.danger,
//                               size: 20,
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Text(
//                                 _error!,
//                                 style:
//                                     const TextStyle(
//                                   color: AppColors
//                                       .danger,
//                                   height: 1.4,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],

//                     const SizedBox(height: 26),

//                     PrimaryButton(
//                       label: isProvider
//                           ? 'Save Provider Profile'
//                           : 'Save & Continue',
//                       onPressed: _saveProfile,
//                       loading: _saving,
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }