// import 'package:flutter/material.dart';
// import 'package:service_hub/new/appuser.dart';
// import 'package:service_hub/new/firestore_service.dart';
// import 'package:service_hub/new/primary_buton.dart';

// import '../../theme/app_theme.dart';

// class AddEditServiceScreen extends StatefulWidget {
//   final String providerId;
//   final ProviderService? service;

//   const AddEditServiceScreen({
//     super.key,
//     required this.providerId,
//     this.service,
//   });

//   bool get isEditing => service != null;

//   @override
//   State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
// }

// class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   late final TextEditingController _titleController;
//   late final TextEditingController _descriptionController;
//   late final TextEditingController _chargeController;
//   late final TextEditingController _experienceController;
//   late final TextEditingController _areaController;

//   late String _selectedCategory;

//   bool _saving = false;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();

//     final service = widget.service;

//     _titleController = TextEditingController(
//       text: service?.title ?? '',
//     );

//     _descriptionController = TextEditingController(
//       text: service?.description ?? '',
//     );

//     _chargeController = TextEditingController(
//       text: service == null ? '' : service.hourlyCharge.toStringAsFixed(0),
//     );

//     _experienceController = TextEditingController(
//       text: service == null ? '' : service.experienceYears.toString(),
//     );

//     _areaController = TextEditingController(
//       text: service?.serviceArea ?? '',
//     );

//     final categoryExists = kServiceCategories.any(
//       (category) => category.name == service?.category,
//     );

//     _selectedCategory =
//         categoryExists ? service!.category : kServiceCategories.first.name;
//   }

//   Future<void> _saveService() async {
//     if (_saving) return;

//     FocusManager.instance.primaryFocus?.unfocus();

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _saving = true;
//       _error = null;
//     });

//     final hourlyCharge = double.parse(
//       _chargeController.text.trim(),
//     );

//     final experienceYears = int.parse(
//       _experienceController.text.trim(),
//     );

//     final existingService = widget.service;

//     final service = ProviderService(
//       id: existingService?.id ?? '',
//       providerId: widget.providerId,
//       title: _titleController.text.trim(),
//       category: _selectedCategory,
//       description: _descriptionController.text.trim(),
//       hourlyCharge: hourlyCharge,
//       experienceYears: experienceYears,
//       serviceArea: _areaController.text.trim(),
//       createdAt: existingService?.createdAt ?? DateTime.now(),
//       providerName: '',
//     );

//     try {
//       if (widget.isEditing) {
//         await FirestoreService.instance.updateProviderService(
//           service,
//         );
//       } else {
//         await FirestoreService.instance.createProviderService(
//           service,
//         );
//       }

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             widget.isEditing
//                 ? 'Service updated successfully.'
//                 : 'Service added successfully.',
//           ),
//           backgroundColor: AppColors.success,
//         ),
//       );

//       Navigator.of(context).pop(true);
//     } catch (_) {
//       if (!mounted) return;

//       setState(() {
//         _error = widget.isEditing
//             ? 'Could not update service. Please try again.'
//             : 'Could not add service. Please try again.';
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
//     _chargeController.dispose();
//     _experienceController.dispose();
//     _areaController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pageTitle = widget.isEditing ? 'Edit Service' : 'Add New Service';

//     return PopScope(
//       canPop: !_saving,
//       child: Scaffold(
//         backgroundColor: AppColors.cardDark,
//         appBar: AppBar(
//           title: Text(pageTitle),
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             padding: const EdgeInsets.all(18),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _HeaderCard(
//                     isEditing: widget.isEditing,
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Service Details',
//                     style: TextStyle(
//                       color: AppColors.darkBg,
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   TextFormField(
//                     controller: _titleController,
//                     enabled: !_saving,
//                     textCapitalization: TextCapitalization.words,
//                     textInputAction: TextInputAction.next,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Title',
//                       hintText: 'e.g. Home Electrical Repair',
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
//                         return 'Title must contain at least 4 characters';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     // ignore: deprecated_member_use
//                     value: _selectedCategory,
//                     isExpanded: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Category',
//                       prefixIcon: Icon(
//                         Icons.category_outlined,
//                       ),
//                     ),
//                     items: kServiceCategories.map(
//                       (category) {
//                         return DropdownMenuItem<String>(
//                           value: category.name,
//                           child: Row(
//                             children: [
//                               Icon(
//                                 category.icon,
//                                 size: 19,
//                               ),
//                               const SizedBox(width: 10),
//                               Text(category.name),
//                             ],
//                           ),
//                         );
//                       },
//                     ).toList(),
//                     onChanged: _saving
//                         ? null
//                         : (value) {
//                             if (value == null) return;

//                             setState(() {
//                               _selectedCategory = value;
//                             });
//                           },
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
//                       hintText:
//                           'Explain what work you provide in this service.',
//                       alignLabelWithHint: true,
//                     ),
//                     validator: (value) {
//                       final description = value?.trim() ?? '';

//                       if (description.isEmpty) {
//                         return 'Please enter service details';
//                       }

//                       if (description.length < 15) {
//                         return 'Description must contain at least 15 characters';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 18),
//                   const Text(
//                     'Pricing & Experience',
//                     style: TextStyle(
//                       color: AppColors.darkBg,
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _chargeController,
//                           enabled: !_saving,
//                           keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             labelText: 'Hourly Charge',
//                             hintText: '1000',
//                             prefixText: 'PKR ',
//                             prefixIcon: Icon(
//                               Icons.payments_outlined,
//                             ),
//                           ),
//                           validator: (value) {
//                             final amount = double.tryParse(
//                               value?.trim() ?? '',
//                             );

//                             if (amount == null || amount <= 0) {
//                               return 'Enter valid charge';
//                             }

//                             if (amount > 100000) {
//                               return 'Enter a realistic charge';
//                             }

//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _experienceController,
//                           enabled: !_saving,
//                           keyboardType: TextInputType.number,
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             labelText: 'Experience',
//                             hintText: '3',
//                             suffixText: 'years',
//                             prefixIcon: Icon(
//                               Icons.workspace_premium_outlined,
//                             ),
//                           ),
//                           validator: (value) {
//                             final years = int.tryParse(
//                               value?.trim() ?? '',
//                             );

//                             if (years == null || years < 0) {
//                               return 'Enter valid years';
//                             }

//                             if (years > 70) {
//                               return 'Enter valid years';
//                             }

//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 18),
//                   const Text(
//                     'Service Area',
//                     style: TextStyle(
//                       color: AppColors.darkBg,
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   TextFormField(
//                     controller: _areaController,
//                     enabled: !_saving,
//                     textCapitalization: TextCapitalization.words,
//                     textInputAction: TextInputAction.done,
//                     decoration: const InputDecoration(
//                       labelText: 'Area / City',
//                       hintText: 'e.g. Johar Town, Lahore',
//                       prefixIcon: Icon(
//                         Icons.location_on_outlined,
//                       ),
//                     ),
//                     validator: (value) {
//                       final area = value?.trim() ?? '';

//                       if (area.isEmpty) {
//                         return 'Please enter your service area';
//                       }

//                       if (area.length < 3) {
//                         return 'Enter a valid service area';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   const InfoMessageBox(
//                     message:
//                         'Your service becomes visible to users only when your provider profile is Live.',
//                   ),
//                   if (_error != null) ...[
//                     const SizedBox(height: 16),
//                     ErrorMessageBox(
//                       message: _error!,
//                     ),
//                   ],
//                   const SizedBox(height: 25),
//                   PrimaryButton(
//                     label: widget.isEditing ? 'Save Changes' : 'Add Service',
//                     icon: widget.isEditing ? Icons.save_outlined : Icons.add,
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

// class _HeaderCard extends StatelessWidget {
//   final bool isEditing;

//   const _HeaderCard({
//     required this.isEditing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.darkBg,
//         borderRadius: BorderRadius.circular(17),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 57,
//             height: 57,
//             decoration: BoxDecoration(
//               color: AppColors.primaryYellow,
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Icon(
//               isEditing ? Icons.edit_outlined : Icons.add_business_outlined,
//               color: AppColors.darkBg,
//               size: 30,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isEditing ? 'Update your service' : 'Add a new service',
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 const Text(
//                   'Clear details help users choose the right provider.',
//                   style: TextStyle(
//                     color: AppColors.textGrey,
//                     fontSize: 12,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:service_hub/new/appuser.dart';
// import 'package:service_hub/new/firestore_service.dart';
// import 'package:service_hub/new/primary_buton.dart';

// import '../../theme/app_theme.dart';

// class AddEditServiceScreen extends StatefulWidget {
//   final String providerId;
//   final ProviderService? service;

//   const AddEditServiceScreen({
//     super.key,
//     required this.providerId,
//     this.service,
//     required ProviderProfile providerProfile,
//     required ProviderService existingService,
//   });

//   bool get isEditing => service != null;

//   @override
//   State<AddEditServiceScreen> createState() => _AddEditServiceScreenState();
// }

// class _AddEditServiceScreenState extends State<AddEditServiceScreen> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   late final TextEditingController _titleController;
//   late final TextEditingController _descriptionController;
//   late final TextEditingController _chargeController;
//   late final TextEditingController _experienceController;
//   late final TextEditingController _areaController;

//   late String _selectedCategory;
//   late int _selectedCategoryIndex;

//   bool _saving = false;
//   String? _error;

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

//     final service = widget.service;
//     final categories = _uniqueServiceCategories;

//     _titleController = TextEditingController(
//       text: service?.title ?? '',
//     );

//     _descriptionController = TextEditingController(
//       text: service?.description ?? '',
//     );

//     _chargeController = TextEditingController(
//       text: service == null ? '' : service.hourlyCharge.toStringAsFixed(0),
//     );

//     _experienceController = TextEditingController(
//       text: service == null ? '' : service.experienceYears.toString(),
//     );

//     _areaController = TextEditingController(
//       text: service?.serviceArea ?? '',
//     );

//     final existingCategory = service?.category.trim();

//     final foundIndex = categories.indexWhere(
//       (category) => category.name.trim() == existingCategory,
//     );

//     _selectedCategoryIndex = foundIndex >= 0 ? foundIndex : 0;

//     _selectedCategory = categories[_selectedCategoryIndex].name.trim();
//   }

//   Future<void> _saveService() async {
//     if (_saving) return;

//     FocusManager.instance.primaryFocus?.unfocus();

//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _saving = true;
//       _error = null;
//     });

//     final hourlyCharge = double.parse(
//       _chargeController.text.trim(),
//     );

//     final experienceYears = int.parse(
//       _experienceController.text.trim(),
//     );

//     final existingService = widget.service;

//     final service = ProviderService(
//       id: existingService?.id ?? '',
//       providerId: widget.providerId,
//       title: _titleController.text.trim(),
//       category: _selectedCategory,
//       description: _descriptionController.text.trim(),
//       hourlyCharge: hourlyCharge,
//       experienceYears: experienceYears,
//       serviceArea: _areaController.text.trim(),
//       createdAt: existingService?.createdAt ?? DateTime.now(),
//       providerName: '',
//     );

//     try {
//       if (widget.isEditing) {
//         await FirestoreService.instance.updateProviderService(
//           service,
//         );
//       } else {
//         await FirestoreService.instance.createProviderService(
//           service,
//         );
//       }

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             widget.isEditing
//                 ? 'Service updated successfully.'
//                 : 'Service added successfully.',
//           ),
//           backgroundColor: AppColors.success,
//         ),
//       );

//       Navigator.of(context).pop(true);
//     } catch (_) {
//       if (!mounted) return;

//       setState(() {
//         _error = widget.isEditing
//             ? 'Could not update service. Please try again.'
//             : 'Could not add service. Please try again.';
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
//     _chargeController.dispose();
//     _experienceController.dispose();
//     _areaController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final pageTitle = widget.isEditing ? 'Edit Service' : 'Add New Service';

//     final categories = _uniqueServiceCategories;

//     return PopScope(
//       canPop: !_saving,
//       child: Scaffold(
//         backgroundColor: AppColors.cardDark,
//         appBar: AppBar(
//           title: Text(pageTitle),
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
//             padding: const EdgeInsets.all(18),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _HeaderCard(
//                     isEditing: widget.isEditing,
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Service Details',
//                     style: TextStyle(
//                       color: AppColors.darkBg,
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   TextFormField(
//                     controller: _titleController,
//                     enabled: !_saving,
//                     textCapitalization: TextCapitalization.words,
//                     textInputAction: TextInputAction.next,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Title',
//                       hintText: 'e.g. Home Electrical Repair',
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
//                         return 'Title must contain at least 4 characters';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 16),

//                   // Internal value ab unique index hai.
//                   DropdownButtonFormField<int>(
//                     key: ValueKey<int>(_selectedCategoryIndex),
//                     // ignore: deprecated_member_use
//                     value: _selectedCategoryIndex,
//                     isExpanded: true,
//                     decoration: const InputDecoration(
//                       labelText: 'Service Category',
//                       prefixIcon: Icon(
//                         Icons.category_outlined,
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
//                                 size: 19,
//                               ),
//                               const SizedBox(width: 10),
//                               Text(category.name.trim()),
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
//                       hintText:
//                           'Explain what work you provide in this service.',
//                       alignLabelWithHint: true,
//                     ),
//                     validator: (value) {
//                       final description = value?.trim() ?? '';

//                       if (description.isEmpty) {
//                         return 'Please enter service details';
//                       }

//                       if (description.length < 15) {
//                         return 'Description must contain at least 15 characters';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 18),
//                   const Text(
//                     'Pricing & Experience',
//                     style: TextStyle(
//                       color: AppColors.darkBg,
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: _chargeController,
//                           enabled: !_saving,
//                           keyboardType: const TextInputType.numberWithOptions(
//                             decimal: true,
//                           ),
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             labelText: 'Hourly Charge',
//                             hintText: '1000',
//                             prefixText: 'PKR ',
//                             prefixIcon: Icon(
//                               Icons.payments_outlined,
//                             ),
//                           ),
//                           validator: (value) {
//                             final amount = double.tryParse(
//                               value?.trim() ?? '',
//                             );

//                             if (amount == null || amount <= 0) {
//                               return 'Enter valid charge';
//                             }

//                             if (amount > 100000) {
//                               return 'Enter a realistic charge';
//                             }

//                             return null;
//                           },
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: TextFormField(
//                           controller: _experienceController,
//                           enabled: !_saving,
//                           keyboardType: TextInputType.number,
//                           textInputAction: TextInputAction.next,
//                           decoration: const InputDecoration(
//                             labelText: 'Experience',
//                             hintText: '3',
//                             suffixText: 'years',
//                             prefixIcon: Icon(
//                               Icons.workspace_premium_outlined,
//                             ),
//                           ),
//                           validator: (value) {
//                             final years = int.tryParse(
//                               value?.trim() ?? '',
//                             );

//                             if (years == null || years < 0) {
//                               return 'Enter valid years';
//                             }

//                             if (years > 70) {
//                               return 'Enter valid years';
//                             }

//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 18),
//                   const Text(
//                     'Service Area',
//                     style: TextStyle(
//                       color: AppColors.darkBg,
//                       fontSize: 19,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 14),
//                   TextFormField(
//                     controller: _areaController,
//                     enabled: !_saving,
//                     textCapitalization: TextCapitalization.words,
//                     textInputAction: TextInputAction.done,
//                     decoration: const InputDecoration(
//                       labelText: 'Area / City',
//                       hintText: 'e.g. Johar Town, Lahore',
//                       prefixIcon: Icon(
//                         Icons.location_on_outlined,
//                       ),
//                     ),
//                     validator: (value) {
//                       final area = value?.trim() ?? '';

//                       if (area.isEmpty) {
//                         return 'Please enter your service area';
//                       }

//                       if (area.length < 3) {
//                         return 'Enter a valid service area';
//                       }

//                       return null;
//                     },
//                   ),
//                   const SizedBox(height: 12),
//                   const InfoMessageBox(
//                     message:
//                         'Your service becomes visible to users only when your provider profile is Live.',
//                   ),
//                   if (_error != null) ...[
//                     const SizedBox(height: 16),
//                     ErrorMessageBox(
//                       message: _error!,
//                     ),
//                   ],
//                   const SizedBox(height: 25),
//                   PrimaryButton(
//                     label: widget.isEditing ? 'Save Changes' : 'Add Service',
//                     icon: widget.isEditing ? Icons.save_outlined : Icons.add,
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

// class _HeaderCard extends StatelessWidget {
//   final bool isEditing;

//   const _HeaderCard({
//     required this.isEditing,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.darkBg,
//         borderRadius: BorderRadius.circular(17),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 57,
//             height: 57,
//             decoration: BoxDecoration(
//               color: AppColors.primaryYellow,
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Icon(
//               isEditing ? Icons.edit_outlined : Icons.add_business_outlined,
//               color: AppColors.darkBg,
//               size: 30,
//             ),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   isEditing ? 'Update your service' : 'Add a new service',
//                   style: const TextStyle(
//                     color: AppColors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 const Text(
//                   'Clear details help users choose the right provider.',
//                   style: TextStyle(
//                     color: AppColors.textGrey,
//                     fontSize: 12,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
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
  final ProviderProfile providerProfile;
  final ProviderService? existingService;

  const AddEditServiceScreen({
    super.key,
    required this.providerProfile,
    this.existingService,
    required String providerId,
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

  // Duplicate categories, khas taur par duplicate "More",
  // ko dropdown list se remove karta hai.
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
      providerId: widget.providerProfile.uid,
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
        await FirestoreService.instance.updateProviderService(service);
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
