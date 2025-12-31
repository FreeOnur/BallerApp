import 'package:baller_app/models/Court.dart';
import 'package:baller_app/pages/Map/court_details_page.dart';
import 'package:baller_app/services/load_position.dart';
import 'package:baller_app/widgets/popups/create_map_window.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? userPosition;
  GoogleMapController? mapController;
  Court? selectedCourt;
  List<Court> courts = [];
  List<Court> filteredCourts = [];
  List<Court> sortedCourts = [];
  int visibleCourtsCount = 10;
  String searchQuery = '';
  final LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();
    loadPosition();
    fetchCourts();
  }

  Future<void> loadPosition() async {
    userPosition = await LocationService().loadPosition();

    updateSortedCourts();

    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            userPosition!.latitude,
            userPosition!.longitude,
          ),
          13,
        ),
      );
    }

    setState(() {});
  }

  Future<void> fetchCourts() async {
    final res = await Supabase.instance.client.from('courts').select();
    final data = res as List;

    courts = data.map((e) => Court.fromMap(e)).toList();
    filteredCourts = courts;

    updateSortedCourts();

    setState(() {});
  }

  void updateSortedCourts() {
    if (userPosition == null) {
      sortedCourts = List.from(filteredCourts);
      return;
    }

    sortedCourts = List<Court>.from(filteredCourts)
      ..sort(
        (a, b) => distanceToCourt(a).compareTo(distanceToCourt(b)),
      );
  }

  void searchCourts(String query) {
    searchQuery = query.toLowerCase();

    filteredCourts = courts
        .where((court) =>
            court.name.toLowerCase().contains(searchQuery))
        .toList();

    updateSortedCourts();
    setState(() {});
  }

  double distanceToCourt(Court court) {
    if (userPosition == null) return double.infinity;

    return Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      court.lat,
      court.lng,
    );
  }
  List<Court> get visibleCourts {
    if (sortedCourts.length <= visibleCourtsCount) {
      return sortedCourts;
    }
    return sortedCourts.take(visibleCourtsCount).toList();
  }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 1),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.05),

          Icon(
            Icons.location_on,
            color: const Color.fromRGBO(231, 85, 39, 1),
            size: screenHeight * 0.09,
          ),

          Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.03),
            child: Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.06,
              decoration: BoxDecoration(
                color: const Color.fromARGB(156, 26, 24, 24),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color.fromARGB(255, 49, 49, 49),
                  width: 2,
                ),
              ),
              child: TextField(
                onChanged: searchCourts,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenHeight * 0.022,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: screenHeight * 0.4,
                width: double.infinity,
                child: GoogleMap(
                  onMapCreated: (controller) {
                    mapController = controller;
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(47.0, 8.0),
                    zoom: 12,
                  ),
                  mapType: MapType.satellite,
                  myLocationEnabled: true,
                  markers: sortedCourts.map(
                    (court) => Marker(
                      markerId: MarkerId(court.id.toString()),
                      position: LatLng(court.lat, court.lng),
                      infoWindow: InfoWindow(title: court.name),
                    ),
                  ).toSet(),
                ),
              ),
            ),
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: sortedCourts.isEmpty
                  ? const Center(
                      child: Text(
                        'Keine Courts gefunden',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: visibleCourts.length + 1,
                      itemBuilder: (context, index) {

                        if (index == visibleCourts.length) {
                          if (visibleCourts.length == sortedCourts.length) {
                            return const SizedBox.shrink();
                          }
                          return TextButton(
                            onPressed: () {
                              setState(() {
                                visibleCourtsCount += 10;
                              });
                            },
                            child: const Text(
                              'Mehr laden',
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }
                        final court = sortedCourts[index];

                        return InkWell(
                          onTap: () {
                            selectedCourt = court;
                            mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(
                                LatLng(court.lat, court.lng),
                                15,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  // decoration: BoxDecoration(
                                  //   color: Colors.orange,
                                  //   borderRadius: BorderRadius.circular(8),
                                  // ),
                                  // child: const Icon(
                                  //   Icons.sports_basketball,
                                  //   color: Colors.white,
                                  // ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        court.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (userPosition != null)
                                        Text(
                                          "${(distanceToCourt(court) / 1000).toStringAsFixed(1)} km entfernt",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      GestureDetector(
                                        onTap: () => {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => CourtDetailsPage(court: court),
                                            ),
                                          )
                                        },
                                        child: Text(
                                          'See More',
                                          style: TextStyle(
                                            color: Colors.blue[300],
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          SizedBox(
            height: 80,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(left: 10),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border(
                      top: BorderSide(color: Colors.white, width: 2),
                      bottom: BorderSide(color: Colors.white, width: 2),
                      left: BorderSide(color: Colors.white, width: 2),
                      right: BorderSide(color: Colors.white, width: 2),
                    )
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.black87,
                          title: const Text('Create Map', style: TextStyle(color: Colors.white),),
                          content: CreateMapWindow(),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK', style: TextStyle(color: Colors.orange),),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )
              ],
            )
          ),
        ],
      ),
    );
  }
}
