import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/user_model.dart' hide BookingRequest;
import '../theme/app_theme.dart';

class UserBookingsScreen extends StatelessWidget {
  final String userId;

  const UserBookingsScreen({
    super.key,
    required this.userId,
  });

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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _cancelBooking({
    required BuildContext context,
    required BookingRequest booking,
  }) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Cancel Booking?',
      message: 'Are you sure you want to cancel this booking request?',
      confirmLabel: 'Cancel Booking',
      destructive: true,
    );

    if (!confirmed) return;

    try {
      await FirestoreService.instance.updateBookingStatus(
        bookingId: booking.id,
        status: 'cancelled',
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking cancelled successfully.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not cancel booking. Please try again.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _contactProvider({
    required BuildContext context,
    required BookingRequest booking,
  }) async {
    // final number = booking.providerWhatsapp.replaceAll(RegExp(r'[^0-9]'), '');

    // if (number.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text(
    //         'Provider WhatsApp number is not available.',
    //       ),
    //       backgroundColor: AppColors.danger,
    //     ),
    //   );
    //   return;
    // }

    // ignore: unused_local_variable
    final message = Uri.encodeComponent(
      'Assalam-o-Alaikum ${booking.providerName},\n\n'
      'I am contacting you regarding my KaamSetu booking for '
      '${booking.serviceTitle} on ${_formatDate(booking.date)} '
      'at ${booking.time}.',
    );

    // final uri = Uri.parse(
    //   // 'https://wa.me/$number?text=$message',
    // );

    // try {
    //   final opened = await launchUrl(
    //     uri,
    //     mode: LaunchMode.externalApplication,
    //   );

    //   if (!opened) {
    //     throw Exception('Could not open WhatsApp');
    //   }
    // } catch (_) {
    //   if (!context.mounted) return;

    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text(
    //         'Could not open WhatsApp. Make sure it is installed.',
    //       ),
    //       backgroundColor: AppColors.danger,
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardDark,
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: SafeArea(
        child: StreamBuilder<List<BookingRequest>>(
          stream: FirestoreService.instance.watchUserBookings(userId),
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
                title: 'No Bookings Yet',
                message: 'Your service booking requests will appear here.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final booking = bookings[index];

                return UserBookingCard(
                  booking: booking,
                  onCancel: () {
                    _cancelBooking(
                      context: context,
                      booking: booking,
                    );
                  },
                  onContact: () {
                    _contactProvider(
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

class UserBookingCard extends StatelessWidget {
  final BookingRequest booking;
  final VoidCallback onCancel;
  final VoidCallback onContact;

  const UserBookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
    required this.onContact,
  });

  bool get _isRequested => booking.status == 'requested';

  bool get _isAccepted => booking.status == 'accepted';

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
        return 'Pending';
    }
  }

  String get _statusMessage {
    switch (booking.status) {
      case 'accepted':
        return 'Your provider accepted this request. Contact them on WhatsApp.';

      case 'completed':
        return 'This service booking has been marked as completed.';

      case 'rejected':
        return 'The provider could not accept this request.';

      case 'cancelled':
        return 'You cancelled this booking request.';

      default:
        return 'Waiting for the provider to respond.';
    }
  }

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
                height: 48,
                width: 48,
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
                      'Provider: ${booking.providerName}',
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
                  // ignore: deprecated_member_use
                  color: _statusColor.withOpacity(0.11),
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
          _BookingDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: UserBookingsScreen._formatDate(
              booking.date,
            ),
          ),
          const SizedBox(height: 10),
          _BookingDetailRow(
            icon: Icons.schedule_outlined,
            label: 'Time',
            value: booking.time,
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: _statusColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              _statusMessage,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          if (booking.note.trim().isNotEmpty) ...[
            const SizedBox(height: 13),
            Text(
              'Your Note: ${booking.note}',
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (_isRequested)
            OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Cancel Booking'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(
                  color: AppColors.danger,
                ),
                minimumSize: const Size(
                  double.infinity,
                  48,
                ),
              ),
            ),
          if (_isAccepted || booking.status == 'completed')
            PrimaryButton(
              label: 'Contact Provider on WhatsApp',
              icon: Icons.chat_outlined,
              // backgroundColor: AppColors.success,
              // foregroundColor: AppColors.white,
              onPressed: onContact,
            ),
        ],
      ),
    );
  }
}

class _BookingDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BookingDetailRow({
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
          color: AppColors.textGrey,
          size: 18,
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
