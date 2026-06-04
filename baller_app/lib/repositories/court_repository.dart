import 'package:baller_app/core/api/api_client.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourtRepository {
  CourtRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> fetchApprovedCourts() async {
    if (AppConfig.useLegacySupabase) {
      final res = await Supabase.instance.client
          .from('courts')
          .select()
          .eq('status', 'approved');
      return List<Map<String, dynamic>>.from(res as List);
    }

    final res = await _apiClient.dio.get('/courts');
    return List<Map<String, dynamic>>.from(res.data as List);
  }

  Future<String> createCourt({
    required String name,
    required double latitude,
    required double longitude,
    required bool indoor,
    required bool hasLights,
    required bool hasCourtMarkings,
    required String groundType,
    required int hoops,
    required String address,
  }) async {
    if (AppConfig.useLegacySupabase) {
      final res = await Supabase.instance.client
          .from('courts')
          .insert({
            'source': 'community',
            'name': name,
            'lat': latitude,
            'lng': longitude,
            'indoor': indoor,
            'lights': hasLights,
            'has_markings': hasCourtMarkings,
            'surface': groundType,
            'hoops': hoops,
            'address': address,
          })
          .select('id')
          .single();
      return res['id'] as String;
    }

    final res = await _apiClient.dio.post(
      '/courts',
      data: {
        'name': name,
        'lat': latitude,
        'lng': longitude,
        'indoor': indoor,
        'lights': hasLights,
        'has_markings': hasCourtMarkings,
        'surface': groundType,
        'hoops': hoops,
        'address': address,
      },
    );
    final data = res.data as Map<String, dynamic>;
    return data['id'] as String;
  }
}
