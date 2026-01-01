class Court {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final bool indoor;

  Court({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.indoor,
  });

  factory Court.fromMap(Map<String, dynamic> map) {
    return Court(
      id: map['id'] as String,
      name: map['name'] ?? '',
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      indoor: map['indoor'] ?? false,
    );
  }
}
