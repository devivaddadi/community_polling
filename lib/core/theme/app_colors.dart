import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (Modern Indigo & Violet)
  static const Color primary = Color(0xFF4F46E5); // Indigo 600
  static const Color primaryDark = Color(0xFF3730A3); // Indigo 800
  static const Color primaryLight = Color(0xFF6366F1); // Indigo 500
  static const Color primaryAccent = Color(0xFF818CF8); // Indigo 400
  static const Color primaryContainer = Color(0xFFEEF2FF); // Indigo 50

  static const Color primaryGradientStart = Color(0xFF4F46E5);
  static const Color primaryGradientEnd = Color(0xFF7C3AED); // Purple 600
  static const Color primaryGradientAlt = Color(0xFF9333EA); // Purple 700

  // Secondary Accents
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color secondaryContainer = Color(0xFFECFEFF);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentRoseBg = Color(0xFFFFE4E6);

  // Background & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color cardBackground = Colors.white;
  static const Color surface = Color(0xFFF1F5F9); // Slate 100
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color glassWhite = Color(0xCCFFFFFF); // 80% opacity white

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textWhite = Colors.white;

  // Status & Accents
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successBg = Color(0xFFDCFCE7);
  static const Color successText = Color(0xFF15803D);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFFB45309);

  static const Color danger = Color(0xFFEF4444); // Red
  static const Color dangerBg = Color(0xFFFEE2E2);
  static const Color dangerText = Color(0xFFB91C1C);

  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoBg = Color(0xFFDBEAFE);
  static const Color infoText = Color(0xFF1D4ED8);

  // Chart Palette (Matching reference)
  static const Color chartBlue = Color(0xFF3B82F6);
  static const Color chartTeal = Color(0xFF06B6D4);
  static const Color chartGreen = Color(0xFF10B981);
  static const Color chartAmber = Color(0xFFF59E0B);
  static const Color chartPurple = Color(0xFF8B5CF6);
  static const Color chartPink = Color(0xFFEC4899);

  static const List<Color> chartColors = [
    chartBlue,
    chartTeal,
    chartGreen,
    chartAmber,
    chartPurple,
    chartPink,
  ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGradientStart, primaryGradientEnd],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4338CA), Color(0xFF6D28D9), Color(0xFF7C3AED)],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFF97316)],
  );

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color borderFocus = Color(0xFF6366F1);

  // Shadows
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> buttonGlow = [
    BoxShadow(
      color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
      blurRadius: 14,
      offset: const Offset(0, 4),
    ),
  ];

  // Category Color Scheme Helper
  static CategoryColors getCategoryColors(String category) {
    switch (category.toLowerCase()) {
      case 'facilities':
      case 'amenities':
        return const CategoryColors(
          color: Color(0xFF0284C7),
          bg: Color(0xFFE0F2FE),
          icon: Icons.apartment_rounded,
        );
      case 'security':
        return const CategoryColors(
          color: Color(0xFF059669),
          bg: Color(0xFFD1FAE5),
          icon: Icons.shield_outlined,
        );
      case 'budget':
      case 'finance':
        return const CategoryColors(
          color: Color(0xFFD97706),
          bg: Color(0xFFFEF3C7),
          icon: Icons.account_balance_wallet_outlined,
        );
      case 'social':
      case 'events':
        return const CategoryColors(
          color: Color(0xFF9333EA),
          bg: Color(0xFFF3E8FF),
          icon: Icons.celebration_outlined,
        );
      case 'rules':
      case 'bylaws':
        return const CategoryColors(
          color: Color(0xFFE11D48),
          bg: Color(0xFFFFE4E6),
          icon: Icons.gavel_rounded,
        );
      case 'environment':
      case 'eco':
        return const CategoryColors(
          color: Color(0xFF16A34A),
          bg: Color(0xFFDCFCE7),
          icon: Icons.eco_outlined,
        );
      default:
        return const CategoryColors(
          color: Color(0xFF4F46E5),
          bg: Color(0xFFEEF2FF),
          icon: Icons.ballot_outlined,
        );
    }
  }
}

class CategoryColors {
  final Color color;
  final Color bg;
  final IconData icon;

  const CategoryColors({
    required this.color,
    required this.bg,
    required this.icon,
  });
}
