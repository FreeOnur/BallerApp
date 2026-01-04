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
          'name': name,
          'lat': latitude,
          'lng': longitude,
          'indoor': indoor,
          'light': hasLights,
          'court_markings': hasCourtMarkings,
          'ground': groundType,
          'hoops': hoops,
          'address': address,
        })
        .select('id')
        .single();

    return res['id'] as String;
  }
}
