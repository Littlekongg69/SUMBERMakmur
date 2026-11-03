import 'package:flutter/material.dart';

/// Design tokens sesuai PRD Bagian 33 & Bagian 14 (Referensi UI Mobile)
class DesignTokens {
  DesignTokens._();

  // Light Mode Tokens (Bagian 33)
  static const Color bgLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F7FA);
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF4B5563);
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color xpRewardLight = Color(0xFFF59E0B);
  static const Color successLight = Color(0xFF16A34A);
  static const Color errorLight = Color(0xFFDC2626);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Dark Mode Tokens (Bagian 33)
  static const Color bgDark = Color(0xFF0F1419);
  static const Color surfaceDark = Color(0xFF1A2129);
  static const Color textPrimaryDark = Color(0xFFE6EAF0);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color primaryDark = Color(0xFF60A5FA);
  static const Color xpRewardDark = Color(0xFFFBBF24);
  static const Color successDark = Color(0xFF4ADE80);
  static const Color errorDark = Color(0xFFF87171);
  static const Color borderDark = Color(0xFF2D3748);

  // Gradients for Mobile UI Reference (Bagian 14: latar gradasi biru muda)
  static const LinearGradient lightPageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFEFF6FF),
      Color(0xFFF8FAFC),
      Color(0xFFFFFFFF),
    ],
  );

  static const LinearGradient darkPageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF131C2E),
      Color(0xFF0F1419),
    ],
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF1D4ED8),
    ],
  );

  // SQL Block Colors (Bagian 14: keyword, kolom, tabel, operator, penutup)
  static const Color blockKeyword = Color(0xFF2563EB);
  static const Color blockColumn = Color(0xFF0D9488);
  static const Color blockTable = Color(0xFF7C3AED);
  static const Color blockOperator = Color(0xFFD97706);
  static const Color blockValue = Color(0xFF16A34A);
  static const Color blockClosing = Color(0xFF475569);

  // Radii & Spacing (Bagian 33: Card Radius 12/16, padding 16, touch target >= 44x44)
  static const double cardRadius = 16.0;
  static const double smallRadius = 10.0;
  static const double pillRadius = 999.0;
  static const double cardPadding = 16.0;
  static const double minTouchTarget = 44.0;
}

