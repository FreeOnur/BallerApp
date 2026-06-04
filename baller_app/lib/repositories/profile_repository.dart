import 'package:baller_app/core/api/api_client.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  ProfileRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<bool> hasProfile({String? userId}) async {
    if (AppConfig.useLegacySupabase) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return false;
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      return response != null;
    }

    if (userId == null) return false;
    try {
      await _apiClient.dio.get('/profiles/me');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> upsertProfile({
    required String userId,
    required String username,
    int? age,
    int? location,
    int? gender,
    int? skillLevel,
    String? avatarUrl,
  }) async {
    if (AppConfig.useLegacySupabase) {
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'username': username,
        'age': age,
        'location': location,
        'gender': gender,
        'skill_level': skillLevel,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      });
      return;
    }

    await _apiClient.dio.put(
      '/profiles/me',
      data: {
        'username': username,
        'age': age,
        'location': location,
        'gender': gender,
        'skill_level': skillLevel,
        'avatar_url': avatarUrl,
      },
    );
  }
}
