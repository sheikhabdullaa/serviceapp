import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/user_model.dart' hide BookingRequest;
import 'package:url_launcher/url_launcher.dart';

import '../../model/model.dart';
import '../../services/fire_Store_services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart' hide PrimaryButton;

class ProviderBookingsScreen extends StatelessWidget {
  final String providerId;

  const ProviderBookingsScreen({
    super.key,
    required this.providerId,
  });

  Future<void> _updateStatus({
    required BuildContext context,
    required BookingRequest booking,
    required String status,
  }) async {
    final normalizedStatus = status.trim().toLowerCase();

    final shouldConfirm =
        normalizedStatus == 'rejected' || normalizedStatus == 'completed';

    if (shouldConfirm) {
      final confirmed = await showConfirmationDialog(
        context: context,
        title: normalizedStatus == 'rejected'
            ? 'Reject Request?'
            : 'Complete Booking?',
        message: normalizedStatus == 'rejected'
            ? 'Are you sure you want to reject this booking request?'
            : 'Confirm that this service has been completed.',
        confirmLabel: normalizedStatus == 'rejected' ? 'Reject' : 'Complete',
        destructive: normalizedStatus == 'rejected',
      );

      if (!confirmed) return;
    }

    try {
      await FirestoreService.instance.updateBookingStatus(
        bookingId: booking.id,
        status: normalizedStatus,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _successMessage(normalizedStatus),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update booking: $error',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _contactUser({
    required BuildContext context,
    required BookingRequest booking,
  }) async {
    final number = booking.userWhatsapp.replaceAll(RegExp(r'[^0-9]'), '');

    if (number.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User WhatsApp number is not available.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final message = Uri.encodeComponent(
      'Assalam-o-Alaikum ${booking.userName},\n\n'
      'I am contacting you regarding your KaamSetu request for '
      '${booking.serviceTitle} on ${_formatDate(booking.date)} '
      'at ${booking.time}.',
    );

    final uri = Uri.parse(
      'https://wa.me/$number?text=$message',
    );

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        throw Exception('Could not open WhatsApp');
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open WhatsApp. Make sure it is installed.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  String _successMessage(String status) {
    switch (status) {
      case 'accepted':
        return 'Booking request accepted';

      case 'completed':
        return 'Booking marked as completed';

      case 'rejected':
        return 'Booking request rejected';

      default:
        return 'Booking status updated';
    }
  }

  static String _formatDate(DateTime date) {
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

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: const Text('Booking Requests'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<BookingRequest>>(
          stream: FirestoreService.instance.watchProviderBookings(providerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Could Not Load Bookings',
                message: snapshot.error.toString(),
              );
            }

            final bookings = snapshot.data ?? const <BookingRequest>[];

            if (bookings.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.calendar_month_outlined,
                title: 'No Booking Requests',
                message: 'Booking requests from users will appear here.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return BookingRequestCard(
                  booking: booking,
                  onAccept: () {
                    _updateStatus(
                      context: context,
                      booking: booking,
                      status: 'accepted',
                    );
                  },
                  onReject: () {
                    _updateStatus(
                      context: context,
                      booking: booking,
                      status: 'rejected',
                    );
                  },
                  onComplete: () {
                    _updateStatus(
                      context: context,
                      booking: booking,
                      status: 'completed',
                    );
                  },
                  onContact: () {
                    _contactUser(
                      context: context,
                      booking: booking,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class BookingRequestCard extends StatelessWidget {
  final BookingRequest booking;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onComplete;
  final VoidCallback onContact;

  const BookingRequestCard({
    super.key,
    required this.booking,
    required this.onAccept,
    required this.onReject,
    required this.onComplete,
    required this.onContact,
  });

  Color get _statusColor {
    switch (booking.status) {
      case 'accepted':
        return Colors.blue;

      case 'completed':
        return AppColors.success;

      case 'rejected':
      case 'cancelled':
        return AppColors.danger;

      default:
        return AppColors.primaryYellow;
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case 'accepted':
        return 'Accepted';

      case 'completed':
        return 'Completed';

      case 'rejected':
        return 'Rejected';

      case 'cancelled':
        return 'Cancelled';

      default:
        return 'Requested';
    }
  }

  bool get _isRequested => booking.status == 'requested';

  bool get _isAccepted => booking.status == 'accepted';

  @override
  Widget build(BuildContext context) {
    final category = serviceCategoryByName(
      booking.serviceCategory,
    );

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.darkBg,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceTitle,
                      style: const TextStyle(
                        color: AppColors.darkBg,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.serviceCategory,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(
                    0.11,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BookingInfoRow(
            icon: Icons.person_outline,
            label: 'Customer',
            value:
                booking.userName.isEmpty ? 'KaamSetu User' : booking.userName,
          ),
          const SizedBox(height: 10),
          _BookingInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: ProviderBookingsScreen._formatDate(
              booking.date,
            ),
          ),
          const SizedBox(height: 10),
          _BookingInfoRow(
            icon: Icons.schedule_outlined,
            label: 'Time',
            value: booking.time,
          ),
          if (booking.note.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customer Note',
                    style: TextStyle(
                      color: AppColors.darkBg,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    booking.note,
                    style: const TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_isRequested)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(
                        color: AppColors.danger,
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          if (_isAccepted)
            Column(
              children: [
                PrimaryButton(
                  label: 'Contact on WhatsApp',
                  icon: Icons.chat_outlined,
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  onPressed: onContact,
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: 'Mark as Completed',
                  icon: Icons.check_circle_outline,
                  onPressed: onComplete,
                ),
              ],
            ),
          if (!_isRequested && !_isAccepted)
            SecondaryButton(
              label: 'Contact Customer',
              icon: Icons.chat_outlined,
              onPressed: onContact,
            ),
        ],
      ),
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BookingInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 19,
          color: AppColors.textGrey,
        ),
        const SizedBox(width: 9),
        Text(
          '$label: ',
          style: const TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.darkBg,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
