import 'package:birdo/model/managers/base_manager.dart';
import 'package:birdo/model/services/settings_service.dart';
import 'package:flutter/foundation.dart';

/// Manager for app settings state.
///
/// Handles the NUX (New User Experience) completion state and other
/// app-wide settings. Delegates persistence to SettingsService.
class SettingsManager extends BaseManager {
  bool _nuxCompleted = false;

  SettingsManager();

  bool get nuxCompleted => _nuxCompleted;

  @override
  Future<void> onInitialize() async {
    await loadSettings();
  }

  Future<void> loadSettings() async {
    debugPrint('SettingsManager: Loading settings...');
    try {
      _nuxCompleted = await SettingsService.getNuxCompleted();
      debugPrint('SettingsManager: NUX completed: $_nuxCompleted');
      notifyListeners();
    } catch (e) {
      debugPrint('SettingsManager: Error loading settings: $e');
    }
  }

  Future<void> completeNux() async {
    debugPrint('SettingsManager: Completing NUX...');
    try {
      await SettingsService.setNuxCompleted(true);
      _nuxCompleted = true;
      notifyListeners();
      debugPrint('SettingsManager: NUX completed successfully');
    } catch (e) {
      debugPrint('SettingsManager: Error completing NUX: $e');
    }
  }

  Future<void> resetNux() async {
    debugPrint('SettingsManager: Resetting NUX...');
    try {
      await SettingsService.setNuxCompleted(false);
      _nuxCompleted = false;
      notifyListeners();
      debugPrint('SettingsManager: NUX reset successfully');
    } catch (e) {
      debugPrint('SettingsManager: Error resetting NUX: $e');
    }
  }
}
