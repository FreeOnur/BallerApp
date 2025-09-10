import 'dart:ffi';

import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(
    String email, String password) async {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password);
    }

    // Sign up with email password
    Future<AuthResponse> signUp(String email, String password) async {
      return await _supabase.auth.signUp(
        email: email,
        password: password);
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
      required int skillLevel
    }) async {
      final user = _supabase.auth.currentUser;
      if(user == null) {
        throw Exception('No user logged in!');
      }

      final response = await _supabase.from('profiles').insert({
        'id': user.id,
        'username': username,
        'avatar_url': avatarURL,
        'age': age,
        'location': location,
        'gender': gender,
        'skill_level': skillLevel
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