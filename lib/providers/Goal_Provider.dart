import 'package:flutter/foundation.dart';
import 'package:safe/widgets/Goal.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:safe/providers/profile_provider.dart';

class GoalProvider extends ChangeNotifier {
  final ProfileProvider _profileProvider;
  List<Goal> _goals = [];

  GoalProvider(this._profileProvider) {
    _loadGoals();
  }

  List<Goal> get goals => List.unmodifiable(_goals);

  Future<void> _loadGoals() async {
    final currentProfile = _profileProvider.currentProfile;
    if (currentProfile != null) {
      _goals = await StorageService.loadGoals(currentProfile.id);
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal newGoal) async {
    final currentProfile = _profileProvider.currentProfile;
    if (currentProfile != null) {
      _goals.add(newGoal);
      await StorageService.saveGoals(currentProfile.id, _goals);
      notifyListeners();
    }
  }

  Future<void> removeGoal(int index) async {
    final currentProfile = _profileProvider.currentProfile;
    if (currentProfile != null) {
      _goals.removeAt(index);
      await StorageService.saveGoals(currentProfile.id, _goals);
      notifyListeners();
    }
  }

  Future<void> updateGoalProgress(int index, double amount) async {
    final currentProfile = _profileProvider.currentProfile;
    if (currentProfile != null && index >= 0 && index < _goals.length) {
      _goals[index].currentAmount += amount;
      await StorageService.saveGoals(currentProfile.id, _goals);
      notifyListeners();
    }
  }
}
