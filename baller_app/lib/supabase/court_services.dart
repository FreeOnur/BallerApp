import 'package:supabase_flutter/supabase_flutter.dart';

class CourtServices {
  final SupabaseClient _supabase = Supabase.instance.client;

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
}
