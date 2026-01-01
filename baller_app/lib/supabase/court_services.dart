import 'package:supabase_flutter/supabase_flutter.dart';

class CourtServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createCourt({
    required String name,
    required double latitude,
    required double longitude,
    required bool indoor,
    required bool hasLights,
    required bool hasCourtMarkings,
    required String groundType,
    required int hoops,
    required String address, 
    int radiusMeters = 100,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Not logged in');

    final nearby = await _supabase.rpc(
      'find_court_within_radius',
      params: {
        'p_lat': latitude,
        'p_lng': longitude,
        'p_radius_m': radiusMeters,
      },
    );

    if (nearby != null && nearby.isNotEmpty) {
      throw Exception('Court existiert bereits im Umkreis von ${radiusMeters}m');
    }

    await _supabase.from('courts').insert({
      'name': name,
      'lat': latitude,
      'lng': longitude,
      'indoor': indoor,
      'light': hasLights,
      'court_markings': hasCourtMarkings,
      'ground': groundType,
      'hoops': hoops,
      'address': address,
      'created_by': user.id,
    });
  }
}
