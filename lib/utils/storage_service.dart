import 'dart:convert';
import 'package:safe/models/profile.dart';
import 'package:safe/widgets/item.dart';
import 'package:safe/Blocks/Goal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _itemsKey = 'items';
  static const String _goalsKey = 'goals';
  static const String _walletKey = 'wallet';
  static const String _spentKey = 'spent';
  static const String _profilesKey = 'profiles';
  static const String _currentProfileKey = 'current_profile';
  static const String _userNameKey = 'user_name';
  static const String _isFirstLaunchKey = 'is_first_launch';

  // Profile-specific key generators
  static String _getProfileItemsKey(String profileId) =>
      'profile_${profileId}_items';
  static String _getProfileGoalsKey(String profileId) =>
      'profile_${profileId}_goals';
  static String _getProfileWalletKey(String profileId) =>
      'profile_${profileId}_wallet';
  static String _getProfileSpentKey(String profileId) =>
      'profile_${profileId}_spent';

  static Future<void> saveItems(String profileId, List<item> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = items.map((item) => item.toJson()).toList();
    await prefs.setString(
        _getProfileItemsKey(profileId), jsonEncode(itemsJson));
  }

  static Future<List<item>> loadItems(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_getProfileItemsKey(profileId));
    if (itemsJson == null) return [];

    final List<dynamic> decodedItems = jsonDecode(itemsJson);
    return decodedItems.map((json) => item.fromJson(json)).toList();
  }

  static Future<void> saveGoals(String profileId, List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = goals.map((goal) => goal.toJson()).toList();
    await prefs.setString(
        _getProfileGoalsKey(profileId), jsonEncode(goalsJson));
  }

  static Future<List<Goal>> loadGoals(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_getProfileGoalsKey(profileId));
    if (goalsJson == null) return [];

    final List<dynamic> decodedGoals = jsonDecode(goalsJson);
    return decodedGoals.map((json) => Goal.fromJson(json)).toList();
  }

  static Future<void> saveWalletBalance(
      String profileId, double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_getProfileWalletKey(profileId), balance);
  }

  static Future<double> loadWalletBalance(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_getProfileWalletKey(profileId)) ?? 0.0;
  }

  static Future<void> saveSpentAmount(String profileId, double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_getProfileSpentKey(profileId), amount);
  }

  static Future<double> loadSpentAmount(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_getProfileSpentKey(profileId)) ?? 0.0;
  }

  static Future<void> saveProfiles(List<Profile> profiles) async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = profiles.map((profile) => profile.toJson()).toList();
    await prefs.setString(_profilesKey, jsonEncode(profilesJson));
  }

  static Future<List<Profile>> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final profilesJson = prefs.getString(_profilesKey);
    if (profilesJson == null) return [];

    final List<dynamic> decodedProfiles = jsonDecode(profilesJson);
    return decodedProfiles.map((json) => Profile.fromJson(json)).toList();
  }

  static Future<void> saveCurrentProfileId(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentProfileKey, profileId);
  }

  static Future<String?> loadCurrentProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentProfileKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstLaunchKey) ?? true;
  }

  static Future<void> setFirstLaunch(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstLaunchKey, value);
  }
}
