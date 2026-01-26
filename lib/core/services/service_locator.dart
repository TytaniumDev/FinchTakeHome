import 'package:birdo/controllers/nux_controller.dart';
import 'package:birdo/core/services/date_time_service.dart';
import 'package:birdo/core/services/server_service.dart';
import 'package:birdo/model/managers/settings_manager.dart';

class ServiceLocator {
  ServiceLocator._();

  static DateTimeService? _dateTimeService;
  static ServerService? _serverService;
  static SettingsManager? _settingsManager;
  static NuxController? _nuxController;

  static DateTimeService get dateTimeService {
    if (_dateTimeService == null) {
      throw Exception(
        'DateTimeService not initialized. Call ServiceLocator.initialize() first.',
      );
    }
    return _dateTimeService!;
  }

  static ServerService get serverService {
    if (_serverService == null) {
      throw Exception(
        'ServerService not initialized. Call ServiceLocator.initialize() first.',
      );
    }
    return _serverService!;
  }

  static NuxController get nuxController {
    if (_nuxController == null) {
      throw Exception(
        'NuxController not initialized. Call ServiceLocator.initialize() first.',
      );
    }
    return _nuxController!;
  }

  static SettingsManager get settingsManager {
    if (_settingsManager == null) {
      throw Exception(
        'SettingsManager not initialized. Call ServiceLocator.initialize() first.',
      );
    }
    return _settingsManager!;
  }

  static Future<void> initialize() async {
    _dateTimeService = DateTimeService();
    await _dateTimeService!.initialize();
    _serverService = ServerService();

    _settingsManager = SettingsManager();
    await _settingsManager!.initialize();

    _nuxController = NuxController(settingsManager: _settingsManager!);
    await _nuxController!.initialize();
  }

  /// Set services for testing
  /// This method should only be used in tests
  static void setTestServices({
    DateTimeService? dateTimeService,
    ServerService? serverService,
    SettingsManager? settingsManager,
    NuxController? nuxController,
  }) {
    if (dateTimeService != null) {
      _dateTimeService = dateTimeService;
    }

    if (serverService != null) {
      _serverService = serverService;
    }

    if (settingsManager != null) {
      _settingsManager = settingsManager;
    }

    if (nuxController != null) {
      _nuxController = nuxController;
    }
  }
}
