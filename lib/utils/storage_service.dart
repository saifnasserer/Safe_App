import 'dart:convert';
import 'package:safe/widgets/item.dart';
import 'package:safe/Blocks/Goal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _itemsKey = 'items';
  static const String _goalsKey = 'goals';
  static const String _walletKey = 'wallet';
  static const String _spentKey = 'spent';

  static Future<void> saveItems(List<item> items) async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = items.map((item) => item.toJson()).toList();
    await prefs.setString(_itemsKey, jsonEncode(itemsJson));
  }

  static Future<List<item>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsJson = prefs.getString(_itemsKey);
    if (itemsJson == null) return [];

    final List<dynamic> decodedItems = jsonDecode(itemsJson);
    return decodedItems.map((json) => item.fromJson(json)).toList();
  }

  static Future<void> saveGoals(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = goals.map((goal) => goal.toJson()).toList();
    await prefs.setString(_goalsKey, jsonEncode(goalsJson));
  }

  static Future<List<Goal>> loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final goalsJson = prefs.getString(_goalsKey);
    if (goalsJson == null) return [];

    final List<dynamic> decodedGoals = jsonDecode(goalsJson);
    return decodedGoals.map((json) => Goal.fromJson(json)).toList();
  }

  static Future<void> saveWalletBalance(double balance) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_walletKey, balance);
  }

  static Future<double> loadWalletBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_walletKey) ?? 0.0;
  }

  static Future<void> saveSpentAmount(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_spentKey, amount);
  }

  static Future<double> loadSpentAmount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_spentKey) ?? 0.0;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
