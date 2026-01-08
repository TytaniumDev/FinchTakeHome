import 'package:birdo/controllers/base_controller.dart';
import 'package:birdo/core/constants/hive_boxes.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Controller for managing the New User Experience (NUX) flow
class NuxController extends BaseController {
  static const String nuxCompletionKey = 'hasCompletedNux';

  int _currentScreenIndex = 0;
  String? birdName;
  String? userName;

  int getCurrentScreenIndex() => _currentScreenIndex;

  int getTotalScreenCount() => 2;

  Future<bool> isNuxCompleted() async {
    final settings = Hive.box(settingsBox);
    return settings.get(nuxCompletionKey, defaultValue: false) as bool;
  }

  Future<void> completeNux() async {
    final settings = Hive.box(settingsBox);
    await settings.put(nuxCompletionKey, true);
  }

  /// Reset the NUX completion state (for debugging)
  Future<void> resetNux() async {
    final settings = Hive.box(settingsBox);
    await settings.put(nuxCompletionKey, false);
    _currentScreenIndex = 0;
    birdName = null;
    userName = null;
  }

  void goToNextScreen() {
    if (_currentScreenIndex < getTotalScreenCount() - 1) {
      _currentScreenIndex++;
    }
  }

  void goToPreviousScreen() {
    if (_currentScreenIndex > 0) {
      _currentScreenIndex--;
    }
  }

  @override
  Future<void> onInitialize() async {}
}
