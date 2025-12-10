
import '../services/api_client.dart';
import '../services/auth_service.dart';

enum AuthResult { success, invalidCredentials, networkError, unknownError }

class AuthRepository {
  final AuthService _authService;
  final ApiClient _apiClient;

  AuthRepository({required AuthService authService, required ApiClient apiClient})
      : _authService = authService,
        _apiClient = apiClient;

  Future<AuthResult> login(String email, String password) async {
    try {
      await _authService.login(email, password);
      return AuthResult.success;
    } on UnauthorizedException {
      return AuthResult.invalidCredentials;
    } on ApiException {
      return AuthResult.networkError;
    } catch (e) {
      return AuthResult.unknownError;
    }
  }

  Future<AuthResult> signUp(String email, String password, String username) async {
    try {
      await _authService.signUp(email, password, username);
      return AuthResult.success;
    } on UnauthorizedException {
      return AuthResult.invalidCredentials;
    } on ApiException {
      return AuthResult.networkError;
    } catch (e) {
      return AuthResult.unknownError;
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getToken();
    return token != null;
  }

  Future<void> logout() async {
    await _apiClient.deleteToken();
  }
}
