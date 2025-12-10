import 'package:arise2/repositories/auth_repository.dart';
import 'package:flutter/material.dart';

enum AuthStatus { uninitialized, authenticating, authenticated, unauthenticated }

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  AuthStatus _status = AuthStatus.uninitialized;

  AuthViewModel({required AuthRepository authRepository}) : _authRepository = authRepository {
    _checkAuthStatus();
  }

  AuthStatus get status => _status;

  Future<void> _checkAuthStatus() async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    final isAuthenticated = await _authRepository.isAuthenticated();
    _status = isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    final result = await _authRepository.login(email, password);
    if (result == AuthResult.success) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String username) async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    final result = await _authRepository.signUp(email, password, username);
    if (result == AuthResult.success) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
