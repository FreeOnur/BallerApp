import 'package:baller_app/services/load_position.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapSelectionPage extends StatefulWidget {
  const MapSelectionPage({super.key});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  LatLng? selectedPosition;
  final LocationService locationService = LocationService();
  GoogleMapController? mapController;
  Position? userPosition;

  @override
  void initState() {
    super.initState();
    loadPosition();
  }

  Future<void> loadPosition() async {
    userPosition = await locationService.loadPosition();
    setState(() {});
  }

  void _moveCameraToUser() {
    if (mapController != null && userPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            userPosition!.latitude,
            userPosition!.longitude,
          ),
          16,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userPosition == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                userPosition!.latitude,
                userPosition!.longitude,
              ),
              zoom: 16,
            ),
            onMapCreated: (controller) {
              mapController = controller;
              _moveCameraToUser();
            },
            mapType: MapType.normal,
            buildingsEnabled: false,
            tiltGesturesEnabled: false,
            onTap: (position) {
              setState(() {
                selectedPosition = position;
              });
            },
            markers: selectedPosition == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: selectedPosition!,
                    )
                  },
          ),

          if (selectedPosition != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, selectedPosition);
                },
                child: const Text("Diesen Ort verwenden"),
              ),
            ),
        ],
      ),
    );
  }
}
