import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:hive_ce/hive.dart';

/// Service for managing app settings persistence.
///
/// This service handles direct database operations for settings data.
/// Uses a generic Hive box for key-value storage of settings.
class SettingsService {
  static const String nuxCompletionKey = 'hasCompletedNux';

  static bool _testMode = false;
  static Box? _testBox;

  static void enableTestMode(Box testBox) {
    _testMode = true;
    _testBox = testBox;
  }

  static void disableTestMode() {
    _testMode = false;
    _testBox = null;
  }

  static Box _getBox() {
    if (_testMode && _testBox != null) {
      return _testBox!;
    }
    return Hive.box(settingsBox);
  }

  /// Gets whether the New User Experience has been completed.
  static Future<bool> getNuxCompleted() async {
    final box = _getBox();
    return box.get(nuxCompletionKey, defaultValue: false) as bool;
  }

  /// Sets the NUX completion state.
  static Future<void> setNuxCompleted(bool value) async {
    final box = _getBox();
    await box.put(nuxCompletionKey, value);
  }
}
