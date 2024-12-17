import 'package:flutter/material.dart';
import 'package:safe/Blocks/Goal.dart';
import 'package:safe/utils/storage_service.dart';

class GoalProvider extends ChangeNotifier {
  List<Goal> _goals = [];

  GoalProvider() {
    _loadGoals();
  }

  List<Goal> get goals => _goals;

  Future<void> _loadGoals() async {
    _goals = await StorageService.loadGoals();
    notifyListeners();
  }

  Future<void> addGoal(Goal newGoal) async {
    _goals.add(newGoal);
    await StorageService.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> removeGoal(int index) async {
    _goals.removeAt(index);
    await StorageService.saveGoals(_goals);
    notifyListeners();
  }

  Future<void> updateGoalProgress(int index, double amount) async {
    if (index >= 0 && index < _goals.length) {
      _goals[index].currentAmount += amount;
      await StorageService.saveGoals(_goals);
      notifyListeners();
    }
  }
}
