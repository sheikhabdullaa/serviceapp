// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:service_hub/new/appuser.dart';
// import 'package:service_hub/new/firestore_service.dart';
// import 'package:service_hub/new/primary_buton.dart';
// import 'package:service_hub/new/user_model.dart'
//     hide ProviderService, ProviderProfile;

// import '../../theme/app_theme.dart' hide kServiceCategories, ServiceCategory;

// class AddEditServiceScreen extends StatefulWidget {
//   final ProviderProfile providerProfile;
//   final ProviderService? existingService;

//   const AddEditServiceScreen({
//     super.key,
//     required this.providerProfile,
//     this.existingService,
//     required String providerId,
//     required ProviderService service,
//   });

//   @override
//   State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
// }

// class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _titleController = TextEditingController();

//   final TextEditingController _descriptionController = TextEditingController();

//   final TextEditingController _experienceController = TextEditingController();

//   final TextEditingController _hourlyChargeController = TextEditingController();

//   final TextEditingController _serviceAreaController = TextEditingController();

//   late String _selectedCategory;
//   late int _selectedCategoryIndex;

//   bool _isActive = true;
//   bool _saving = false;
//   String? _error;

//   bool get isEditing => widget.existingService != null;
//   List<ServiceCategory> get _uniqueServiceCategories {
//     final Map<String, ServiceCategory> uniqueCategories = {};

//     for (final category in kServiceCategories) {
//       final cleanName = category.name.trim();

//       if (cleanName.isNotEmpty) {
//         uniqueCategories.putIfAbsent(
//           cleanName,
//           () => category,
//         );
//       }
//     }

//     return uniqueCategories.values.toList(growable: false);
//   }

//   @override
//   void initState() {
//     super.initState();

//     final service = widget.existingService;
//     final categories = _uniqueServiceCategories;

//     final profileCategory = widget.providerProfile.mainService.trim();

//     final requestedCategory = (service?.category.trim().isNotEmpty == true)
//         ? service!.category.trim()
//         : profileCategory;

//     final foundIndex = categories.indexWhere(
//       (category) =>
//           category.name.trim().toLowerCase() == requestedCategory.toLowerCase(),
//     );

//     _selectedCategoryIndex = foundIndex >= 0 ? foundIndex : 0;

//     _selectedCategory = categories[_selectedCategoryIndex].name.trim();

//     _titleController.text = service?.title ?? '';

//     _descriptionController.text = service?.description ?? '';

//     _experienceController.text =
//         service == null ? '' : service.experienceYears.toString();

//     _hourlyChargeController.text =
//         service == null ? '' : service.hourlyCharge.toStringAsFixed(0);

//     _serviceAreaController.text =
//         service?.serviceArea ?? widget.providerProfile.address;

//     _isActive = service?.isActive ?? true;
//   }

//   Future<void> _saveService() async {
//     if (_saving) return;

//     FocusManager.instance.primaryFocus?.unfocus();

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     final experience = int.tryParse(
//           _experienceController.text.trim(),
//         ) ??
//         0;

//     final hourlyCharge = double.tryParse(
//           _hourlyChargeController.text.trim().replaceAll(',', ''),
//         ) ??
//         0;

//     final service = ProviderService(
//       id: widget.existingService?.id ?? '',
//       providerId: widget.providerProfile.uid,
//       providerName: widget.providerProfile.name,
//       category: _selectedCategory,
//       title: _titleController.text.trim(),
//       description: _descriptionController.text.trim(),
//       experienceYears: experience,
//       hourlyCharge: hourlyCharge,
//       serviceArea: _serviceAreaController.text.trim(),
//       isActive: _isActive,
//       createdAt: widget.existingService?.createdAt,
//     );

//     setState(() {
//       _saving = true;
//       _error = null;
//     });

//     try {
//       if (isEditing) {
//         await FirestoreService.instance.updateProviderService(service);
//       } else {
//         await FirestoreService.instance.addProviderService(service);
//       }

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             isEditing
//                 ? 'Service updated successfully'
//                 : 'Service added successfully',
//           ),
//           backgroundColor: AppColors.success,
//         ),
//       );

//       Navigator.of(context).pop(true);
//     } on FirebaseException catch (error) {
//       if (!mounted) return;

//       setState(() {
//         if (error.code == 'permission-denied') {
//           _error = 'Permission denied. Check your Firestore security rules.';
//         } else {
//           _error = error.message ?? 'Could not save service.';
//         }
//       });
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _error = 'Could not save service: $error';
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
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _experienceController.dispose();
//     _hourlyChargeController.dispose();
//     _serviceAreaController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = _uniqueServiceCategories;

//     final selectedCategory = categories[_selectedCategoryIndex];

//     return PopScope(
//       canPop: !_saving,
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         appBar: AppBar(
//           title: Text(
//             isEditing ? 'Edit Service' : 'Add New Service',
//           ),
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             padding: const EdgeInsets.all(22),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isEditing
//                         ? 'Update your service'
//                         : 'What service do you offer?',
//                     style: const TextStyle(
//                       color: AppColors.darkBg,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     isEditing
//                         ? 'Make changes and save your service.'
//                         : 'Add clear details so users understand exactly what you provide.',
//                     style: const TextStyle(
//                       color: AppColors.textGrey,
//                       fontSize: 14,
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 26),

//                   // Dropdown ki internal value unique index hai.
//                   // Screen aur Firestore mein category name hi use hoga.
//                   DropdownButtonFormField<int>(
//                     key: ValueKey<int>(
//                       _selectedCategoryIndex,
//                     ),
//                     // ignore: deprecated_member_use
//                     value: _selectedCategoryIndex,
//                     isExpanded: true,
//                     decoration: InputDecoration(
//                       labelText: 'Service Category',
//                       prefixIcon: Icon(
//                         selectedCategory.icon,
//                       ),
//                     ),
//                     items: List.generate(
//                       categories.length,
//                       (index) {
//                         final category = categories[index];

//                         return DropdownMenuItem<int>(
//                           value: index,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 category.icon,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 10),
//                               Text(
//                                 category.name.trim(),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     onChanged: _saving
//                         ? null
//                         : (index) {
//                             if (index == null) return;

//                             setState(() {
//                               _selectedCategoryIndex = index;
//                               _selectedCategory = categories[index].name.trim();
//                             });
//                           },
//                     validator: (index) {
//                       if (index == null ||
//                           index < 0 ||
//                           index >= categories.length) {
//                         return 'Please select a service category';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _titleController,
//                     enabled: !_saving,
//                     textCapitalization: TextCapitalization.words,
//                     textInputAction: TextInputAction.next,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Title',
//                       hintText: 'Example: Home Electrical Wiring',
//                       prefixIcon: Icon(
//                         Icons.home_repair_service_outlined,
//                       ),
//                     ),
//                     validator: (value) {
//                       final title = value?.trim() ?? '';

//                       if (title.isEmpty) {
//                         return 'Please enter a service title';
//                       }

//                       if (title.length < 4) {
//                         return 'Service title is too short';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _descriptionController,
//                     enabled: !_saving,
//                     minLines: 3,
//                     maxLines: 5,
//                     maxLength: 350,
//                     textCapitalization: TextCapitalization.sentences,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Description',
//                       hintText: 'Describe what is included in this service',
//                       alignLabelWithHint: true,
//                     ),
//                     validator: (value) {
//                       final description = value?.trim() ?? '';

//                       if (description.isEmpty) {
//                         return 'Please enter a service description';
//                       }

//                       if (description.length < 15) {
//                         return 'Description must contain at least 15 characters';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _experienceController,
//                           enabled: !_saving,
//                           keyboardType: TextInputType.number,
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             labelText: 'Experience',
//                             hintText: 'Years',
//                             prefixIcon: Icon(
//                               Icons.work_history_outlined,
//                             ),
//                           ),
//                           validator: (value) {
//                             final years = int.tryParse(
//                               value?.trim() ?? '',
//                             );

//                             if (years == null) {
//                               return 'Required';
//                             }

//                             if (years < 0 || years > 60) {
//                               return 'Invalid';
//                             }

//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _hourlyChargeController,
//                           enabled: !_saving,
//                           keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             labelText: 'Hourly Charge',
//                             hintText: 'PKR',
//                             prefixIcon: Icon(
//                               Icons.payments_outlined,
//                             ),
//                           ),
//                           validator: (value) {
//                             final charge = double.tryParse(
//                               (value ?? '').trim().replaceAll(',', ''),
//                             );

//                             if (charge == null) {
//                               return 'Required';
//                             }

//                             if (charge <= 0) {
//                               return 'Invalid';
//                             }

//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _serviceAreaController,
//                     enabled: !_saving,
//                     textCapitalization: TextCapitalization.words,
//                     textInputAction: TextInputAction.done,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Area',
//                       hintText: 'Example: Johar Town, Lahore',
//                       prefixIcon: Icon(
//                         Icons.location_on_outlined,
//                       ),
//                     ),
//                     validator: (value) {
//                       final area = value?.trim() ?? '';

//                       if (area.isEmpty) {
//                         return 'Please enter your service area';
//                       }

//                       if (area.length < 4) {
//                         return 'Enter a valid service area';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 18),
//                   Container(
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF8FAFC),
//                       borderRadius: BorderRadius.circular(13),
//                       border: Border.all(
//                         color: AppColors.cardDark,
//                       ),
//                     ),
//                     child: SwitchListTile(
//                       contentPadding: EdgeInsets.zero,
//                       value: _isActive,
//                       // ignore: deprecated_member_use
//                       activeColor: AppColors.success,
//                       title: const Text(
//                         'Active Service',
//                         style: TextStyle(
//                           color: AppColors.darkBg,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       subtitle: Text(
//                         _isActive
//                             ? 'Users can find this service when your profile is live.'
//                             : 'This service will remain hidden from users.',
//                         style: const TextStyle(
//                           color: AppColors.textGrey,
//                           fontSize: 12,
//                         ),
//                       ),
//                       onChanged: _saving
//                           ? null
//                           : (value) {
//                               setState(() {
//                                 _isActive = value;
//                               });
//                             },
//                     ),
//                   ),
//                   if (_error != null) ...[
//                     const SizedBox(height: 16),
//                     ErrorMessageBox(
//                       message: _error!,
//                     ),
//                   ],
//                   const SizedBox(height: 26),
//                   PrimaryButton(
//                     label: isEditing ? 'Update Service' : 'Add Service',
//                     icon: isEditing ? Icons.save_outlined : Icons.add,
//                     onPressed: _saveService,
//                     loading: _saving,
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:service_hub/new/appuser.dart';
// import 'package:service_hub/new/firestore_service.dart';
// import 'package:service_hub/new/primary_buton.dart';
// import 'package:service_hub/new/user_model.dart'
//     hide ProviderService, ProviderProfile;

// import '../../theme/app_theme.dart' hide kServiceCategories, ServiceCategory;

// class AddEditServiceScreen extends StatefulWidget {
//   final String providerId;
//   final ProviderProfile providerProfile;
//   final ProviderService? existingService;

//   const AddEditServiceScreen({
//     super.key,
//     required this.providerId,
//     required this.providerProfile,
//     this.existingService, required ProviderService service,
//   });

//   @override
//   State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
// }

// class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _titleController = TextEditingController();

//   final TextEditingController _descriptionController = TextEditingController();

//   final TextEditingController _experienceController = TextEditingController();

//   final TextEditingController _hourlyChargeController = TextEditingController();

//   final TextEditingController _serviceAreaController = TextEditingController();

//   late String _selectedCategory;
//   late int _selectedCategoryIndex;

//   bool _isActive = true;
//   bool _saving = false;
//   String? _error;

//   bool get isEditing => widget.existingService != null;
//   List<ServiceCategory> get _uniqueServiceCategories {
//     final Map<String, ServiceCategory> uniqueCategories = {};

//     for (final category in kServiceCategories) {
//       final cleanName = category.name.trim();

//       if (cleanName.isNotEmpty) {
//         uniqueCategories.putIfAbsent(
//           cleanName,
//           () => category,
//         );
//       }
//     }

//     return uniqueCategories.values.toList(growable: false);
//   }

//   @override
//   void initState() {
//     super.initState();

//     final service = widget.existingService;
//     final categories = _uniqueServiceCategories;

//     final profileCategory = widget.providerProfile.mainService.trim();

//     final requestedCategory = (service?.category.trim().isNotEmpty == true)
//         ? service!.category.trim()
//         : profileCategory;

//     final foundIndex = categories.indexWhere(
//       (category) =>
//           category.name.trim().toLowerCase() == requestedCategory.toLowerCase(),
//     );

//     _selectedCategoryIndex = foundIndex >= 0 ? foundIndex : 0;

//     _selectedCategory = categories[_selectedCategoryIndex].name.trim();

//     _titleController.text = service?.title ?? '';

//     _descriptionController.text = service?.description ?? '';

//     _experienceController.text =
//         service == null ? '' : service.experienceYears.toString();

//     _hourlyChargeController.text =
//         service == null ? '' : service.hourlyCharge.toStringAsFixed(0);

//     _serviceAreaController.text =
//         service?.serviceArea ?? widget.providerProfile.address;

//     _isActive = service?.isActive ?? true;
//   }

//   Future<void> _saveService() async {
//     if (_saving) return;

//     FocusManager.instance.primaryFocus?.unfocus();

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     final experience = int.tryParse(
//           _experienceController.text.trim(),
//         ) ??
//         0;

//     final hourlyCharge = double.tryParse(
//           _hourlyChargeController.text.trim().replaceAll(',', ''),
//         ) ??
//         0;

//     final service = ProviderService(
//       id: widget.existingService?.id ?? '',
//       providerId: widget.providerId.trim().isNotEmpty
//           ? widget.providerId.trim()
//           : widget.providerProfile.uid,
//       providerName: widget.providerProfile.name,
//       category: _selectedCategory,
//       title: _titleController.text.trim(),
//       description: _descriptionController.text.trim(),
//       experienceYears: experience,
//       hourlyCharge: hourlyCharge,
//       serviceArea: _serviceAreaController.text.trim(),
//       isActive: _isActive,
//       createdAt: widget.existingService?.createdAt,
//     );

//     setState(() {
//       _saving = true;
//       _error = null;
//     });

//     try {
//       if (isEditing) {
//         await FirestoreService.instance.updateProviderService(service);
//       } else {
//         await FirestoreService.instance.addProviderService(service);
//       }

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             isEditing
//                 ? 'Service updated successfully'
//                 : 'Service added successfully',
//           ),
//           backgroundColor: AppColors.success,
//         ),
//       );

//       Navigator.of(context).pop(true);
//     } on FirebaseException catch (error) {
//       if (!mounted) return;

//       setState(() {
//         if (error.code == 'permission-denied') {
//           _error = 'Permission denied. Check your Firestore security rules.';
//         } else {
//           _error = error.message ?? 'Could not save service.';
//         }
//       });
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _error = 'Could not save service: $error';
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
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _experienceController.dispose();
//     _hourlyChargeController.dispose();
//     _serviceAreaController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = _uniqueServiceCategories;

//     final selectedCategory = categories[_selectedCategoryIndex];

//     return PopScope(
//       canPop: !_saving,
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         appBar: AppBar(
//           title: Text(
//             isEditing ? 'Edit Service' : 'Add New Service',
//           ),
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             padding: const EdgeInsets.all(22),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isEditing
//                         ? 'Update your service'
//                         : 'What service do you offer?',
//                     style: const TextStyle(
//                       color: AppColors.darkBg,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     isEditing
//                         ? 'Make changes and save your service.'
//                         : 'Add clear details so users understand exactly what you provide.',
//                     style: const TextStyle(
//                       color: AppColors.textGrey,
//                       fontSize: 14,
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 26),

//                   // Dropdown ki internal value unique index hai.
//                   // Screen aur Firestore mein category name hi use hoga.
//                   DropdownButtonFormField<int>(
//                     key: ValueKey<int>(
//                       _selectedCategoryIndex,
//                     ),
//                     // ignore: deprecated_member_use
//                     value: _selectedCategoryIndex,
//                     isExpanded: true,
//                     decoration: InputDecoration(
//                       labelText: 'Service Category',
//                       prefixIcon: Icon(
//                         selectedCategory.icon,
//                       ),
//                     ),
//                     items: List.generate(
//                       categories.length,
//                       (index) {
//                         final category = categories[index];

//                         return DropdownMenuItem<int>(
//                           value: index,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 category.icon,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 10),
//                               Text(
//                                 category.name.trim(),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     onChanged: _saving
//                         ? null
//                         : (index) {
//                             if (index == null) return;

//                             setState(() {
//                               _selectedCategoryIndex = index;
//                               _selectedCategory = categories[index].name.trim();
//                             });
//                           },
//                     validator: (index) {
//                       if (index == null ||
//                           index < 0 ||
//                           index >= categories.length) {
//                         return 'Please select a service category';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _titleController,
//                     enabled: !_saving,
//                     textCapitalization: TextCapitalization.words,
//                     textInputAction: TextInputAction.next,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Title',
//                       hintText: 'Example: Home Electrical Wiring',
//                       prefixIcon: Icon(
//                         Icons.home_repair_service_outlined,
//                       ),
//                     ),
//                     validator: (value) {
//                       final title = value?.trim() ?? '';

//                       if (title.isEmpty) {
//                         return 'Please enter a service title';
//                       }

//                       if (title.length < 4) {
//                         return 'Service title is too short';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _descriptionController,
//                     enabled: !_saving,
//                     minLines: 3,
//                     maxLines: 5,
//                     maxLength: 350,
//                     textCapitalization: TextCapitalization.sentences,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Description',
//                       hintText: 'Describe what is included in this service',
//                       alignLabelWithHint: true,
//                     ),
//                     validator: (value) {
//                       final description = value?.trim() ?? '';

//                       if (description.isEmpty) {
//                         return 'Please enter a service description';
//                       }

//                       if (description.length < 15) {
//                         return 'Description must contain at least 15 characters';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _experienceController,
//                           enabled: !_saving,
//                           keyboardType: TextInputType.number,
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             labelText: 'Experience',
//                             hintText: 'Years',
//                             prefixIcon: Icon(
//                               Icons.work_history_outlined,
//                             ),
//                           ),
//                           validator: (value) {
//                             final years = int.tryParse(
//                               value?.trim() ?? '',
//                             );

//                             if (years == null) {
//                               return 'Required';
//                             }

//                             if (years < 0 || years > 60) {
//                               return 'Invalid';
//                             }

//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _hourlyChargeController,
//                           enabled: !_saving,
//                           keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             labelText: 'Hourly Charge',
//                             hintText: 'PKR',
//                             prefixIcon: Icon(
//                               Icons.payments_outlined,
//                             ),
//                           ),
//                           validator: (value) {
//                             final charge = double.tryParse(
//                               (value ?? '').trim().replaceAll(',', ''),
//                             );

//                             if (charge == null) {
//                               return 'Required';
//                             }

//                             if (charge <= 0) {
//                               return 'Invalid';
//                             }

//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _serviceAreaController,
//                     enabled: !_saving,
//                     textCapitalization: TextCapitalization.words,
//                     textInputAction: TextInputAction.done,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Area',
//                       hintText: 'Example: Johar Town, Lahore',
//                       prefixIcon: Icon(
//                         Icons.location_on_outlined,
//                       ),
//                     ),
//                     validator: (value) {
//                       final area = value?.trim() ?? '';

//                       if (area.isEmpty) {
//                         return 'Please enter your service area';
//                       }

//                       if (area.length < 4) {
//                         return 'Enter a valid service area';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 18),
//                   Container(
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF8FAFC),
//                       borderRadius: BorderRadius.circular(13),
//                       border: Border.all(
//                         color: AppColors.cardDark,
//                       ),
//                     ),
//                     child: SwitchListTile(
//                       contentPadding: EdgeInsets.zero,
//                       value: _isActive,
//                       // ignore: deprecated_member_use
//                       activeColor: AppColors.success,
//                       title: const Text(
//                         'Active Service',
//                         style: TextStyle(
//                           color: AppColors.darkBg,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       subtitle: Text(
//                         _isActive
//                             ? 'Users can find this service when your profile is live.'
//                             : 'This service will remain hidden from users.',
//                         style: const TextStyle(
//                           color: AppColors.textGrey,
//                           fontSize: 12,
//                         ),
//                       ),
//                       onChanged: _saving
//                           ? null
//                           : (value) {
//                               setState(() {
//                                 _isActive = value;
//                               });
//                             },
//                     ),
//                   ),
//                   if (_error != null) ...[
//                     const SizedBox(height: 16),
//                     ErrorMessageBox(
//                       message: _error!,
//                     ),
//                   ],
//                   const SizedBox(height: 26),
//                   PrimaryButton(
//                     label: isEditing ? 'Update Service' : 'Add Service',
//                     icon: isEditing ? Icons.save_outlined : Icons.add,
//                     onPressed: _saveService,
//                     loading: _saving,
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:service_hub/new/appuser.dart';
// import 'package:service_hub/new/firestore_service.dart';
// import 'package:service_hub/new/primary_buton.dart';
// import 'package:service_hub/new/user_model.dart'
//     hide ProviderService, ProviderProfile;

// import '../../theme/app_theme.dart' hide kServiceCategories, ServiceCategory;

// class AddEditServiceScreen extends StatefulWidget {
//   final String providerId;
//   final ProviderProfile providerProfile;
//   final ProviderService? existingService;

//   const AddEditServiceScreen({
//     super.key,
//     required this.providerId,
//     required this.providerProfile,
//     this.existingService, required ProviderService service,
//   });

//   @override
//   State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
// }

// class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   final TextEditingController _titleController = TextEditingController();

//   final TextEditingController _descriptionController = TextEditingController();

//   final TextEditingController _experienceController = TextEditingController();

//   final TextEditingController _hourlyChargeController = TextEditingController();

//   final TextEditingController _serviceAreaController = TextEditingController();

//   late String _selectedCategory;
//   late int _selectedCategoryIndex;

//   bool _isActive = true;
//   bool _saving = false;
//   String? _error;

//   bool get isEditing => widget.existingService != null;
//   List<ServiceCategory> get _uniqueServiceCategories {
//     final Map<String, ServiceCategory> uniqueCategories = {};

//     for (final category in kServiceCategories) {
//       final cleanName = category.name.trim();

//       if (cleanName.isNotEmpty) {
//         uniqueCategories.putIfAbsent(
//           cleanName,
//           () => category,
//         );
//       }
//     }

//     return uniqueCategories.values.toList(growable: false);
//   }

//   @override
//   void initState() {
//     super.initState();

//     final service = widget.existingService;
//     final categories = _uniqueServiceCategories;

//     final profileCategory = widget.providerProfile.mainService.trim();

//     final requestedCategory = (service?.category.trim().isNotEmpty == true)
//         ? service!.category.trim()
//         : profileCategory;

//     final foundIndex = categories.indexWhere(
//       (category) =>
//           category.name.trim().toLowerCase() == requestedCategory.toLowerCase(),
//     );

//     _selectedCategoryIndex = foundIndex >= 0 ? foundIndex : 0;

//     _selectedCategory = categories[_selectedCategoryIndex].name.trim();

//     _titleController.text = service?.title ?? '';

//     _descriptionController.text = service?.description ?? '';

//     _experienceController.text =
//         service == null ? '' : service.experienceYears.toString();

//     _hourlyChargeController.text =
//         service == null ? '' : service.hourlyCharge.toStringAsFixed(0);

//     _serviceAreaController.text =
//         service?.serviceArea ?? widget.providerProfile.address;

//     _isActive = service?.isActive ?? true;
//   }

//   Future<void> _saveService() async {
//     if (_saving) return;

//     FocusManager.instance.primaryFocus?.unfocus();

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     final experience = int.tryParse(
//           _experienceController.text.trim(),
//         ) ??
//         0;

//     final hourlyCharge = double.tryParse(
//           _hourlyChargeController.text.trim().replaceAll(',', ''),
//         ) ??
//         0;

//     final service = ProviderService(
//       id: widget.existingService?.id ?? '',
//       providerId: widget.providerId.trim().isNotEmpty
//           ? widget.providerId.trim()
//           : widget.providerProfile.uid,
//       providerName: widget.providerProfile.name,
//       category: _selectedCategory,
//       title: _titleController.text.trim(),
//       description: _descriptionController.text.trim(),
//       experienceYears: experience,
//       hourlyCharge: hourlyCharge,
//       serviceArea: _serviceAreaController.text.trim(),
//       isActive: _isActive,
//       createdAt: widget.existingService?.createdAt,
//     );

//     setState(() {
//       _saving = true;
//       _error = null;
//     });

//     try {
//       if (isEditing) {
//         await FirestoreService.instance.updateProviderService(
//           service,
//           originalService: widget.existingService,
//         );
//       } else {
//         await FirestoreService.instance.addProviderService(service);
//       }

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             isEditing
//                 ? 'Service updated successfully'
//                 : 'Service added successfully',
//           ),
//           backgroundColor: AppColors.success,
//         ),
//       );

//       Navigator.of(context).pop(true);
//     } on FirebaseException catch (error) {
//       if (!mounted) return;

//       setState(() {
//         if (error.code == 'permission-denied') {
//           _error = 'Permission denied. Check your Firestore security rules.';
//         } else {
//           _error = error.message ?? 'Could not save service.';
//         }
//       });
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _error = 'Could not save service: $error';
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
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _experienceController.dispose();
//     _hourlyChargeController.dispose();
//     _serviceAreaController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final categories = _uniqueServiceCategories;

//     final selectedCategory = categories[_selectedCategoryIndex];

//     return PopScope(
//       canPop: !_saving,
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         appBar: AppBar(
//           title: Text(
//             isEditing ? 'Edit Service' : 'Add New Service',
//           ),
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             padding: const EdgeInsets.all(22),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isEditing
//                         ? 'Update your service'
//                         : 'What service do you offer?',
//                     style: const TextStyle(
//                       color: AppColors.darkBg,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     isEditing
//                         ? 'Make changes and save your service.'
//                         : 'Add clear details so users understand exactly what you provide.',
//                     style: const TextStyle(
//                       color: AppColors.textGrey,
//                       fontSize: 14,
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 26),

//                   // Dropdown ki internal value unique index hai.
//                   // Screen aur Firestore mein category name hi use hoga.
//                   DropdownButtonFormField<int>(
//                     key: ValueKey<int>(
//                       _selectedCategoryIndex,
//                     ),
//                     // ignore: deprecated_member_use
//                     value: _selectedCategoryIndex,
//                     isExpanded: true,
//                     decoration: InputDecoration(
//                       labelText: 'Service Category',
//                       prefixIcon: Icon(
//                         selectedCategory.icon,
//                       ),
//                     ),
//                     items: List.generate(
//                       categories.length,
//                       (index) {
//                         final category = categories[index];

//                         return DropdownMenuItem<int>(
//                           value: index,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 category.icon,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 10),
//                               Text(
//                                 category.name.trim(),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                     onChanged: _saving
//                         ? null
//                         : (index) {
//                             if (index == null) return;

//                             setState(() {
//                               _selectedCategoryIndex = index;
//                               _selectedCategory = categories[index].name.trim();
//                             });
//                           },
//                     validator: (index) {
//                       if (index == null ||
//                           index < 0 ||
//                           index >= categories.length) {
//                         return 'Please select a service category';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _titleController,
//                     enabled: !_saving,
//                     textCapitalization: TextCapitalization.words,
//                     textInputAction: TextInputAction.next,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Title',
//                       hintText: 'Example: Home Electrical Wiring',
//                       prefixIcon: Icon(
//                         Icons.home_repair_service_outlined,
//                       ),
//                     ),
//                     validator: (value) {
//                       final title = value?.trim() ?? '';

//                       if (title.isEmpty) {
//                         return 'Please enter a service title';
//                       }

//                       if (title.length < 4) {
//                         return 'Service title is too short';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _descriptionController,
//                     enabled: !_saving,
//                     minLines: 3,
//                     maxLines: 5,
//                     maxLength: 350,
//                     textCapitalization: TextCapitalization.sentences,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Description',
//                       hintText: 'Describe what is included in this service',
//                       alignLabelWithHint: true,
//                     ),
//                     validator: (value) {
//                       final description = value?.trim() ?? '';

//                       if (description.isEmpty) {
//                         return 'Please enter a service description';
//                       }

//                       if (description.length < 15) {
//                         return 'Description must contain at least 15 characters';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _experienceController,
//                           enabled: !_saving,
//                           keyboardType: TextInputType.number,
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             labelText: 'Experience',
//                             hintText: 'Years',
//                             prefixIcon: Icon(
//                               Icons.work_history_outlined,
//                             ),
//                           ),
//                           validator: (value) {
//                             final years = int.tryParse(
//                               value?.trim() ?? '',
//                             );

//                             if (years == null) {
//                               return 'Required';
//                             }

//                             if (years < 0 || years > 60) {
//                               return 'Invalid';
//                             }

//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _hourlyChargeController,
//                           enabled: !_saving,
//                           keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             labelText: 'Hourly Charge',
//                             hintText: 'PKR',
//                             prefixIcon: Icon(
//                               Icons.payments_outlined,
//                             ),
//                           ),
//                           validator: (value) {
//                             final charge = double.tryParse(
//                               (value ?? '').trim().replaceAll(',', ''),
//                             );

//                             if (charge == null) {
//                               return 'Required';
//                             }

//                             if (charge <= 0) {
//                               return 'Invalid';
//                             }

//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   TextFormField(
//                     controller: _serviceAreaController,
//                     enabled: !_saving,
//                     textCapitalization: TextCapitalization.words,
//                     textInputAction: TextInputAction.done,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Area',
//                       hintText: 'Example: Johar Town, Lahore',
//                       prefixIcon: Icon(
//                         Icons.location_on_outlined,
//                       ),
//                     ),
//                     validator: (value) {
//                       final area = value?.trim() ?? '';

//                       if (area.isEmpty) {
//                         return 'Please enter your service area';
//                       }

//                       if (area.length < 4) {
//                         return 'Enter a valid service area';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 18),
//                   Container(
//                     padding: const EdgeInsets.all(15),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF8FAFC),
//                       borderRadius: BorderRadius.circular(13),
//                       border: Border.all(
//                         color: AppColors.cardDark,
//                       ),
//                     ),
//                     child: SwitchListTile(
//                       contentPadding: EdgeInsets.zero,
//                       value: _isActive,
//                       // ignore: deprecated_member_use
//                       activeColor: AppColors.success,
//                       title: const Text(
//                         'Active Service',
//                         style: TextStyle(
//                           color: AppColors.darkBg,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       subtitle: Text(
//                         _isActive
//                             ? 'Users can find this service when your profile is live.'
//                             : 'This service will remain hidden from users.',
//                         style: const TextStyle(
//                           color: AppColors.textGrey,
//                           fontSize: 12,
//                         ),
//                       ),
//                       onChanged: _saving
//                           ? null
//                           : (value) {
//                               setState(() {
//                                 _isActive = value;
//                               });
//                             },
//                     ),
//                   ),
//                   if (_error != null) ...[
//                     const SizedBox(height: 16),
//                     ErrorMessageBox(
//                       message: _error!,
//                     ),
//                   ],
//                   const SizedBox(height: 26),
//                   PrimaryButton(
//                     label: isEditing ? 'Update Service' : 'Add Service',
//                     icon: isEditing ? Icons.save_outlined : Icons.add,
//                     onPressed: _saveService,
//                     loading: _saving,
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/user_model.dart'
    hide ProviderService, ProviderProfile;

import '../../theme/app_theme.dart' hide kServiceCategories, ServiceCategory;

class AddEditServiceScreen extends StatefulWidget {
  final String providerId;
  final ProviderProfile providerProfile;
  final ProviderService? existingService;

  const AddEditServiceScreen({
    super.key,
    required this.providerId,
    required this.providerProfile,
    this.existingService, required ProviderService service,
  });

  @override
  State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
}

class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final TextEditingController _experienceController = TextEditingController();

  final TextEditingController _hourlyChargeController = TextEditingController();

  final TextEditingController _serviceAreaController = TextEditingController();

  late String _selectedCategory;
  late int _selectedCategoryIndex;

  bool _isActive = true;
  bool _saving = false;
  String? _error;

  bool get isEditing => widget.existingService != null;
  List<ServiceCategory> get _uniqueServiceCategories {
    final Map<String, ServiceCategory> uniqueCategories = {};

    for (final category in kServiceCategories) {
      final cleanName = category.name.trim();

      if (cleanName.isNotEmpty) {
        uniqueCategories.putIfAbsent(
          cleanName,
          () => category,
        );
      }
    }

    return uniqueCategories.values.toList(growable: false);
  }

  @override
  void initState() {
    super.initState();

    final service = widget.existingService;
    final categories = _uniqueServiceCategories;

    final profileCategory = widget.providerProfile.mainService.trim();

    final requestedCategory = (service?.category.trim().isNotEmpty == true)
        ? service!.category.trim()
        : profileCategory;

    final foundIndex = categories.indexWhere(
      (category) =>
          category.name.trim().toLowerCase() == requestedCategory.toLowerCase(),
    );

    _selectedCategoryIndex = foundIndex >= 0 ? foundIndex : 0;

    _selectedCategory = categories[_selectedCategoryIndex].name.trim();

    _titleController.text = service?.title ?? '';

    _descriptionController.text = service?.description ?? '';

    _experienceController.text =
        service == null ? '' : service.experienceYears.toString();

    _hourlyChargeController.text =
        service == null ? '' : service.hourlyCharge.toStringAsFixed(0);

    _serviceAreaController.text =
        service?.serviceArea ?? widget.providerProfile.address;

    _isActive = service?.isActive ?? true;
  }

  Future<void> _saveService() async {
    if (_saving) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final experience = int.tryParse(
          _experienceController.text.trim(),
        ) ??
        0;

    final hourlyCharge = double.tryParse(
          _hourlyChargeController.text.trim().replaceAll(',', ''),
        ) ??
        0;

    final service = ProviderService(
      id: widget.existingService?.id ?? '',
      providerId: widget.providerId.trim().isNotEmpty
          ? widget.providerId.trim()
          : widget.providerProfile.uid,
      providerName: widget.providerProfile.name,
      category: _selectedCategory,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      experienceYears: experience,
      hourlyCharge: hourlyCharge,
      serviceArea: _serviceAreaController.text.trim(),
      isActive: _isActive,
      createdAt: widget.existingService?.createdAt,
    );

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      if (isEditing) {
        await FirestoreService.instance.updateProviderService(
          service,
          originalService: widget.existingService,
        );
      } else {
        await FirestoreService.instance.addProviderService(service);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Service updated successfully'
                : 'Service added successfully',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop(true);
    } on FirebaseException catch (error) {
      if (!mounted) return;

      setState(() {
        if (error.code == 'permission-denied') {
          _error = 'Permission denied. Check your Firestore security rules.';
        } else {
          _error = error.message ?? 'Could not save service.';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not save service: $error';
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
    _experienceController.dispose();
    _hourlyChargeController.dispose();
    _serviceAreaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _uniqueServiceCategories;

    final selectedCategory = categories[_selectedCategoryIndex];

    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(
            isEditing ? 'Edit Service' : 'Add New Service',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(22),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing
                        ? 'Update your service'
                        : 'What service do you offer?',
                    style: const TextStyle(
                      color: AppColors.darkBg,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEditing
                        ? 'Make changes and save your service.'
                        : 'Add clear details so users understand exactly what you provide.',
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 26),

                  // Dropdown ki internal value unique index hai.
                  // Screen aur Firestore mein category name hi use hoga.
                  DropdownButtonFormField<int>(
                    key: ValueKey<int>(
                      _selectedCategoryIndex,
                    ),
                    // ignore: deprecated_member_use
                    value: _selectedCategoryIndex,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Service Category',
                      prefixIcon: Icon(
                        selectedCategory.icon,
                      ),
                    ),
                    items: List.generate(
                      categories.length,
                      (index) {
                        final category = categories[index];

                        return DropdownMenuItem<int>(
                          value: index,
                          child: Row(
                            children: [
                              Icon(
                                category.icon,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                category.name.trim(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    onChanged: _saving
                        ? null
                        : (index) {
                            if (index == null) return;

                            setState(() {
                              _selectedCategoryIndex = index;
                              _selectedCategory = categories[index].name.trim();
                            });
                          },
                    validator: (index) {
                      if (index == null ||
                          index < 0 ||
                          index >= categories.length) {
                        return 'Please select a service category';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Service Title',
                      hintText: 'Example: Home Electrical Wiring',
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
                        return 'Service title is too short';
                      }

                      return null;
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
                      hintText: 'Describe what is included in this service',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      final description = value?.trim() ?? '';

                      if (description.isEmpty) {
                        return 'Please enter a service description';
                      }

                      if (description.length < 15) {
                        return 'Description must contain at least 15 characters';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _experienceController,
                          enabled: !_saving,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Experience',
                            hintText: 'Years',
                            prefixIcon: Icon(
                              Icons.work_history_outlined,
                            ),
                          ),
                          validator: (value) {
                            final years = int.tryParse(
                              value?.trim() ?? '',
                            );

                            if (years == null) {
                              return 'Required';
                            }

                            if (years < 0 || years > 60) {
                              return 'Invalid';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _hourlyChargeController,
                          enabled: !_saving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Hourly Charge',
                            hintText: 'PKR',
                            prefixIcon: Icon(
                              Icons.payments_outlined,
                            ),
                          ),
                          validator: (value) {
                            final charge = double.tryParse(
                              (value ?? '').trim().replaceAll(',', ''),
                            );

                            if (charge == null) {
                              return 'Required';
                            }

                            if (charge <= 0) {
                              return 'Invalid';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _serviceAreaController,
                    enabled: !_saving,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Service Area',
                      hintText: 'Example: Johar Town, Lahore',
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                      ),
                    ),
                    validator: (value) {
                      final area = value?.trim() ?? '';

                      if (area.isEmpty) {
                        return 'Please enter your service area';
                      }

                      if (area.length < 4) {
                        return 'Enter a valid service area';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: AppColors.cardDark,
                      ),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isActive,
                      // ignore: deprecated_member_use
                      activeColor: AppColors.success,
                      title: const Text(
                        'Active Service',
                        style: TextStyle(
                          color: AppColors.darkBg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        _isActive
                            ? 'Users can find this service when your profile is live.'
                            : 'This service will remain hidden from users.',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                        ),
                      ),
                      onChanged: _saving
                          ? null
                          : (value) {
                              setState(() {
                                _isActive = value;
                              });
                            },
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    ErrorMessageBox(
                      message: _error!,
                    ),
                  ],
                  const SizedBox(height: 26),
                  PrimaryButton(
                    label: isEditing ? 'Update Service' : 'Add Service',
                    icon: isEditing ? Icons.save_outlined : Icons.add,
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