import 'package:birdo/controllers/base_controller.dart';
import 'package:birdo/model/managers/settings_manager.dart';

/// Controller for managing the New User Experience (NUX) flow.
///
/// This controller coordinates the NUX onboarding process and delegates
/// persistence to SettingsManager.
class NuxController extends BaseController {
  final SettingsManager _settingsManager;

  int _currentScreenIndex = 0;
  String? birdName;
  String? userName;

  NuxController({required SettingsManager settingsManager})
      : _settingsManager = settingsManager;

  int getCurrentScreenIndex() => _currentScreenIndex;

  int getTotalScreenCount() => 2;

  Future<bool> isNuxCompleted() async {
    return _settingsManager.nuxCompleted;
  }

  Future<void> completeNux() async {
    await _settingsManager.completeNux();
  }

  /// Reset the NUX completion state (for debugging)
  Future<void> resetNux() async {
    await _settingsManager.resetNux();
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
