import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFE53935);
  static const primaryDark = Color(0xFFC62828);
  static const primaryLight = Color(0xFFFF6F60);

  // Tool accent colors
  static const imageToPdf = Color(0xFF2196F3);
  static const mergePdf = Color(0xFF9C27B0);
  static const splitPdf = Color(0xFFFF9800);
  static const compressPdf = Color(0xFF009688);
  static const pdfToImage = Color(0xFF4CAF50);
  static const protectPdf = Color(0xFFE53935);
  static const unlockPdf = Color(0xFF3F51B5);

  static const surface = Color(0xFFFAFAFA);
  static const surfaceDark = Color(0xFF121212);
  static const cardLight = Colors.white;
  static const cardDark = Color(0xFF1E1E1E);

  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);

  static const divider = Color(0xFFE5E7EB);

  static LinearGradient get primaryGradient => const LinearGradient(
        colors: [primary, primaryDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient toolGradient(Color color) => LinearGradient(
        colors: [color, color.withValues(alpha: 0.7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
}
