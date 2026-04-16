import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Post tile / saved tile — ID badge and userId metadata
  static const postMeta = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textLight,
  );

  // Post tile / saved tile — title (Playfair Display)
  static TextStyle get postCardTitle => GoogleFonts.playfairDisplay(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
      );

  // Post tile / saved tile — body preview (2 lines)
  static const postBodyPreview = TextStyle(
    fontSize: 13,
    color: AppColors.textMid,
    height: 1.5,
  );

  // Stats page — section headings ("Posts per Author", "Trending Words", etc.)
  static const sectionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
}
