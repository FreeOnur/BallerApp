import 'package:baller_app/core/config/app_config.dart';
import 'package:baller_app/repositories/api_auth_repository.dart';
import 'package:baller_app/repositories/auth_repository.dart';
import 'package:baller_app/repositories/auth_result.dart';
import 'package:baller_app/repositories/profile_repository.dart';
import 'package:baller_app/repositories/repository_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService({
    AuthRepository? authRepository,
    ProfileRepository? profileRepository,
  })  : _auth = authRepository ?? RepositoryProvider.auth,
        _profiles = profileRepository ?? RepositoryProvider.profiles;

  final AuthRepository _auth;
  final ProfileRepository _profiles;

  Future<AuthResult> signInWithEmailPassword(String email, String password) {
    return _auth.signInWithEmailPassword(email, password);
  }

  Future<AuthResult> signUp(String email, String password) {
    return _auth.signUp(email, password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<bool> hasSession() => _auth.hasSession();

  Future<String?> resolveUserId() async {
    final syncId = _auth.getCurrentUserId();
    if (syncId != null) return syncId;
    if (_auth is ApiAuthRepository) {
      return _auth.getUserIdAsync();
    }
    return null;
  }

  Future<void> createProfile({
    required String username,
    String? avatarURL,
    required int? age,
    required int? location,
    required int? gender,
    required int? skillLevel,
  }) async {
    final userId = await resolveUserId();
    if (userId == null) {
      throw Exception('No user logged in!');
    }
    try {
      await _profiles.upsertProfile(
        userId: userId,
        username: username,
        age: age,
        location: location,
        gender: gender,
        skillLevel: skillLevel,
        avatarUrl: avatarURL,
      );
    } catch (e) {
      throw Exception('Failed to create profile: $e');
    }
  }

  String? getCurrentUserEmail() => _auth.getCurrentUserEmail();

  String? getCurrentUserId() => _auth.getCurrentUserId();

  /// Password reset — Supabase only until API forgot-password is wired.
  Future<void> resetPasswordForEmail(String email) async {
    if (!AppConfig.useLegacySupabase) {
      throw UnsupportedError('Use API forgot-password when USE_LEGACY_SUPABASE=false');
    }
    await Supabase.instance.client.auth.resetPasswordForEmail(email);
  }
}
