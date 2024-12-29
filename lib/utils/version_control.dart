import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionControl {
  static const String _lastSeenVersionKey = 'last_seen_version';
  static const String currentVersion = '1.0.0'; // Matches pubspec.yaml version

  static final Map<String, String> updateNotes = {
    '1.0.0': '''
  • اضافة امكانية انك تقدر تشوف في الشاشة الرئيسية مصاريفيك اليومية والاسبوعية  والشهرية او تشوف مصاريف يوم معين لواحدة
  • دلوقتي تقدر في صفحة الحساب تشوف مصاريقك كامله او الفلوس اللي تم اضافتها كل حاجة لواحدها عن طريق فلتر
  • اختبار
  ''',
  };

  static Future<bool> shouldShowUpdateNotes(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeenVersion = prefs.getString(_lastSeenVersionKey) ?? '0.0.0';
    
    if (lastSeenVersion != currentVersion) {
      await prefs.setString(_lastSeenVersionKey, currentVersion);
      return true;
    }
    return false;
  }

  static String? getUpdateNotes() {
    return updateNotes[currentVersion];
  }
}
