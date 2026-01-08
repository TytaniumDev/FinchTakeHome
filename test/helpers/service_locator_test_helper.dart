import 'package:birdo/core/services/server_service.dart';
import 'package:birdo/core/services/service_locator.dart';

import 'test_helpers.dart';

/// A test helper for initializing the ServiceLocator with test-friendly implementations
class ServiceLocatorTestHelper {
  static MockDateTimeService? _mockDateTimeService;

  static MockDateTimeService get mockDateTimeService {
    if (_mockDateTimeService == null) {
      throw Exception(
        'MockDateTimeService not initialized. Call ServiceLocatorTestHelper.initialize() first.',
      );
    }
    return _mockDateTimeService!;
  }

  /// Initialize the ServiceLocator for tests
  static Future<void> initialize() async {
    // Create mock services
    _mockDateTimeService = MockDateTimeService();
    final mockServerService = MockServerService();

    // Set the mock services in the ServiceLocator
    ServiceLocator.setTestServices(
      dateTimeService: _mockDateTimeService!,
      serverService: mockServerService,
    );
  }
}

// Mock implementation of ServerService for testing
class MockServerService implements ServerService {
  @override
  Future<Map<String, dynamic>> makePostRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    // Mock implementation that returns success
    return {'success': true};
  }

  @override
  Future<Map<String, dynamic>> makeGetRequest(
    String endpoint, [
    Map<String, dynamic>? queryParameters,
  ]) async {
    // Mock implementation that returns success
    return {'success': true};
  }
}
