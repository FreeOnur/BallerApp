import 'dart:ffi';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up with email password
  Future<AuthResponse> signUp(String email, String password) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Wenn Signup erfolgreich, Profil anlegen
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

    return response;
  }

  // Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Create Profile
  Future<void> createProfile({
    required String username,
    String? avatarURL,
    required Int age,
    required int location,
    required int gender,
    required int skillLevel,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in!');
    }

    final response = await _supabase.from('profiles').update({
      'id': user.id,
      'username': username,
      'age': age,
      'location': location,
      'gender': gender,
      'skill_level': skillLevel,
    });

    if (response.error != null) {
      throw Exception(response.error!.message);
    }
  }

  // Get User Email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}
