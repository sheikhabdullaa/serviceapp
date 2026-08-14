import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// KaamSetu کا reusable primary button۔
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primaryYellow,
          foregroundColor: foregroundColor ?? AppColors.darkBg,
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.3,
                  color: AppColors.darkBg,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                    ),
                    const SizedBox(width: 9),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Secondary outlined button۔
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// KaamSetu logo widget۔
class KaamSetuLogo extends StatelessWidget {
  final double size;
  final bool showName;
  final bool showTagline;
  final bool darkBackground;

  const KaamSetuLogo({
    super.key,
    this.size = 92,
    this.showName = true,
    this.showTagline = true,
    this.darkBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = darkBackground ? AppColors.white : AppColors.darkBg;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.primaryYellow,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: AppColors.primaryYellow.withOpacity(0.22),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.engineering,
            size: size * 0.55,
            color: AppColors.darkBg,
          ),
        ),
        if (showName) ...[
          const SizedBox(height: 18),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: size * 0.31,
                fontWeight: FontWeight.bold,
              ),
              children: [
                TextSpan(
                  text: 'Kaam',
                  style: TextStyle(
                    color: titleColor,
                  ),
                ),
                const TextSpan(
                  text: 'Setu',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 5),
          Text(
            'Har Kaam, Aasan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  darkBackground ? AppColors.primaryYellow : AppColors.textGrey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

/// Error message دکھانے کے لیے۔
class ErrorMessageBox extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorMessageBox({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppColors.danger.withOpacity(0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.danger,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 7),
                  GestureDetector(
                    onTap: onRetry,
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Success message دکھانے کے لیے۔
class SuccessMessageBox extends StatelessWidget {
  final String message;

  const SuccessMessageBox({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: AppColors.success.withOpacity(0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // ignore: deprecated_member_use
          color: AppColors.success.withOpacity(0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// General information message۔
class InfoMessageBox extends StatelessWidget {
  final String message;

  const InfoMessageBox({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.primaryYellow,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.darkBg,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// پورے page کا loading indicator۔
class AppLoadingScreen extends StatelessWidget {
  final String? message;

  const AppLoadingScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primaryYellow,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Lists کے empty ہونے پر دکھایا جائے گا۔
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppColors.primaryYellow.withOpacity(0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primaryYellow,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkBg,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (buttonLabel != null && onButtonPressed != null) ...[
              const SizedBox(height: 22),
              PrimaryButton(
                label: buttonLabel!,
                onPressed: onButtonPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Screen section heading۔
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.darkBg,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// Provider verification badge۔
class VerificationBadge extends StatelessWidget {
  final bool verified;

  const VerificationBadge({
    super.key,
    required this.verified,
  });

  @override
  Widget build(BuildContext context) {
    final color = verified ? AppColors.success : AppColors.primaryYellow;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            verified ? Icons.verified_outlined : Icons.schedule_outlined,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            verified ? 'Verified' : 'Pending Verification',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// User یا provider کا initials avatar۔
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final Color? backgroundColor;

  const InitialsAvatar({
    super.key,
    required this.name,
    this.radius = 28,
    this.backgroundColor,
  });

  String get _initials {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();

    if (words.isEmpty) return '?';

    if (words.length == 1) {
      return words.first[0].toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? AppColors.primaryYellow,
      child: Text(
        _initials,
        style: TextStyle(
          color: AppColors.darkBg,
          fontSize: radius * 0.62,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// App کی confirmation dialog۔
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            style: TextButton.styleFrom(
              foregroundColor:
                  destructive ? AppColors.danger : AppColors.success,
            ),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
