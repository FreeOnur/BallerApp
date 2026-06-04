import 'package:baller_app/core/api/api_client.dart';
import 'package:baller_app/core/api/token_storage.dart';
import 'package:baller_app/repositories/auth_repository.dart';
import 'package:baller_app/repositories/auth_result.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({ApiClient? apiClient, TokenStorage? tokenStorage})
      : _client = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _client;
  final TokenStorage _tokenStorage;

  Future<void> _persistTokens(Map<String, dynamic> data) async {
    await _tokenStorage.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      userId: data['user_id'] as String,
    );
  }

  @override
  Future<AuthResult> signInWithEmailPassword(String email, String password) async {
    final res = await _client.dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data as Map<String, dynamic>;
    await _persistTokens(data);
    return AuthResult(userId: data['user_id'] as String, email: email);
  }

  @override
  Future<AuthResult> signUp(String email, String password) async {
    final res = await _client.dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );
    final data = res.data as Map<String, dynamic>;
    await _persistTokens(data);
    return AuthResult(userId: data['user_id'] as String, email: email);
  }

  @override
  Future<void> signOut() async {
    final refresh = await _tokenStorage.getRefreshToken();
    if (refresh != null) {
      try {
        await _client.dio.post('/auth/logout', data: {'refresh_token': refresh});
      } catch (_) {
        // Clear local session even if server logout fails
      }
    }
    await _tokenStorage.clear();
  }

  @override
  Future<bool> hasSession() => _tokenStorage.hasSession();

  @override
  String? getCurrentUserEmail() => null;

  @override
  String? getCurrentUserId() {
    // Sync read not available from secure storage; use async in gate
    return null;
  }

  Future<String?> getUserIdAsync() => _tokenStorage.getUserId();
}
