import 'dart:convert';
import 'package:http/http.dart' as http;
class GetAddress {
  Future<String?> getAddressFromCoordinates(double lat, double long) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?format=json'
      '&lat=$lat'
      '&lon=$long'
    );
  final response = await http.get(
      url,
      headers: {
        'User-Agent': 'BallerApp/1.0',
      },
    );

    if (response.statusCode != 200) return null;

    final data = json.decode(response.body);
    return data['display_name'];
  }
}

