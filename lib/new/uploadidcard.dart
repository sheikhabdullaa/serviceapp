import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:service_hub/new/appuser.dart';
import 'package:service_hub/new/firestore_service.dart';
import 'package:service_hub/new/primary_buton.dart';
import 'package:service_hub/new/profile_preview.dart';
import '../../theme/app_theme.dart';

class UploadIdCardScreen extends StatefulWidget {
  final ProviderProfile providerProfile;

  const UploadIdCardScreen({
    super.key,
    required this.providerProfile,
  });

  @override
  State<UploadIdCardScreen> createState() => _UploadIdCardScreenState();
}

class _UploadIdCardScreenState extends State<UploadIdCardScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;

  bool _uploading = false;
  String? _error;

  bool get _hasExistingImage =>
      widget.providerProfile.idCardImageUrl.trim().isNotEmpty;

  Future<void> _showImageSource() async {
    if (_uploading) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              5,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select ID Card Image',
                  style: TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryYellow,
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: AppColors.darkBg,
                    ),
                  ),
                  title: const Text('Take Photo'),
                  subtitle: const Text(
                    'Use your mobile camera',
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    // Chrome/Web par gallery/file
                    // picker open hoga. Android par
                    // mobile camera open hoga.
                    _pickImage(
                      kIsWeb ? ImageSource.gallery : ImageSource.camera,
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryYellow,
                    child: Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.darkBg,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                  ),
                  subtitle: const Text(
                    'Select an existing image',
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();

                    _pickImage(
                      ImageSource.gallery,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(
    ImageSource source,
  ) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 78,
        maxWidth: 1600,
        maxHeight: 1200,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image == null) return;

      final Uint8List imageBytes = await image.readAsBytes();

      if (!mounted) return;

      if (imageBytes.isEmpty) {
        setState(() {
          _error = 'Selected image could not be loaded.';
        });
        return;
      }

      setState(() {
        _selectedImage = image;
        _selectedImageBytes = imageBytes;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not access camera or gallery.';
      });
    }
  }

  String _fileExtension(XFile image) {
    final String fileName =
        '${image.name} ${image.path}'.toLowerCase().split('?').first;

    if (fileName.contains('.png')) {
      return 'png';
    }

    if (fileName.contains('.webp')) {
      return 'webp';
    }

    return 'jpg';
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';

      case 'webp':
        return 'image/webp';

      default:
        return 'image/jpeg';
    }
  }

  Future<String> _uploadImage(
    XFile image,
    Uint8List imageBytes,
  ) async {
    if (imageBytes.isEmpty) {
      throw Exception(
        'Selected image data is empty.',
      );
    }

    final String extension = _fileExtension(image);

    final Reference storageReference = FirebaseStorage.instance.ref().child(
          'provider_id_cards/'
          '${widget.providerProfile.uid}/'
          'id_card.$extension',
        );

    /*
     * putData Android aur Flutter Web
     * dono platforms par kaam karta hai.
     */
    final UploadTask uploadTask = storageReference.putData(
      imageBytes,
      SettableMetadata(
        contentType: _contentType(extension),
        customMetadata: {
          'providerId': widget.providerProfile.uid,
          'documentType': 'id_card',
        },
      ),
    );

    final TaskSnapshot snapshot = await uploadTask;

    return snapshot.ref.getDownloadURL();
  }

  Future<void> _continueToPreview() async {
    if (_uploading) return;

    if (_selectedImage == null && !_hasExistingImage) {
      setState(() {
        _error = 'Please upload a clear image of your CNIC or ID card.';
      });
      return;
    }

    if (_selectedImage != null && _selectedImageBytes == null) {
      setState(() {
        _error = 'Selected image could not be loaded. Please select it again.';
      });
      return;
    }

    setState(() {
      _uploading = true;
      _error = null;
    });

    try {
      String imageUrl = widget.providerProfile.idCardImageUrl;

      if (_selectedImage != null && _selectedImageBytes != null) {
        imageUrl = await _uploadImage(
          _selectedImage!,
          _selectedImageBytes!,
        );
      }

      final ProviderProfile updatedProfile = widget.providerProfile.copyWith(
        idCardImageUrl: imageUrl,
      );

      /*
       * Uploaded image URL provider document
       * mein save hoga.
       */
      await FirestoreService.instance.createOrUpdateProvider(
        updatedProfile,
      );

      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProfilePreviewScreen(
            providerProfile: updatedProfile,
          ),
        ),
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;

      setState(() {
        switch (error.code) {
          case 'unauthorized':
          case 'permission-denied':
            _error = 'Firebase Storage permission denied. Check Storage rules.';
            break;

          case 'canceled':
            _error = 'Image upload was cancelled.';
            break;

          case 'retry-limit-exceeded':
            _error = 'Upload timed out. Check your internet and try again.';
            break;

          case 'object-not-found':
            _error = 'Firebase Storage file could not be created.';
            break;

          case 'unknown':
            _error =
                'Upload failed. Check your internet connection and Firebase Storage setup.';
            break;

          default:
            _error = error.message ?? 'Could not upload ID card image.';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = 'Could not upload the image. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_uploading,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text(
            'Upload ID Card',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Verify your identity',
                  style: TextStyle(
                    color: AppColors.darkBg,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload a clear photo of the front side of your CNIC or ID card.',
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                const _ProfileStepIndicator(
                  currentStep: 2,
                ),
                const SizedBox(height: 26),
                GestureDetector(
                  onTap: _uploading ? null : _showImageSource,
                  child: Container(
                    width: double.infinity,
                    height: 230,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFF8FAFC,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedImage != null || _hasExistingImage
                            ? AppColors.success
                            : AppColors.textGrey,
                        width: 1.4,
                      ),
                    ),
                    child: _buildImagePreview(),
                  ),
                ),
                const SizedBox(height: 15),
                const InfoMessageBox(
                  message:
                      'Make sure your name, photo and ID number are clearly visible. Your ID image will not be shown publicly.',
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  ErrorMessageBox(
                    message: _error!,
                  ),
                ],
                const SizedBox(height: 26),
                PrimaryButton(
                  label: _selectedImage == null && !_hasExistingImage
                      ? 'Select ID Card Image'
                      : 'Continue to Preview',
                  icon: _selectedImage == null && !_hasExistingImage
                      ? Icons.upload_file_outlined
                      : Icons.arrow_forward,
                  onPressed: _selectedImage == null && !_hasExistingImage
                      ? _showImageSource
                      : _continueToPreview,
                  loading: _uploading,
                ),
                if (_selectedImage != null || _hasExistingImage) ...[
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: 'Change Image',
                    icon: Icons.photo_library_outlined,
                    onPressed: _showImageSource,
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

  Widget _buildImagePreview() {
    /*
     * Image.memory Android aur Web dono par
     * selected image preview show karega.
     */
    if (_selectedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.memory(
          _selectedImageBytes!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (
            context,
            error,
            stackTrace,
          ) {
            return const _UploadPlaceholder();
          },
        ),
      );
    }

    if (_hasExistingImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(
          widget.providerProfile.idCardImageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (
            context,
            child,
            loadingProgress,
          ) {
            if (loadingProgress == null) {
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
            return const _UploadPlaceholder();
          },
        ),
      );
    }

    return const _UploadPlaceholder();
  }
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          color: AppColors.darkBg,
          size: 58,
        ),
        SizedBox(height: 13),
        Text(
          'Tap to Upload',
          style: TextStyle(
            color: AppColors.darkBg,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Camera or Gallery',
          style: TextStyle(
            color: AppColors.textGrey,
            fontSize: 13,
          ),
        ),
      ],
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
                        child: Text(
                          '$step',
                          style: TextStyle(
                            color:
                                active ? AppColors.darkBg : AppColors.textGrey,
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
                          : AppColors.darkBg,
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
