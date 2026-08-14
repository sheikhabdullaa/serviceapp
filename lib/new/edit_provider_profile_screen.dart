import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import '../../theme/app_theme.dart';

class EditProviderProfileScreen extends StatefulWidget {
  final ProviderProfile providerProfile;

  const EditProviderProfileScreen({
    super.key,
    required this.providerProfile,
  });

  @override
  State<EditProviderProfileScreen> createState() =>
      _EditProviderProfileScreenState();
}

class _EditProviderProfileScreenState extends State<EditProviderProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;

  late final TextEditingController _whatsappController;

  late final TextEditingController _addressController;

  late final TextEditingController _aboutController;

  late String _selectedMainService;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.providerProfile.name,
    );

    _whatsappController = TextEditingController(
      text: widget.providerProfile.whatsapp,
    );

    _addressController = TextEditingController(
      text: widget.providerProfile.address,
    );

    _aboutController = TextEditingController(
      text: widget.providerProfile.about,
    );

    final categoryExists = kServiceCategories.any(
      (category) => category.name == widget.providerProfile.mainService,
    );

    _selectedMainService = categoryExists
        ? widget.providerProfile.mainService
        : kServiceCategories.first.name;
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

  Future<void> _saveChanges() async {
    if (_saving) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final updatedProvider = widget.providerProfile.copyWith(
      name: _nameController.text.trim(),
      whatsapp: _whatsappController.text.trim(),
      mainService: _selectedMainService,
      address: _addressController.text.trim(),
      about: _aboutController.text.trim(),
    );

    try {
      await FirestoreService.instance.createOrUpdateProvider(
        updatedProvider,
      );

      await FirestoreService.instance.updateUserFields(
        uid: updatedProvider.uid,
        data: {
          'name': updatedProvider.name,
          'whatsapp': updatedProvider.whatsapp,
        },
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile updated successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop(true);
    } on FirebaseException catch (error) {
      if (!mounted) return;

      setState(() {
        if (error.code == 'permission-denied') {
          _error = 'Permission denied. Check Firestore security rules.';
        } else {
          _error = error.message ?? 'Could not update profile.';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not update profile. Please try again.';
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
    _addressController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text(
            'Edit Provider Profile',
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
                      'Update your information',
                      style: TextStyle(
                        color: AppColors.darkBg,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'These details will be visible to users on your public provider profile.',
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_saving,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
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
                      decoration: const InputDecoration(
                        labelText: 'Service Area / Address',
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
                          return 'Enter a valid service area';
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
                    const SizedBox(height: 4),
                    InfoMessageBox(
                      message:
                          'ID Card: ${widget.providerProfile.idCardNumber}. '
                          'Contact support if you need to change your identity document.',
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      ErrorMessageBox(
                        message: _error!,
                      ),
                    ],
                    const SizedBox(height: 26),
                    PrimaryButton(
                      label: 'Save Changes',
                      icon: Icons.save_outlined,
                      onPressed: _saveChanges,
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
