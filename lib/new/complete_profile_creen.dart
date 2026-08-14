import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/uploadidcard.dart';

import '../../theme/app_theme.dart';

class CompleteProfileScreen extends StatefulWidget {
  final User firebaseUser;
  final String role;

  const CompleteProfileScreen({
    super.key,
    required this.firebaseUser,
    required this.role,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _whatsappController = TextEditingController();

  final TextEditingController _idCardController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _aboutController = TextEditingController();

  late String _selectedMainService;

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _selectedMainService = kServiceCategories.first.name;

    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final appUser =
          await FirestoreService.instance.getUser(widget.firebaseUser.uid);

      final provider = await FirestoreService.instance.getProvider(
        widget.firebaseUser.uid,
      );

      if (appUser != null) {
        _nameController.text = appUser.name;

        _whatsappController.text = appUser.whatsapp;
      }

      if (provider != null) {
        if (_nameController.text.trim().isEmpty) {
          _nameController.text = provider.name;
        }

        if (_whatsappController.text.trim().isEmpty) {
          _whatsappController.text = provider.whatsapp;
        }

        _idCardController.text = provider.idCardNumber;

        _addressController.text = provider.address;

        _aboutController.text = provider.about;

        final categoryExists = kServiceCategories.any(
          (category) => category.name == provider.mainService,
        );

        if (categoryExists) {
          _selectedMainService = provider.mainService;
        }
      }
    } catch (error) {
      _error = 'Could not load your existing profile.';
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool _isValidWhatsAppNumber(
    String value,
  ) {
    final cleaned = value.replaceAll(
      RegExp(r'[\s\-\(\)]'),
      '',
    );

    return RegExp(
      r'^\+?[0-9]{8,15}$',
    ).hasMatch(cleaned);
  }

  bool _isValidIdCard(String value) {
    final cleaned = value.replaceAll(
      RegExp(r'[\s\-]'),
      '',
    );

    return RegExp(
      r'^[A-Za-z0-9]{5,20}$',
    ).hasMatch(cleaned);
  }

  Future<void> _continueToIdUpload() async {
    if (_saving) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final uid = widget.firebaseUser.uid;

    final email = widget.firebaseUser.email?.trim().toLowerCase() ?? '';

    final existingProvider = await FirestoreService.instance.getProvider(uid);

    final providerProfile = ProviderProfile(
      uid: uid,
      email: email,
      name: _nameController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      idCardNumber: _idCardController.text.trim(),

      /*
       * Existing uploaded image ہو تو preserve ہوگی۔
       */
      idCardImageUrl: existingProvider?.idCardImageUrl ?? '',
      mainService: _selectedMainService,
      about: _aboutController.text.trim(),
      address: _addressController.text.trim(),
      verified: existingProvider?.verified ?? false,
      isLive: existingProvider?.isLive ?? false,
      totalViews: existingProvider?.totalViews ?? 0,
      totalContacts: existingProvider?.totalContacts ?? 0,
      totalBookings: existingProvider?.totalBookings ?? 0,
      rating: existingProvider?.rating ?? 0,
      reviewCount: existingProvider?.reviewCount ?? 0,
      createdAt: existingProvider?.createdAt,
    );

    try {
      /*
       * users/{uid} میں basic information update۔
       */
      await FirestoreService.instance.updateUserFields(
        uid: uid,
        data: {
          'name': providerProfile.name,
          'whatsapp': providerProfile.whatsapp,
          'role': 'provider',
          'emailVerified': widget.firebaseUser.emailVerified,
          'profileCompleted': false,
        },
      );

      /*
       * providers/{uid} میں draft profile save۔
       */
      await FirestoreService.instance.createOrUpdateProvider(
        providerProfile,
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => UploadIdCardScreen(
            providerProfile: providerProfile,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      setState(() {
        if (error.code == 'permission-denied') {
          _error = 'Firestore permission denied. Check your Firestore rules.';
        } else {
          _error = error.message ?? 'Could not save your profile.';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not save your profile. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _idCardController.dispose();
    _addressController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppLoadingScreen(
        message: 'Loading your profile...',
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Create Provider Profile',
          ),
        ),
        body: SafeArea(
          child: AutofillGroup(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(22),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tell us about yourself',
                      style: TextStyle(
                        color: AppColors.darkBg,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This information will be shown to users looking for your services.',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // const _ProfileStepIndicator(
                    //   currentStep: 1,
                    // ),
                    const SizedBox(height: 26),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_saving,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.name,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(
                          Icons.person_outline,
                        ),
                      ),
                      validator: (value) {
                        final name = value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Please enter your full name';
                        }

                        if (name.length < 3) {
                          return 'Name must contain at least 3 characters';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _whatsappController,
                      enabled: !_saving,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.telephoneNumber,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp Number',
                        hintText: '+923001234567',
                        prefixIcon: Icon(
                          Icons.chat_outlined,
                        ),
                      ),
                      validator: (value) {
                        final phone = value?.trim() ?? '';

                        if (phone.isEmpty) {
                          return 'Please enter your WhatsApp number';
                        }

                        if (!_isValidWhatsAppNumber(
                          phone,
                        )) {
                          return 'Enter a valid number with country code';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _idCardController,
                      enabled: !_saving,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'CNIC / ID Card Number',
                        hintText: '35202-1234567-1',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                        ),
                      ),
                      validator: (value) {
                        final id = value?.trim() ?? '';

                        if (id.isEmpty) {
                          return 'Please enter your ID card number';
                        }

                        if (!_isValidIdCard(id)) {
                          return 'Enter a valid ID card number';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedMainService,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Main Service Category',
                        prefixIcon: Icon(
                          Icons.home_repair_service_outlined,
                        ),
                      ),
                      items: kServiceCategories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category.name,
                              child: Row(
                                children: [
                                  Icon(
                                    category.icon,
                                    size: 19,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    category.name,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _saving
                          ? null
                          : (value) {
                              if (value == null) {
                                return;
                              }

                              setState(() {
                                _selectedMainService = value;
                              });
                            },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      enabled: !_saving,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [
                        AutofillHints.fullStreetAddress,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Service Area / Address',
                        hintText: 'Example: Johar Town, Lahore',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                        ),
                      ),
                      validator: (value) {
                        final address = value?.trim() ?? '';

                        if (address.isEmpty) {
                          return 'Please enter your service area';
                        }

                        if (address.length < 4) {
                          return 'Please enter a valid service area';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _aboutController,
                      enabled: !_saving,
                      minLines: 3,
                      maxLines: 5,
                      maxLength: 300,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'About You',
                        hintText: 'Write about your experience and skills',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        final about = value?.trim() ?? '';

                        if (about.isEmpty) {
                          return 'Please write a short introduction';
                        }

                        if (about.length < 15) {
                          return 'Introduction must contain at least 15 characters';
                        }

                        return null;
                      },
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      ErrorMessageBox(
                        message: _error!,
                      ),
                    ],
                    const SizedBox(height: 25),
                    PrimaryButton(
                      label: 'Continue to ID Upload',
                      icon: Icons.arrow_forward,
                      onPressed: _continueToIdUpload,
                      loading: _saving,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class _ProfileStepIndicator extends StatelessWidget {
//   final int currentStep;

//   const _ProfileStepIndicator({
//     required this.currentStep,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const labels = [
//       'Details',
//       'ID Card',
//       'Preview',
//     ];

//     return Row(
//       children: List.generate(
//         labels.length,
//         (index) {
//           final step = index + 1;
//           final active = step <= currentStep;

//           return Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 32,
//                         height: 32,
//                         decoration: BoxDecoration(
//                           color: active
//                               ? AppColors.primaryYellow
//                               : AppColors.darkBg,
//                           shape: BoxShape.circle,
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(
//                           '$step',
//                           style: TextStyle(
//                             color:
//                                 active ? AppColors.darkBg : AppColors.textGrey,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         labels[index],
//                         style: TextStyle(
//                           color: active ? AppColors.darkBg : AppColors.textGrey,
//                           fontSize: 11,
//                           fontWeight:
//                               active ? FontWeight.w600 : FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (index < labels.length - 1)
//                   Expanded(
//                     child: Container(
//                       height: 2,
//                       color: step < currentStep
//                           ? AppColors.primaryYellow
//                           : AppColors.darkBg,
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
