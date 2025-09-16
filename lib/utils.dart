import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// ** COLOR STYLES

// ** NEUTRAL
const Color neutral900 = Color(0xFF1F1F1F);
const Color neutral800 = Color(0xFF333333);
const Color neutral700 = Color(0xFF4A4A4A);
const Color neutral600 = Color(0xFF666666);
const Color neutral500 = Color(0xFF808080);
const Color neutral400 = Color(0xFF999999);
const Color neutral300 = Color(0xFFB3B3B3);
const Color neutral200 = Color(0xFFD1D1D1);
const Color neutral100 = Color(0xFFE0E0E0);
const Color neutral50 = Color(0xFFF0F0F0);

// ** BRAND COLOR
const Color brand900 = Color(0xFF071F4F);
const Color brand800 = Color(0xFF0B3583);
const Color brand700 = Color(0xFF12489E);
const Color brand600 = Color(0xFF1A5CBA);
const Color brand500 = Color(0xFF2670D4);
const Color brand400 = Color(0xFF08B2E3);
const Color brand300 = Color(0xFF4CC3F0);
const Color brand200 = Color(0xFF80D4F7);
const Color brand100 = Color(0xFFB3E4FA);
const Color brand50 = Color(0xFFE6F4FD);

// ** STATUS COLOR
const Color yellow700 = Color(0xFFFFD702);
const Color yellow600 = Color(0xFFDDC107);
const Color yellow400 = Color(0xFFFFF6AA);
const Color yellow50 = Color(0xFFFFFDF0);

const Color green600 = Color(0xFF067A4F);
const Color green400 = Color(0xFF089A69);
const Color green50 = Color(0xFFE6F4EF);

// ** FONT STYLES

// ** MOBILE HEADINGS
TextStyle mobileH1 = GoogleFonts.urbanist(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  color: neutral900,
);

TextStyle mobileH2 = GoogleFonts.urbanist(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: neutral900,
);

TextStyle mobileH3 = GoogleFonts.urbanist(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: neutral900,
);

TextStyle mobileH4 = GoogleFonts.urbanist(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: neutral900,
);

// ** DESKTOP HEADINGS
TextStyle desktopH1 = GoogleFonts.urbanist(
  fontSize: 40,
  fontWeight: FontWeight.w700,
  color: neutral900,
);

TextStyle desktopH2 = GoogleFonts.urbanist(
  fontSize: 32,
  fontWeight: FontWeight.w600,
  color: neutral900,
);

TextStyle desktopH3 = GoogleFonts.urbanist(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  color: neutral900,
);

TextStyle desktopH4 = GoogleFonts.urbanist(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: neutral900,
);

TextStyle desktopH5 = GoogleFonts.urbanist(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: neutral900,
);

// ** BODY TEXT
TextStyle bodyText18 = GoogleFonts.urbanist(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: neutral900,
);

TextStyle bodyText16 = GoogleFonts.urbanist(
  fontSize: 16,
  fontWeight: FontWeight.w500,
  color: neutral900,
);

TextStyle bodyText14 = GoogleFonts.urbanist(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  color: neutral900,
);

TextStyle bodyText12 = GoogleFonts.urbanist(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  color: neutral900,
);

// ** BUTTON TEXT
TextStyle buttonText = GoogleFonts.urbanist(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.white,
);

// ** LAYOUT CONSTANTS

class AppConstants {
  AppConstants._();

  static const double defaultPadding = 16.0;
  static final BorderRadius defaultBorderRadius = BorderRadius.circular(12.0);
}

// ** FORMATTERS

class AppFormatters {
  AppFormatters._();

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    } else {
      return "$twoDigitMinutes:$twoDigitSeconds";
    }
  }
}

// ** UI UTILS & HELPERS

class AppUtils {
  AppUtils._();

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: bodyText16),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
