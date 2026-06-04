import 'package:baller_app/repositories/court_repository.dart';
import 'package:baller_app/repositories/repository_provider.dart';

class CourtServices {
  CourtServices({CourtRepository? courtRepository})
      : _courts = courtRepository ?? RepositoryProvider.courts;

  final CourtRepository _courts;

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
  }) {
    return _courts.createCourt(
      name: name,
      latitude: latitude,
      longitude: longitude,
      indoor: indoor,
      hasLights: hasLights,
      hasCourtMarkings: hasCourtMarkings,
      groundType: groundType,
      hoops: hoops,
      address: address,
    );
  }
}
