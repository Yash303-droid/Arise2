
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<AuthSuccess> login(String email, String password) async {
    final data = {'email': email, 'password': password};
    final response = await _apiClient.post('/auth/login', data);
    final authSuccess = AuthSuccess.fromJson(response as Map<String, dynamic>);
    await _apiClient.saveUserId(authSuccess.userId.toString());
    if (authSuccess.token != null) {
      await _apiClient.saveToken(authSuccess.token!);
    }
    return authSuccess;
  }

  Future<AuthSuccess> signUp(String email, String password, String username) async {
    final data = {'email': email, 'password': password, 'username': username};
    final response = await _apiClient.post('/auth/signup', data);
    final authSuccess = AuthSuccess.fromJson(response as Map<String, dynamic>);
    await _apiClient.saveUserId(authSuccess.userId.toString());
    if (authSuccess.token != null) {
      await _apiClient.saveToken(authSuccess.token!);
    }
    return authSuccess;
  }
}

class AuthSuccess {
  final int userId;
  final String message;
  final String? token;

  AuthSuccess({required this.userId, required this.message, this.token});

  factory AuthSuccess.fromJson(Map<String, dynamic> json) {
    return AuthSuccess(
      userId: json['user_id'] as int,
      message: json['message'] as String,
      token: json['access_token'] as String? ?? json['token'] as String?,
    );
  }
}
