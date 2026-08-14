// import 'package:flutter/material.dart';
// import 'package:service_hub/model/model.dart';
// import 'package:service_hub/services/fire_Store_services.dart';
// import 'package:service_hub/widgets/intial_avater.dart';
// import '../../theme/app_theme.dart';
// import '../../widgets/common_widgets.dart';

// class EditProfileScreen extends StatefulWidget {
//   final ProviderProfile provider;
//   const EditProfileScreen({super.key, required this.provider});

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   late final _nameCtrl = TextEditingController(text: widget.provider.name);
//   late final _whatsappCtrl =
//       TextEditingController(text: widget.provider.whatsapp);
//   late final _aboutCtrl = TextEditingController(text: widget.provider.about);
//   late String _service = widget.provider.service;
//   bool _saving = false;

//   Future<void> _save() async {
//     setState(() => _saving = true);
//     await FirestoreService.instance.createOrUpdateProvider(ProviderProfile(
//       uid: widget.provider.uid,
//       name: _nameCtrl.text.trim(),
//       whatsapp: _whatsappCtrl.text.trim(),
//       idCardNumber: widget.provider.idCardNumber,
//       service: _service,
//       about: _aboutCtrl.text.trim(),
//       verified: widget.provider.verified,
//       isLive: widget.provider.isLive,
//       totalViews: widget.provider.totalViews,
//       totalContacts: widget.provider.totalContacts,
//       totalBookings: widget.provider.totalBookings,
//       rating: widget.provider.rating,
//       reviewCount: widget.provider.reviewCount,
//     ));
//     if (mounted) Navigator.of(context).pop();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Profile')),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(child: InitialsAvatar(name: _nameCtrl.text, radius: 40)),
//             const SizedBox(height: 24),
//             TextField(
//               controller: _nameCtrl,
//               decoration: const InputDecoration(labelText: 'Full name'),
//               onChanged: (_) => setState(() {}),
//             ),
//             const SizedBox(height: 14),
//             TextField(
//               controller: _whatsappCtrl,
//               keyboardType: TextInputType.phone,
//               decoration: const InputDecoration(labelText: 'WhatsApp number'),
//             ),
//             const SizedBox(height: 14),
//             DropdownButtonFormField<String>(
//               initialValue: _service,
//               decoration: const InputDecoration(labelText: 'Service'),
//               items: kServiceCategories
//                   .map((s) =>
//                       DropdownMenuItem(value: s.name, child: Text(s.name)))
//                   .toList(),
//               onChanged: (v) => setState(() => _service = v!),
//             ),
//             const SizedBox(height: 14),
//             TextField(
//               controller: _aboutCtrl,
//               maxLines: 3,
//               decoration: const InputDecoration(
//                   labelText: 'About', alignLabelWithHint: true),
//             ),
//             const SizedBox(height: 26),
//             PrimaryButton(
//                 label: 'Save Profile', onPressed: _save, loading: _saving),
//           ],
//         ),
//       ),
//     );
//   }
// }
