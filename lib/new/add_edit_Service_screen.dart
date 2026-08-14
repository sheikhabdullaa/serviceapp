import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';

import '../../theme/app_theme.dart';

class AddEditServiceScreen extends StatefulWidget {
  final String providerId;
  final ProviderService? service;

  const AddEditServiceScreen({
    super.key,
    required this.providerId,
    this.service,
  });

  bool get isEditing => service != null;

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _chargeController;
  late final TextEditingController _experienceController;
  late final TextEditingController _areaController;

  late String _selectedCategory;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    final service = widget.service;

    _titleController = TextEditingController(
      text: service?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: service?.description ?? '',
    );

    _chargeController = TextEditingController(
      text: service == null ? '' : service.hourlyCharge.toStringAsFixed(0),
    );

    _experienceController = TextEditingController(
      text: service == null ? '' : service.experienceYears.toString(),
    );

    _areaController = TextEditingController(
      text: service?.serviceArea ?? '',
    );

    final categoryExists = kServiceCategories.any(
      (category) => category.name == service?.category,
    );

    _selectedCategory =
        categoryExists ? service!.category : kServiceCategories.first.name;
  }

  Future<void> _saveService() async {
    if (_saving) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final hourlyCharge = double.parse(
      _chargeController.text.trim(),
    );

    final experienceYears = int.parse(
      _experienceController.text.trim(),
    );

    final existingService = widget.service;

    final service = ProviderService(
      id: existingService?.id ?? '',
      providerId: widget.providerId,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      description: _descriptionController.text.trim(),
      hourlyCharge: hourlyCharge,
      experienceYears: experienceYears,
      serviceArea: _areaController.text.trim(),
      createdAt: existingService?.createdAt ?? DateTime.now(),
      providerName: '',
    );

    try {
      if (widget.isEditing) {
        await FirestoreService.instance.updateProviderService(
          service,
        );
      } else {
        await FirestoreService.instance.createProviderService(
          service,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Service updated successfully.'
                : 'Service added successfully.',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = widget.isEditing
            ? 'Could not update service. Please try again.'
            : 'Could not add service. Please try again.';
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
    _titleController.dispose();
    _descriptionController.dispose();
    _chargeController.dispose();
    _experienceController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageTitle = widget.isEditing ? 'Edit Service' : 'Add New Service';

    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: AppColors.cardDark,
        appBar: AppBar(
          title: Text(pageTitle),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderCard(
                    isEditing: widget.isEditing,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Service Details',
                    style: TextStyle(
                      color: AppColors.darkBg,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _titleController,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Service Title',
                      hintText: 'e.g. Home Electrical Repair',
                      prefixIcon: Icon(
                        Icons.home_repair_service_outlined,
                      ),
                    ),
                    validator: (value) {
                      final title = value?.trim() ?? '';

                      if (title.isEmpty) {
                        return 'Please enter a service title';
                      }

                      if (title.length < 4) {
                        return 'Title must contain at least 4 characters';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: _selectedCategory,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Service Category',
                      prefixIcon: Icon(
                        Icons.category_outlined,
                      ),
                    ),
                    items: kServiceCategories.map(
                      (category) {
                        return DropdownMenuItem<String>(
                          value: category.name,
                          child: Row(
                            children: [
                              Icon(
                                category.icon,
                                size: 19,
                              ),
                              const SizedBox(width: 10),
                              Text(category.name),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !_saving,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 350,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Service Description',
                      hintText:
                          'Explain what work you provide in this service.',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      final description = value?.trim() ?? '';

                      if (description.isEmpty) {
                        return 'Please enter service details';
                      }

                      if (description.length < 15) {
                        return 'Description must contain at least 15 characters';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Pricing & Experience',
                    style: TextStyle(
                      color: AppColors.darkBg,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _chargeController,
                          enabled: !_saving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Hourly Charge',
                            hintText: '1000',
                            prefixText: 'PKR ',
                            prefixIcon: Icon(
                              Icons.payments_outlined,
                            ),
                          ),
                          validator: (value) {
                            final amount = double.tryParse(
                              value?.trim() ?? '',
                            );

                            if (amount == null || amount <= 0) {
                              return 'Enter valid charge';
                            }

                            if (amount > 100000) {
                              return 'Enter a realistic charge';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _experienceController,
                          enabled: !_saving,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Experience',
                            hintText: '3',
                            suffixText: 'years',
                            prefixIcon: Icon(
                              Icons.workspace_premium_outlined,
                            ),
                          ),
                          validator: (value) {
                            final years = int.tryParse(
                              value?.trim() ?? '',
                            );

                            if (years == null || years < 0) {
                              return 'Enter valid years';
                            }

                            if (years > 70) {
                              return 'Enter valid years';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Service Area',
                    style: TextStyle(
                      color: AppColors.darkBg,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _areaController,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Area / City',
                      hintText: 'e.g. Johar Town, Lahore',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                      ),
                    ),
                    validator: (value) {
                      final area = value?.trim() ?? '';

                      if (area.isEmpty) {
                        return 'Please enter your service area';
                      }

                      if (area.length < 3) {
                        return 'Enter a valid service area';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const InfoMessageBox(
                    message:
                        'Your service becomes visible to users only when your provider profile is Live.',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    ErrorMessageBox(
                      message: _error!,
                    ),
                  ],
                  const SizedBox(height: 25),
                  PrimaryButton(
                    label: widget.isEditing ? 'Save Changes' : 'Add Service',
                    icon: widget.isEditing ? Icons.save_outlined : Icons.add,
                    onPressed: _saveService,
                    loading: _saving,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final bool isEditing;

  const _HeaderCard({
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 57,
            height: 57,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              isEditing ? Icons.edit_outlined : Icons.add_business_outlined,
              color: AppColors.darkBg,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Update your service' : 'Add a new service',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Clear details help users choose the right provider.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
