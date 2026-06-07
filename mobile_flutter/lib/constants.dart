import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart' as intl;
import 'package:get/get.dart';
import 'package:mobile_flutter/controllers/settings_controller.dart';

class AppColors {
  // Brand Colors
  static Color get primary {
    try {
      if (Get.isRegistered<SettingsController>()) {
        final settingsController = Get.find<SettingsController>();
        final hexColor = settingsController.settings['primary_color'] ?? settingsController.settings['color'];
        if (hexColor != null && hexColor.toString().isNotEmpty) {
          return Color(int.parse(hexColor.toString().replaceAll('#', '0xFF')));
        }
      }
    } catch (_) {}
    return const Color(0xFFE8781A); // Fallback
  }

  static Color get primaryLight {
    return primary.withOpacity(0.05);
  }
  
  // Slate Scale (Matching Tailwind Slate)
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  // Functional Colors
  static const Color background = Color(0xFFF7F6F3);
  static const Color cardBg = Colors.white;
  static const Color success = Color(0xFF1D9E75);
  static const Color warning = Color(0xFFE24B4A); // Mapped to Danger
  static const Color info = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF6366F1);

  // Legacy (for compatibility if needed)
  static const Color secondary = slate200;
  static const Color textPrimary = slate900;
  static const Color textSecondary = slate500;
}

class AppDesign {
  static const double radiusXL = 32.0;
  static const double radiusL = 24.0;
  static const double radiusM = 16.0;
  static const double radiusS = 12.0;

  static const BoxShadow shadow = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 20,
    offset: Offset(0, 10),
  );

  static const BoxShadow shadowLg = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 30,
    offset: Offset(0, 15),
  );

  static const BoxShadow shadowMd = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 15,
    offset: Offset(0, 5),
  );
}

class ApiConstants {
  static String? _customBaseUrl;

  static void setCustomBaseUrl(String? url) {
    _customBaseUrl = url;
  }

  static String get baseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }
    return 'https://menuku.icaadrm.my.id/api';
  }
}

class CurrencyFormat {
  static String convertToIdr(dynamic number, int decimalDigit) {
    num parsedNumber = 0;
    if (number is String) {
      parsedNumber = num.tryParse(number) ?? 0;
    } else if (number is num) {
      parsedNumber = number;
    }
    
    final intl.NumberFormat currencyFormatter = intl.NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: decimalDigit,
    );
    return currencyFormatter.format(parsedNumber);
  }
}
