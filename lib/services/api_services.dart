import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://pooja-healthcare.ortdemo.com';
  static const Duration _defaultTimeout = Duration(seconds: 30);

  final Map<String, String> _defaultHeaders = {
    'Accept': 'application/json',
    'Cookie':
        'connect.sid=s%3AQB0Ya2sULe8_Lgxpc2_qiMolSaRngElR.i%2BdKncpQaUpFizDa%2BxtBKNITJOExxWIhZEO2UV%2BArWQ',
  };

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// Main request method
  Future<dynamic> _request({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = {..._defaultHeaders, ...?headers};
      final requestTimeout = timeout ?? _defaultTimeout;

      http.Response response;

      switch (method) {
        case 'GET':
          response = await http
              .get(uri, headers: requestHeaders)
              .timeout(requestTimeout);
          break;
        case 'POST':
          response = await http
              .post(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(requestTimeout);
          break;
        case 'PUT':
          response = await http
              .put(
                uri,
                headers: requestHeaders,
                body: body != null ? jsonEncode(body) : null,
              )
              .timeout(requestTimeout);
          break;
        case 'DELETE':
          response = await http
              .delete(
                uri,
                headers: requestHeaders,
              )
              .timeout(requestTimeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return _handleResponse(response);
    } on TimeoutException {
      throw Exception('Request timed out');
    } on http.ClientException {
      throw Exception('Network error occurred');
    } catch (e) {
      throw Exception('API request failed: $e');
    }
  }

  /// Handles the HTTP response
  dynamic _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final responseBody = response.body;

    try {
      final jsonResponse = jsonDecode(responseBody);

      if (statusCode >= 200 && statusCode < 300) {
        return jsonResponse;
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Request failed with status $statusCode',
        );
      }
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }

  /// GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    return await _request(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
    );
  }

  /// POST request
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return await _request(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      headers: headers,
    );
  }

  /// PUT request
  Future<dynamic> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return await _request(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      headers: headers,
    );
  }

  /// DELETE request
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    return await _request(
      method: 'DELETE',
      endpoint: endpoint,
      headers: headers,
    );
  }
}
