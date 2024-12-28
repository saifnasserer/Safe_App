import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/providers/profile_provider.dart';

class Constants {
  static const String defaultFontFamily = 'CairoBold';
  static const String titles = 'GhaithSans';
  static const String secondaryFontFamily = 'Cairo';
  static const Color scaffoldBackgroundColor = Color(0xFFefefef);
  static const double defaultFontSize = 16.0;

  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  static Color getPrimaryColor(BuildContext context) {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      return profileProvider.currentProfile != null
          ? Color(profileProvider.currentProfile!.primaryColor)
          : const Color(0xFF4558C8);
    } catch (e) {
      return const Color(0xFF4558C8);
    }
  }

  // Screen dimensions utilities
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Responsive sizing utilities
  static double heightPercent(BuildContext context, double percent) {
    return screenHeight(context) * (percent / 100);
  }

  static double widthPercent(BuildContext context, double percent) {
    return screenWidth(context) * (percent / 100);
  }

  static double responsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double scaleFactor = (screenWidth + screenHeight) / 1400; // baseline for average phone
    return baseSize * scaleFactor;
  }

  static double responsiveSpacing(BuildContext context, double baseSpacing) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSpacing * (screenWidth / 375); // 375 is iPhone SE width as baseline
  }

  static double responsiveSpacingNew(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double scaleFactor = (screenWidth + screenHeight) / 1400; // baseline for average phone
    return baseSize * scaleFactor;
  }

  static double responsiveRadius(BuildContext context, double baseSize) {
    return responsiveSpacingNew(context, baseSize);
  }

  // Device type checks
  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= mobileBreakpoint && 
           screenWidth(context) < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= desktopBreakpoint;
  }
}
