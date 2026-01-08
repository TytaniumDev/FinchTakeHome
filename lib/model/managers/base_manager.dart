import 'package:flutter/foundation.dart';

abstract class BaseManager extends ChangeNotifier {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await onInitialize();

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> onInitialize();

  void notifyStateChanged() {
    notifyListeners();
  }
}
