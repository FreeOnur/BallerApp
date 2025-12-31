import 'package:baller_app/models/Court.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CourtDetailsPage extends StatelessWidget {
  const CourtDetailsPage({super.key, required Court court});
  Future<void> openInGoogleMaps(LatLng position) async {
  final Uri googleMapsUri = Uri.parse(
    "https://www.google.com/maps/dir/?api=1"
    "&destination=${position.latitude},${position.longitude}"
    "&travelmode=driving",
  );

  if (await canLaunchUrl(googleMapsUri)) {
    await launchUrl(
      googleMapsUri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not open Google Maps';
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            AppBar(
              title: Center(child: Text('Court Details')),
            ),
          ],
        ),
      ),
    );
  }
}