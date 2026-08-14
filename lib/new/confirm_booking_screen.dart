import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/auth_Service.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/user_booking.dart';
import 'package:service_hub/new/user_model.dart'
    hide ProviderProfile, ProviderService, BookingRequest;
import '../theme/app_theme.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final ProviderProfile provider;
  final ProviderService service;

  const ConfirmBookingScreen({
    super.key,
    required this.provider,
    required this.service,
  });

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _whatsappController = TextEditingController();

  final TextEditingController _noteController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    final user = AuthService.instance.currentUser;

    _nameController.text =
        user?.displayName?.trim().isNotEmpty == true ? user!.displayName! : '';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

    final minute = time.minute.toString().padLeft(2, '0');

    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  bool _isValidPhone(String value) {
    final cleaned = value.replaceAll(
      RegExp(r'[\s\-\(\)]'),
      '',
    );

    return RegExp(r'^\+?[0-9]{8,15}$').hasMatch(cleaned);
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: DateTime(
        now.year,
        now.month,
        now.day,
      ),
      lastDate: DateTime(
        now.year + 1,
      ),
    );

    if (date == null || !mounted) return;

    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (time == null || !mounted) return;

    setState(() {
      _selectedTime = time;
    });
  }

  Future<void> _submitBooking() async {
    if (_submitting) return;

    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      setState(() {
        _error = 'Please select a booking date.';
      });
      return;
    }

    if (_selectedTime == null) {
      setState(() {
        _error = 'Please select a preferred time.';
      });
      return;
    }

    final user = AuthService.instance.currentUser;

    if (user == null) {
      setState(() {
        _error = 'Your session has expired. Please login again.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    final booking = BookingRequest(
      id: '',
      providerId: widget.provider.uid,
      providerName: widget.provider.name,
      userId: user.uid,
      userName: _nameController.text.trim(),
      userWhatsapp: _whatsappController.text.trim(),
      serviceId: widget.service.id,
      serviceTitle: widget.service.title,
      serviceCategory: widget.service.category,
      date: _selectedDate!,
      time: _formatTime(_selectedTime!),
      note: _noteController.text.trim(),
      status: 'requested',
      createdAt: DateTime.now(),
    );

    try {
      await FirestoreService.instance.createBooking(
        booking,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking request sent successfully.',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => UserBookingsScreen(
            userId: user.uid,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not send booking request. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _whatsappController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_submitting,
      child: Scaffold(
        backgroundColor: AppColors.cardDark,
        appBar: AppBar(
          title: const Text('Confirm Booking'),
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
                  _ServiceSummaryCard(
                    provider: widget.provider,
                    service: widget.service,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Your Details',
                    style: TextStyle(
                      color: AppColors.darkBg,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nameController,
                    enabled: !_submitting,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      prefixIcon: Icon(
                        Icons.person_outline,
                      ),
                    ),
                    validator: (value) {
                      if ((value?.trim().length ?? 0) < 3) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _whatsappController,
                    enabled: !_submitting,
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

                      if (!_isValidPhone(phone)) {
                        return 'Enter a valid number with country code';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Preferred Schedule',
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
                        child: _PickerField(
                          label: 'Date',
                          value: _selectedDate == null
                              ? 'Select date'
                              : _formatDate(_selectedDate!),
                          icon: Icons.calendar_today_outlined,
                          onTap: _submitting ? null : _selectDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerField(
                          label: 'Time',
                          value: _selectedTime == null
                              ? 'Select time'
                              : _formatTime(_selectedTime!),
                          icon: Icons.schedule_outlined,
                          onTap: _submitting ? null : _selectTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _noteController,
                    enabled: !_submitting,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 300,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Additional Note (Optional)',
                      hintText: 'Explain your work requirement...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    ErrorMessageBox(message: _error!),
                  ],
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Send Booking Request',
                    icon: Icons.send_outlined,
                    onPressed: _submitBooking,
                    loading: _submitting,
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

class _ServiceSummaryCard extends StatelessWidget {
  final ProviderProfile provider;
  final ProviderService service;

  const _ServiceSummaryCard({
    required this.provider,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final category = serviceCategoryByName(
      service.category,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.darkBg,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              category.icon,
              color: AppColors.darkBg,
              size: 29,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Provider: ${provider.name}',
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'PKR ${service.hourlyCharge.toStringAsFixed(0)}/hour',
                  style: const TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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

class _PickerField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _PickerField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.cardDark,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: AppColors.textGrey,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: value.startsWith('Select')
                    ? AppColors.textGrey
                    : AppColors.darkBg,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
