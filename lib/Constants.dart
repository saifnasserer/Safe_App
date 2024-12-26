import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/providers/profile_provider.dart';

class Constants {
  static const String defaultFontFamily = 'CairoBold';
  static const String titles = 'GhaithSans';
  static const String secondaryFontFamily = 'Cairo';
  static const Color scaffoldBackgroundColor = Color(0xFFefefef);
  static const double defaultFontSize = 16.0;
  
  static Color getPrimaryColor(BuildContext context) {
    final profileProvider = context.read<ProfileProvider>();
    if (profileProvider.currentProfile != null) {
      return Color(profileProvider.currentProfile!.primaryColor);
    }
    return const Color(0xFF4558C8); // Default color if no profile
  }
}
