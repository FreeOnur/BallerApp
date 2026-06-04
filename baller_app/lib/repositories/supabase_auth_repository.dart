import 'package:baller_app/repositories/auth_repository.dart';
import 'package:baller_app/repositories/auth_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<AuthResult> signInWithEmailPassword(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) {
      throw Exception('Sign in failed');
    }
    return AuthResult(userId: user.id, email: user.email);
  }

  @override
  Future<AuthResult> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(email: email, password: password);
    final user = response.user;
    if (user != null) {
      await _supabase.from('profiles').insert({
        'id': user.id,
        'username': '',
        'avatar_url': null,
        'age': null,
        'location': null,
        'gender': null,
        'skill_level': null,
      });
    }
    if (user == null) {
      throw Exception('Sign up failed');
    }
    return AuthResult(userId: user.id, email: user.email);
  }

  @override
  Future<void> signOut() => _supabase.auth.signOut();

  @override
  Future<bool> hasSession() async => _supabase.auth.currentSession != null;

  @override
  String? getCurrentUserEmail() => _supabase.auth.currentUser?.email;

  @override
  String? getCurrentUserId() => _supabase.auth.currentUser?.id;
}
