// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:service_hub/model/model.dart';
// import 'package:service_hub/services/fire_Store_services.dart';
// import 'package:service_hub/user/request_sent.dart';
// import '../../theme/app_theme.dart';
// import '../../widgets/common_widgets.dart';

// class ConfirmBookingScreen extends StatefulWidget {
//   final ProviderProfile provider;
//   const ConfirmBookingScreen({super.key, required this.provider});

//   @override
//   State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
// }

// class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
//   DateTime _date = DateTime.now().add(const Duration(days: 1));
//   TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
//   final _noteCtrl = TextEditingController();
//   bool _saving = false;

//   Future<void> _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _date,
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 90)),
//     );
//     if (picked != null) setState(() => _date = picked);
//   }

//   Future<void> _pickTime() async {
//     final picked = await showTimePicker(context: context, initialTime: _time);
//     if (picked != null) setState(() => _time = picked);
//   }

//   Future<void> _confirm() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//     setState(() => _saving = true);

//     final appUser = await FirestoreService.instance.getUser(user.uid);

//     await FirestoreService.instance.createBooking(BookingRequest(
//       id: '',
//       userId: user.uid,
//       userName: appUser?.name ?? 'User',
//       providerId: widget.provider.uid,
//       providerName: widget.provider.name,
//       service: widget.provider.service,
//       date: _date,
//       // ignore: use_build_context_synchronously
//       time: _time.format(context),
//       note: _noteCtrl.text.trim(),
//     ));
//     await FirestoreService.instance
//         .incrementCounter(widget.provider.uid, 'totalBookings');

//     if (!mounted) return;
//     setState(() => _saving = false);
//     Navigator.of(context).pushReplacement(MaterialPageRoute(
//       builder: (_) => RequestSentScreen(provider: widget.provider),
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Confirm Booking')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.provider.service,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             Text(widget.provider.name,
//                 style: const TextStyle(color: AppColors.textGrey)),
//             const SectionTitle('Date'),
//             OutlinedButton.icon(
//               onPressed: _pickDate,
//               icon: const Icon(Icons.calendar_today, size: 18),
//               label: Text('${_date.day}/${_date.month}/${_date.year}'),
//             ),
//             const SectionTitle('Time'),
//             OutlinedButton.icon(
//               onPressed: _pickTime,
//               icon: const Icon(Icons.access_time, size: 18),
//               label: Text(_time.format(context)),
//             ),
//             const SectionTitle('Note (Optional)'),
//             TextField(
//               controller: _noteCtrl,
//               maxLines: 3,
//               decoration:
//                   const InputDecoration(hintText: 'Enter your note here...'),
//             ),
//             const Spacer(),
//             PrimaryButton(
//                 label: 'Confirm & Contact',
//                 onPressed: _confirm,
//                 loading: _saving),
//           ],
//         ),
//       ),
//     );
//   }
// }
