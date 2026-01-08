import 'package:flutter/foundation.dart';

/// Controllers are responsible for handling user actions and coordinating
/// between the view and model layers. They contain the application logic
/// that doesn't belong in either the view or model layers.
abstract class BaseController {
  /// Flag to track if the controller has been initialized
  bool _isInitialized = false;

  /// Getter to check if the controller has been initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the controller
  ///
  /// This method should be called once when the controller is first created.
  /// It should set up any necessary state and connections to models.
  /// Subclasses should override this method to provide specific initialization logic.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await onInitialize();

    _isInitialized = true;
  }

  /// Hook for subclasses to implement their initialization logic
  ///
  /// This method is called by [initialize] and should be overridden
  /// by subclasses to provide specific initialization logic.
  Future<void> onInitialize();

  /// Log a message with the controller's name
  ///
  /// This is a convenience method for logging that includes the controller's name.
  void log(String message) {
    debugPrint('${runtimeType.toString()}: $message');
  }

  /// Dispose of any resources
  ///
  /// This method is called when the controller is no longer needed.
  /// Subclasses should override this method to clean up any resources.
  void dispose() {
    // Base implementation does nothing
  }
}
