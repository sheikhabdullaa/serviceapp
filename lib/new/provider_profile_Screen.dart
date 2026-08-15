import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/confirm_booking_screen.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/user_model.dart'
    hide ProviderService, ProviderProfile;
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';

class ProviderProfileScreen extends StatefulWidget {
  final String providerId;

  /// true ہو تو provider اپنی profile دیکھ رہا ہے۔
  final bool ownerView;

  const ProviderProfileScreen({
    super.key,
    required this.providerId,
    this.ownerView = false,
  });

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  @override
  void initState() {
    super.initState();

    if (!widget.ownerView) {
      FirestoreService.instance.incrementProfileViews(
        widget.providerId,
      );
    }
  }

  String _cleanPhone(String phone) {
    return phone.replaceAll(
      RegExp(r'[^0-9+]'),
      '',
    );
  }

  String _whatsAppNumber(String phone) {
    return phone.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );
  }

  Future<void> _openWhatsApp(
    ProviderProfile provider,
  ) async {
    final number = _whatsAppNumber(provider.whatsapp);

    final message = Uri.encodeComponent(
      'Assalam-o-Alaikum ${provider.name}, '
      'I found your ${provider.mainService} profile on Service Hub.',
    );

    final uri = Uri.parse(
      'https://wa.me/$number?text=$message',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception();
      }

      await FirestoreService.instance.incrementContacts(provider.uid);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open WhatsApp.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _makeCall(
    ProviderProfile provider,
  ) async {
    final phone = _cleanPhone(provider.whatsapp);

    final uri = Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      final launched = await launchUrl(uri);

      if (!launched) {
        throw Exception();
      }

      await FirestoreService.instance.incrementContacts(provider.uid);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open dialer.'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _copyContact(
    ProviderProfile provider,
  ) async {
    final number = _whatsAppNumber(provider.whatsapp);

    await Clipboard.setData(
      ClipboardData(
        text: 'https://wa.me/$number',
      ),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'WhatsApp contact link copied',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _openBooking({
    required ProviderProfile provider,
    required ProviderService service,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConfirmBookingScreen(
          provider: provider,
          service: service,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ProviderProfile?>(
      stream: FirestoreService.instance.watchProvider(widget.providerId),
      builder: (context, providerSnapshot) {
        if (providerSnapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingScreen(
            message: 'Loading provider profile...',
          );
        }

        if (providerSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Provider Details'),
            ),
            body: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Could Not Load Profile',
              message: providerSnapshot.error.toString(),
            ),
          );
        }

        final provider = providerSnapshot.data;

        if (provider == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Provider Details'),
            ),
            body: const EmptyStateWidget(
              icon: Icons.person_off_outlined,
              title: 'Provider Not Found',
              message: 'This provider profile is no longer available.',
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.darkBg,
          appBar: AppBar(
            title: Text(
              widget.ownerView ? 'My Profile' : 'Provider Details',
            ),
            actions: [
              IconButton(
                tooltip: 'Copy contact link',
                onPressed: () {
                  _copyContact(provider);
                },
                icon: const Icon(
                  Icons.share_outlined,
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: _ProviderProfileBody(
              provider: provider,
              ownerView: widget.ownerView,
              onWhatsApp: () {
                _openWhatsApp(provider);
              },
              onCall: () {
                _makeCall(provider);
              },
              onBookService: (service) {
                _openBooking(
                  provider: provider,
                  service: service,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ProviderProfileBody extends StatelessWidget {
  final ProviderProfile provider;
  final bool ownerView;
  final VoidCallback onWhatsApp;
  final VoidCallback onCall;
  final ValueChanged<ProviderService> onBookService;

  const _ProviderProfileBody({
    required this.provider,
    required this.ownerView,
    required this.onWhatsApp,
    required this.onCall,
    required this.onBookService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProviderService>>(
      stream: FirestoreService.instance.watchActiveProviderServices(
        provider.uid,
      ),
      builder: (context, serviceSnapshot) {
        final services = serviceSnapshot.data ?? const <ProviderService>[];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProfileHeader(
                provider: provider,
              ),
              const SizedBox(height: 18),
              if (ownerView)
                InfoMessageBox(
                  message: provider.isLive
                      ? 'Your profile is live and visible to users.'
                      : 'Your profile is offline and hidden from users.',
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: 'WhatsApp',
                        icon: Icons.chat_outlined,
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.white,
                        onPressed: onWhatsApp,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Call',
                        icon: Icons.phone_outlined,
                        onPressed: onCall,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 23),
              const Text(
                'About',
                style: TextStyle(
                  color: AppColors.darkBg,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 9),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.cardDark,
                  ),
                ),
                child: Text(
                  provider.about,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Services',
                style: TextStyle(
                  color: AppColors.darkBg,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (serviceSnapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else if (serviceSnapshot.hasError)
                ErrorMessageBox(
                  message: serviceSnapshot.error.toString(),
                )
              else if (services.isEmpty)
                const EmptyStateWidget(
                  icon: Icons.home_repair_service_outlined,
                  title: 'No Active Services',
                  message: 'This provider currently has no active services.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  separatorBuilder: (context, index) => const SizedBox(
                    height: 11,
                  ),
                  itemBuilder: (context, index) {
                    final service = services[index];

                    return _PublicServiceCard(
                      service: service,
                      ownerView: ownerView,
                      onSelect: () {
                        onBookService(service);
                      },
                    );
                  },
                ),
              const SizedBox(height: 22),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final ProviderProfile provider;

  const _ProfileHeader({
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: AppColors.cardDark,
        ),
      ),
      child: Column(
        children: [
          InitialsAvatar(
            name: provider.name,
            radius: 43,
          ),
          const SizedBox(height: 13),
          Text(
            provider.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.darkBg,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.mainService,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 9),
          VerificationBadge(
            verified: provider.verified,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppColors.primaryYellow,
                size: 21,
              ),
              const SizedBox(width: 4),
              Text(
                provider.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.darkBg,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' (${provider.reviewCount} reviews)',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.success,
                size: 18,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  provider.address,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PublicServiceCard extends StatelessWidget {
  final ProviderService service;
  final bool ownerView;
  final VoidCallback onSelect;

  const _PublicServiceCard({
    required this.service,
    required this.ownerView,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final category = serviceCategoryByName(
      service.category,
    );

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.cardDark,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  category.icon,
                  color: AppColors.darkBg,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      style: const TextStyle(
                        color: AppColors.darkBg,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      service.category,
                      style: const TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'PKR ${service.hourlyCharge.toStringAsFixed(0)}/hr',
                style: const TextStyle(
                  color: AppColors.primaryYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            service.description,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${service.experienceYears} years experience • ${service.serviceArea}',
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 11,
            ),
          ),
          if (!ownerView) ...[
            const SizedBox(height: 13),
            PrimaryButton(
              label: 'Select Service',
              icon: Icons.calendar_month_outlined,
              onPressed: onSelect,
            ),
          ],
        ],
      ),
    );
  }
}
