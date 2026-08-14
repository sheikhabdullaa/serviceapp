import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// No image upload anywhere in this app — every avatar is generated from
/// the person's name initial, colour-coded, so there's zero storage/media
/// pipeline to build or pay for.
class InitialsAvatar extends StatelessWidget {
  final String name;
  final double radius;
  const InitialsAvatar({super.key, required this.name, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
    final colors = [
      AppColors.darkBg,
      AppColors.success,
      const Color(0xFF7C3AED),
      const Color(0xFFDB2777),
      const Color(0xFF2563EB),
    ];
    final color = colors[name.hashCode.abs() % colors.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }
}
