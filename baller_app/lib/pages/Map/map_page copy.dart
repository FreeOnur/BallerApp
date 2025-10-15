import 'package:baller_app/classes/Court.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  List<Court> courts = [];
  List<Court> filteredCourts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCourts();
  }

  Future<void> fetchCourts() async {
    final res = await Supabase.instance.client.from('courts').select();
    final data = res as List;
    final list = data.map((e) => Court.fromMap(e)).toList();

    setState(() {
      courts = list;
      filteredCourts = list;
    });
  }

  void _searchCourts(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredCourts = courts
          .where((court) => court.name.toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// 🔍 Suchfeld oben
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                onChanged: _searchCourts,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.7),
                  hintText: 'Search courts...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            /// 🗺️ Map in der Mitte als Kasten
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: GoogleMap(
                    onMapCreated: (controller) => mapController = controller,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(47.0, 8.0),
                      zoom: 12,
                    ),
                    markers: filteredCourts
                        .map(
                          (court) => Marker(
                            markerId: MarkerId(court.id.toString()),
                            position: LatLng(court.lat, court.lng),
                            infoWindow: InfoWindow(title: court.name),
                          ),
                        )
                        .toSet(),
                  ),
                ),
              ),
            ),

            /// 📋 Liste unten
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: filteredCourts.isEmpty
                    ? const Center(
                        child: Text(
                          'Keine Courts gefunden',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredCourts.length,
                        itemBuilder: (context, index) {
                          final court = filteredCourts[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.sports_basketball,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        court.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4)                                      
                                    ],
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),

      /// ➕ Add Button schwebend mittig unten
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () {
          // neue Seite öffnen etc.
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
