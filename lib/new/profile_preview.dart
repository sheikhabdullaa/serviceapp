// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:service_hub/new/appuser.dart';
// import 'package:service_hub/new/firestore_service.dart';
// import 'package:service_hub/new/my_service_screen.dart';
// import 'package:service_hub/new/primary_buton.dart';
// import '../../theme/app_theme.dart';

// class ProfilePreviewScreen extends StatefulWidget {
//   final ProviderProfile providerProfile;

//   const ProfilePreviewScreen({
//     super.key,
//     required this.providerProfile,
//   });

//   @override
//   State<ProfilePreviewScreen> createState() => _ProfilePreviewScreenState();
// }

// class _ProfilePreviewScreenState extends State<ProfilePreviewScreen> {
//   bool _saving = false;
//   String? _error;

//   Future<void> _saveProfile() async {
//     if (_saving) return;

//     setState(() {
//       _saving = true;
//       _error = null;
//     });

//     try {
//       /*
//        * Provider profile save ہوگی اور users/{uid}
//        * میں profileCompleted true ہوجائے گا۔
//        */
//       await FirestoreService.instance.saveCompletedProviderProfile(
//         widget.providerProfile,
//       );

//       if (!mounted) return;

//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(
//           builder: (_) => MyServicesScreen(
//             providerProfile: widget.providerProfile,
//             isInitialSetup: true,
//           ),
//         ),
//         (route) => false,
//       );
//     } on FirebaseException catch (error) {
//       if (!mounted) return;

//       setState(() {
//         if (error.code == 'permission-denied') {
//           _error = 'Permission denied. Check Firestore security rules.';
//         } else {
//           _error = error.message ?? 'Could not save provider profile.';
//         }
//       });
//     } catch (error) {
//       if (!mounted) return;

//       setState(() {
//         _error = 'Could not save your profile. Please try again.';
//       });
//     } finally {
//       if (mounted) {
//         setState(() {
//           _saving = false;
//         });
//       }
//     }
//   }

//   String _maskedIdCard(String idCard) {
//     final clean = idCard.trim();

//     if (clean.length <= 5) return clean;

//     final visibleStart = clean.substring(0, 3);

//     final visibleEnd = clean.substring(clean.length - 2);

//     return '$visibleStart••••••$visibleEnd';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = widget.providerProfile;

//     return PopScope(
//       canPop: !_saving,
//       child: Scaffold(
//         backgroundColor: AppColors.white,
//         appBar: AppBar(
//           title: const Text('Profile Preview'),
//         ),
//         body: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(22),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const _ProfileStepIndicator(
//                   currentStep: 3,
//                 ),
//                 const SizedBox(height: 26),
//                 Center(
//                   child: Column(
//                     children: [
//                       InitialsAvatar(
//                         name: provider.name,
//                         radius: 47,
//                       ),
//                       const SizedBox(height: 14),
//                       Text(
//                         provider.name,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           color: AppColors.darkBg,
//                           fontSize: 23,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 5),
//                       Text(
//                         provider.mainService,
//                         style: const TextStyle(
//                           color: AppColors.textGrey,
//                           fontSize: 15,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       VerificationBadge(
//                         verified: provider.verified,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 28),
//                 _ProfileInformationCard(
//                   icon: Icons.chat_bubble_outline,
//                   label: 'WhatsApp',
//                   value: provider.whatsapp,
//                 ),
//                 const SizedBox(height: 12),
//                 _ProfileInformationCard(
//                   icon: Icons.location_on_outlined,
//                   label: 'Service Area',
//                   value: provider.address,
//                 ),
//                 const SizedBox(height: 12),
//                 _ProfileInformationCard(
//                   icon: Icons.badge_outlined,
//                   label: 'ID Card Number',
//                   value: _maskedIdCard(
//                     provider.idCardNumber,
//                   ),
//                 ),
//                 const SizedBox(height: 22),
//                 const Text(
//                   'About',
//                   style: TextStyle(
//                     color: AppColors.darkBg,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 9),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.all(15),
//                   decoration: BoxDecoration(
//                     color: const Color(
//                       0xFFF8FAFC,
//                     ),
//                     borderRadius: BorderRadius.circular(13),
//                     border: Border.all(
//                       color: AppColors.cardDark,
//                     ),
//                   ),
//                   child: Text(
//                     provider.about,
//                     style: const TextStyle(
//                       color: AppColors.textGrey,
//                       fontSize: 14,
//                       height: 1.55,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 22),
//                 const Text(
//                   'Uploaded ID Card',
//                   style: TextStyle(
//                     color: AppColors.darkBg,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 9),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(14),
//                   child: Container(
//                     width: double.infinity,
//                     height: 190,
//                     color: const Color(
//                       0xFFF1F5F9,
//                     ),
//                     child: provider.idCardImageUrl.trim().isEmpty
//                         ? const Center(
//                             child: Text(
//                               'No ID image uploaded',
//                               style: TextStyle(
//                                 color: AppColors.textGrey,
//                               ),
//                             ),
//                           )
//                         : Image.network(
//                             provider.idCardImageUrl,
//                             fit: BoxFit.cover,
//                             loadingBuilder: (
//                               context,
//                               child,
//                               progress,
//                             ) {
//                               if (progress == null) {
//                                 return child;
//                               }

//                               return const Center(
//                                 child: CircularProgressIndicator(),
//                               );
//                             },
//                             errorBuilder: (
//                               context,
//                               error,
//                               stackTrace,
//                             ) {
//                               return const Center(
//                                 child: Icon(
//                                   Icons.broken_image_outlined,
//                                   color: AppColors.textGrey,
//                                   size: 42,
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 14),
//                 const InfoMessageBox(
//                   message:
//                       'Your ID card image is private and is only used for provider verification.',
//                 ),
//                 if (_error != null) ...[
//                   const SizedBox(height: 16),
//                   ErrorMessageBox(
//                     message: _error!,
//                   ),
//                 ],
//                 const SizedBox(height: 25),
//                 PrimaryButton(
//                   label: 'Save Profile & Add Services',
//                   icon: Icons.save_outlined,
//                   onPressed: _saveProfile,
//                   loading: _saving,
//                 ),
//                 const SizedBox(height: 12),
//                 SecondaryButton(
//                   label: 'Edit Information',
//                   icon: Icons.edit_outlined,
//                   onPressed: _saving
//                       ? null
//                       : () {
//                           Navigator.of(context).pop();
//                         },
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _ProfileInformationCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const _ProfileInformationCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: AppColors.white,
//         borderRadius: BorderRadius.circular(13),
//         border: Border.all(
//           color: AppColors.cardDark,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 43,
//             height: 43,
//             decoration: BoxDecoration(
//               color: AppColors.primaryYellow,
//               borderRadius: BorderRadius.circular(11),
//             ),
//             child: Icon(
//               icon,
//               color: AppColors.darkBg,
//               size: 22,
//             ),
//           ),
//           const SizedBox(width: 13),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     color: AppColors.textGrey,
//                     fontSize: 12,
//                   ),
//                 ),
//                 const SizedBox(height: 3),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     color: AppColors.darkBg,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
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

// class _ProfileStepIndicator extends StatelessWidget {
//   final int currentStep;

//   const _ProfileStepIndicator({
//     required this.currentStep,
//   });

//   @override
//   Widget build(BuildContext context) {
//     const labels = [
//       'Details',
//       'ID Card',
//       'Preview',
//     ];

//     return Row(
//       children: List.generate(
//         labels.length,
//         (index) {
//           final step = index + 1;
//           final active = step <= currentStep;

//           return Expanded(
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       Container(
//                         width: 32,
//                         height: 32,
//                         alignment: Alignment.center,
//                         decoration: BoxDecoration(
//                           color: active
//                               ? AppColors.primaryYellow
//                               : AppColors.cardDark,
//                           shape: BoxShape.circle,
//                         ),
//                         child: step < currentStep
//                             ? const Icon(
//                                 Icons.check,
//                                 size: 18,
//                                 color: AppColors.darkBg,
//                               )
//                             : Text(
//                                 '$step',
//                                 style: TextStyle(
//                                   color: active
//                                       ? AppColors.darkBg
//                                       : AppColors.textGrey,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         labels[index],
//                         style: TextStyle(
//                           color: active ? AppColors.darkBg : AppColors.textGrey,
//                           fontSize: 11,
//                           fontWeight:
//                               active ? FontWeight.w600 : FontWeight.normal,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (index < labels.length - 1)
//                   Expanded(
//                     child: Container(
//                       height: 2,
//                       color: step < currentStep
//                           ? AppColors.primaryYellow
//                           : AppColors.cardDark,
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/my_service_screen.dart';
import 'package:service_hub/new/primary_buton.dart';

import '../../theme/app_theme.dart';

class ProfilePreviewScreen extends StatefulWidget {
  final ProviderProfile providerProfile;

  /*
   * Ye image sirf temporary memory mein
   * rahegi. Firestore ya Storage mein save
   * nahi hogi.
   */
  final Uint8List? temporaryIdCardImageBytes;

  const ProfilePreviewScreen({
    super.key,
    required this.providerProfile,
    this.temporaryIdCardImageBytes,
  });

  @override
  State<ProfilePreviewScreen> createState() => _ProfilePreviewScreenState();
}

class _ProfilePreviewScreenState extends State<ProfilePreviewScreen> {
  bool _saving = false;
  String? _error;

  Future<void> _saveProfile() async {
    if (_saving) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      /*
       * Sirf provider profile information
       * save hogi. Temporary ID image save
       * nahi hogi.
       */
      await FirestoreService.instance.saveCompletedProviderProfile(
        widget.providerProfile,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MyServicesScreen(
            providerProfile: widget.providerProfile,
            isInitialSetup: true,
          ),
        ),
        (route) => false,
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      setState(() {
        if (error.code == 'permission-denied') {
          _error = 'Permission denied. Check Firestore security rules.';
        } else {
          _error = error.message ?? 'Could not save provider profile.';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not save your profile. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String _maskedIdCard(String idCard) {
    final String clean = idCard.trim();

    if (clean.length <= 5) return clean;

    final String visibleStart = clean.substring(0, 3);

    final String visibleEnd = clean.substring(clean.length - 2);

    return '$visibleStart••••••$visibleEnd';
  }

  Widget _buildIdCardImage(
    ProviderProfile provider,
  ) {
    final Uint8List? temporaryImage = widget.temporaryIdCardImageBytes;

    if (temporaryImage != null && temporaryImage.isNotEmpty) {
      return Image.memory(
        temporaryImage,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.textGrey,
              size: 42,
            ),
          );
        },
      );
    }

    if (provider.idCardImageUrl.trim().isNotEmpty) {
      return Image.network(
        provider.idCardImageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (
          context,
          child,
          progress,
        ) {
          if (progress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: AppColors.textGrey,
              size: 42,
            ),
          );
        },
      );
    }

    return const Center(
      child: Text(
        'No ID image uploaded',
        style: TextStyle(
          color: AppColors.textGrey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ProviderProfile provider = widget.providerProfile;

    return PopScope(
      canPop: !_saving,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text(
            'Profile Preview',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ProfileStepIndicator(
                  currentStep: 3,
                ),
                const SizedBox(height: 26),
                Center(
                  child: Column(
                    children: [
                      InitialsAvatar(
                        name: provider.name,
                        radius: 47,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        provider.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.darkBg,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        provider.mainService,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      VerificationBadge(
                        verified: provider.verified,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                _ProfileInformationCard(
                  icon: Icons.chat_bubble_outline,
                  label: 'WhatsApp',
                  value: provider.whatsapp,
                ),
                const SizedBox(height: 12),
                _ProfileInformationCard(
                  icon: Icons.location_on_outlined,
                  label: 'Service Area',
                  value: provider.address,
                ),
                const SizedBox(height: 12),
                _ProfileInformationCard(
                  icon: Icons.badge_outlined,
                  label: 'ID Card Number',
                  value: _maskedIdCard(
                    provider.idCardNumber,
                  ),
                ),
                const SizedBox(height: 22),
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
                    color: const Color(
                      0xFFF8FAFC,
                    ),
                    borderRadius: BorderRadius.circular(13),
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
                  'Uploaded ID Card',
                  style: TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 190,
                    color: const Color(
                      0xFFF1F5F9,
                    ),
                    child: _buildIdCardImage(provider),
                  ),
                ),
                const SizedBox(height: 14),
                const InfoMessageBox(
                  message:
                      'Your ID card image is private and is only used for provider verification.',
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  ErrorMessageBox(
                    message: _error!,
                  ),
                ],
                const SizedBox(height: 25),
                PrimaryButton(
                  label: 'Save Profile & Add Services',
                  icon: Icons.save_outlined,
                  onPressed: _saveProfile,
                  loading: _saving,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Edit Information',
                  icon: Icons.edit_outlined,
                  onPressed: _saving
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileInformationCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInformationCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.cardDark,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.primaryYellow,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: AppColors.darkBg,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

class _ProfileStepIndicator extends StatelessWidget {
  final int currentStep;

  const _ProfileStepIndicator({
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    const labels = [
      'Details',
      'ID Card',
      'Preview',
    ];

    return Row(
      children: List.generate(
        labels.length,
        (index) {
          final int step = index + 1;
          final bool active = step <= currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primaryYellow
                              : AppColors.cardDark,
                          shape: BoxShape.circle,
                        ),
                        child: step < currentStep
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: AppColors.darkBg,
                              )
                            : Text(
                                '$step',
                                style: TextStyle(
                                  color: active
                                      ? AppColors.darkBg
                                      : AppColors.textGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: active ? AppColors.darkBg : AppColors.textGrey,
                          fontSize: 11,
                          fontWeight:
                              active ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: step < currentStep
                          ? AppColors.primaryYellow
                          : AppColors.cardDark,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
