import 'dart:ffi';

import 'package:baller_app/models/Court.dart';
import 'package:baller_app/pages/Map/map_selection_page.dart';
import 'package:baller_app/services/http/get_address.dart';
import 'package:baller_app/supabase/court_services.dart';
import 'package:baller_app/widgets/text_fields/check_box_custom.dart';
import 'package:baller_app/widgets/text_fields/drop_down_field_custom.dart';
import 'package:baller_app/widgets/text_fields/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateMapWindow extends StatefulWidget {
  const CreateMapWindow({super.key});

  @override
  State<CreateMapWindow> createState() => _CreateMapWindowState();
}

class _CreateMapWindowState extends State<CreateMapWindow> {
  final courtServices = CourtServices();
  LatLng? selectedPosition;
  final nameController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  bool? indoor = false;
  bool? hasLights = false;
  bool? hasCourtMarkings = false;
  final hoopsController = TextEditingController();
  final groundController = TextEditingController();
  final addressService = GetAddress();

  
Future<void> submit() async {
  if (selectedPosition == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bitte Standort auswählen')),
    );
    return;
  }

  if (nameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name fehlt')),
    );
    return;
  }

  final address = await addressService.getAddressFromCoordinates(
    selectedPosition!.latitude,
    selectedPosition!.longitude,
  );

  try {
    await courtServices.createCourt(
      name: nameController.text.trim(),
      latitude: selectedPosition!.latitude,
      longitude: selectedPosition!.longitude,
      indoor: indoor ?? false,
      hasLights: hasLights ?? false,
      hasCourtMarkings: hasCourtMarkings ?? false,
      groundType: groundController.text,
      hoops: int.tryParse(hoopsController.text) ?? 0,
      address: address ?? 'Unknown Address',   
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Court erstellt')),
    );

  } catch (e) {
    if (e.toString().contains('COURT_ALREADY_EXISTS')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Court existiert bereits im Umkreis')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    }
  }
}


  void createMap() {}
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final LatLng? result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapSelectionPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    selectedPosition = result;
                  });
                }
              },
              child: const Text("Select Location"),
            ),
            CustomTextFormField(
              controller: nameController,
              screenwidth: MediaQuery.of(context).size.width,
              labelTextCustom: "Name",
            ),
            Row(
              children: [
                CustomTextFormField(
                  controller: hoopsController,
                  screenwidth: MediaQuery.of(context).size.width * 0.3,
                  labelTextCustom: "Hoops",
                ),
                CheckBoxCustom(
                  text: "Indoor",
                  value: indoor!,
                  onChanged: (value) {
                    setState(() {
                      indoor = value;
                    });
                  },
                ),
              ],
            ),
            CheckBoxCustom(
              text: "Has Lights",
              value: hasLights!,
              onChanged: (value) {
                setState(() {
                  hasLights = value;
                });
              },
            ),
            CheckBoxCustom(
              text: "Has Court Markings",
              value: hasCourtMarkings!,
              onChanged: (value) {
                setState(() {
                  hasCourtMarkings = value;
                });
              },
            ),
            DropDownFieldCustom(
              width: MediaQuery.of(context).size.width * 0.5,
              labelTextCustom: 'Ground Type',
              items: const ['Hardwood', 'PVC/Vinyl', 'PU (Polyurethane)', 'Rubber Flooring', 'Asphalt', 'Concrete', 'Modular Plastic Tiles (Snap-Together Courts)', 'Other'],
              controller: groundController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select Ground Type';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: submit,
              child: const Text('Create Court'),
            ),
          ],
        ),
      ),
    );
  }
}