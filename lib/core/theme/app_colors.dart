import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Neutrals
  static const white     = Color(0xFFFFFFFF); // canvas + on-dark text
  static const textBlack = Color(0xFF000000); // hero headings

  // Brand
  static const primary = Color(0xFF6C63FF);

  // Text / content (semantic — mirror ColorScheme roles)
  static const textDark  = Color(0xFF1A1A2E); // colorScheme.onSurface
  static const textMid   = Color(0xFF6B6B80); // colorScheme.onSurfaceVariant
  static const textLight = Color(0xFF9B9BAD); // colorScheme.outline

  // Surface / card backgrounds
  static const surfaceLavender = Color(0xFFECE8FF);
  static const surfaceBlue     = Color(0xFFE8F4FD);
  static const surfaceGreen    = Color(0xFFD4EDE8);

  // Borders / dividers
  static const borderSubtle = Color(0xFFE8E8EE);
  static const borderLight  = Color(0xFFF0F0F5);

  // Component — word chips
  static const chipBackground = Color(0xFFF5F3FF);
  static const chipBorder     = Color(0xFFE0D9FF);

  // Component — empty states
  static const iconMuted = Color(0xFFD0D0E0);
  static const textHint  = Color(0xFFC0C0D0);

  // Component — charts
  static const chartBar1 = Color(0xFFC8B8FF);
  static const chartBar2 = Color(0xFFB8F0E8);
}
