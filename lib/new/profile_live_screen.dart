import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/provider_dashbord.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';

class ProfileLiveScreen extends StatefulWidget {
  final ProviderProfile providerProfile;

  const ProfileLiveScreen({
    super.key,
    required this.providerProfile,
  });

  @override
  State<ProfileLiveScreen> createState() => _ProfileLiveScreenState();
}

class _ProfileLiveScreenState extends State<ProfileLiveScreen> {
  bool _makingLive = true;
  bool _isLive = false;
  bool _sharing = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    _makeProviderLive();
  }

  String get _cleanWhatsAppNumber {
    return widget.providerProfile.whatsapp.replaceAll(RegExp(r'[^0-9]'), '');
  }

  String get _whatsAppContactLink {
    return 'https://wa.me/$_cleanWhatsAppNumber';
  }

  Future<void> _makeProviderLive() async {
    if (!_makingLive) {
      setState(() {
        _makingLive = true;
        _error = null;
      });
    }

    try {
      await FirestoreService.instance.setProviderLive(
        providerId: widget.providerProfile.uid,
        isLive: true,
      );

      if (!mounted) return;

      setState(() {
        _isLive = true;
        _error = null;
      });
    } on StateError catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.message;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not make your profile live: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _makingLive = false;
        });
      }
    }
  }

  Future<void> _shareOnWhatsApp() async {
    if (_sharing || !_isLive) return;

    setState(() {
      _sharing = true;
      _error = null;
    });

    final message = Uri.encodeComponent(
      'Hi! I am ${widget.providerProfile.name}, '
      'a ${widget.providerProfile.mainService} service provider on KaamSetu.\n\n'
      'Service area: ${widget.providerProfile.address}\n'
      'Contact me on WhatsApp:\n'
      '$_whatsAppContactLink',
    );

    final uri = Uri.parse(
      'https://wa.me/?text=$message',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception(
          'WhatsApp could not be opened.',
        );
      }

      await FirestoreService.instance.incrementContacts(
        widget.providerProfile.uid,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not open WhatsApp. Make sure WhatsApp is installed.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
        });
      }
    }
  }

  Future<void> _copyContactLink() async {
    if (!_isLive) return;

    await Clipboard.setData(
      ClipboardData(
        text: _whatsAppContactLink,
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

  void _openDashboard() {
    if (!_isLive) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const ProviderDashboardScreen(
          providerId: '',
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_makingLive) {
      return const AppLoadingScreen(
        message: 'Making your profile live...',
      );
    }

    return PopScope(
      canPop: !_isLive,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          automaticallyImplyLeading: !_isLive,
          title: const Text('Profile Status'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: (_isLive ? AppColors.success : AppColors.danger)
                        .withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isLive ? Icons.verified_rounded : Icons.error_outline,
                    color: _isLive ? AppColors.success : AppColors.danger,
                    size: 72,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isLive ? 'You Are Live!' : 'Could Not Go Live',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  _isLive
                      ? 'Users can now find your active services and contact you.'
                      : 'Your provider profile could not be made live.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 25),
                if (_isLive)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.18),
                      ),
                    ),
                    child: Column(
                      children: [
                        InitialsAvatar(
                          name: widget.providerProfile.name,
                          radius: 35,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.providerProfile.name,
                          style: const TextStyle(
                            color: AppColors.darkBg,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.providerProfile.mainService,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.providerProfile.address,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 17),
                  ErrorMessageBox(
                    message: _error!,
                  ),
                ],
                const SizedBox(height: 28),
                if (_isLive) ...[
                  const Text(
                    'Share Your Profile',
                    style: TextStyle(
                      color: AppColors.darkBg,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share your contact link and get more work.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Share on WhatsApp',
                    icon: Icons.share_outlined,
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    onPressed: _shareOnWhatsApp,
                    loading: _sharing,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Copy Contact Link',
                    icon: Icons.link,
                    onPressed: _copyContactLink,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _openDashboard,
                    child: const Text(
                      'Open Provider Dashboard',
                    ),
                  ),
                ] else ...[
                  PrimaryButton(
                    label: 'Try Again',
                    icon: Icons.refresh,
                    onPressed: _makeProviderLive,
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Go Back',
                    icon: Icons.arrow_back,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
