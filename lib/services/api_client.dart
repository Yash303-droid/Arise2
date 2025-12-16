
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient({required this.baseUrl, http.Client? client})
      : _client = client ?? http.Client();

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: 'user_id', value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: 'user_id');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'user_id');
  }

  Future<dynamic> post(String path, dynamic requestData, {bool requireAuth = false}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await getToken();
      if (token == null) {
        throw UnauthorizedException('Authentication token not found.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await _client.post(
      uri,
      headers: headers,
      body: jsonEncode(requestData),
    );

    return _handleResponse(response);
  }

  Future<dynamic> get(String path, {bool requireAuth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await getToken();
      if (token == null) {
        throw UnauthorizedException('Authentication token not found.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await _client.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, dynamic requestData, {bool requireAuth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await getToken();
      if (token == null) {
        throw UnauthorizedException('Authentication token not found.');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await _client.put(
      uri,
      headers: headers,
      body: jsonEncode(requestData),
    );

    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {bool requireAuth = true}) async {
     final uri = Uri.parse('$baseUrl$path');
    final headers = {'Content-Type': 'application/json'};

    if (requireAuth) {
      final token = await getToken();
      if (token == null) {
        throw UnauthorizedException('Authentication token not found.');
      }
      headers['Authorization'] = 'Bearer $token';
    }
    final response = await _client.delete(uri, headers: headers);
    return _handleResponse(response);
  }


  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  Exception _handleError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        return UnauthorizedException(jsonDecode(response.body)['message'] ?? 'Unauthorized');
      default:
        return ApiException('API Error: ${response.statusCode} - ${response.reasonPhrase}');
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message);
}
