import 'package:dio/dio.dart';

const String _serverUrl = 'http://localhost:5000';

//! IMPORTANT: This flag should be toggled based on if your interview needs
//! to use any features that interact with the server.
//! If set to false, all requests to the server just succeed with fake data.
const bool enableServer = false;

typedef JSON = Map<String, dynamic>;

class ServerService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _serverUrl,
      // Note: server will return error JSON on non-200 and the client should parse this.
      validateStatus: (_) => true,
    ),
  );

  Future<JSON> makePostRequest(String endpoint, JSON body) async {
    if (!enableServer) {
      return {'success': true};
    }
    final response = await _dio.post(endpoint, data: body);
    return response.data;
  }

  Future<JSON> makeGetRequest(
    String endpoint, [
    Map<String, dynamic>? queryParameters,
  ]) async {
    if (!enableServer) {
      return {'success': true};
    }
    final response = await _dio.get(endpoint, queryParameters: queryParameters);
    return response.data;
  }
}
