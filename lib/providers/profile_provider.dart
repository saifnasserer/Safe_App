import 'package:flutter/material.dart';
import 'package:safe/models/profile.dart';
import 'package:safe/utils/storage_service.dart';
import 'package:uuid/uuid.dart';

class ProfileProvider extends ChangeNotifier {
  List<Profile> _profiles = [];
  Profile? _currentProfile;
  final _uuid = const Uuid();

  Profile? get currentProfile => _currentProfile;
  List<Profile> get profiles => List.unmodifiable(_profiles);

  Future<void> initialize() async {
    _profiles = await StorageService.loadProfiles();
    if (_profiles.isEmpty) {
      // Create default profile
      final defaultProfile = Profile(
        id: _uuid.v4(),
        name: 'Personal',
        primaryColor: const Color(0xff4558c8).value, // Updated default profile color
        isDefault: true,
        created: DateTime.now(),
      );
      _profiles.add(defaultProfile);
      await StorageService.saveProfiles(_profiles);
    }

    // Load last used profile or default to first profile
    final lastUsedProfileId = await StorageService.loadCurrentProfileId();
    if (lastUsedProfileId != null) {
      _currentProfile = _profiles.firstWhere(
        (profile) => profile.id == lastUsedProfileId,
        orElse: () => _profiles.first,
      );
    } else {
      _currentProfile = _profiles.first;
    }

    await StorageService.saveCurrentProfileId(_currentProfile!.id);
    notifyListeners();
  }

  Future<void> createProfile(String name, Color color) async {
    final newProfile = Profile(
      id: _uuid.v4(),
      name: name,
      primaryColor: color.value,
      isDefault: false,
      created: DateTime.now(),
    );

    _profiles.add(newProfile);
    await StorageService.saveProfiles(_profiles);
    await switchProfile(newProfile.id);
  }

  Future<void> deleteProfile(String profileId) async {
    final profileToDelete = _profiles.firstWhere((p) => p.id == profileId);
    if (profileToDelete.isDefault) {
      throw Exception('Cannot delete default profile');
    }

    _profiles.removeWhere((p) => p.id == profileId);
    await StorageService.saveProfiles(_profiles);

    if (_currentProfile?.id == profileId) {
      // Switch to default profile if current profile is deleted
      final defaultProfile = _profiles.firstWhere((p) => p.isDefault);
      await switchProfile(defaultProfile.id);
    } else {
      notifyListeners();
    }
  }

  Future<void> switchProfile(String profileId) async {
    final newProfile = _profiles.firstWhere((p) => p.id == profileId);
    _currentProfile = newProfile;
    await StorageService.saveCurrentProfileId(profileId);
    notifyListeners();
  }

  Future<void> updateProfile(Profile updatedProfile) async {
    final index = _profiles.indexWhere((p) => p.id == updatedProfile.id);
    if (index != -1) {
      _profiles[index] = updatedProfile;
      await StorageService.saveProfiles(_profiles);
      if (_currentProfile?.id == updatedProfile.id) {
        _currentProfile = updatedProfile;
      }
      notifyListeners();
    }
  }
}
