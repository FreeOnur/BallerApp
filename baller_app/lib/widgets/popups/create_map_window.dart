import 'dart:ffi';

import 'package:baller_app/pages/Map/map_selection_page.dart';
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
  LatLng? selectedPosition;
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  final indoor_outdoorController = TextEditingController();
  bool? indoor = false;
  final hasLightsController = TextEditingController();
  bool? hasLights = false;
  final hasCourtMarkingsController = TextEditingController();
  bool? hasCourtMarkings = false;
  final hoopsController = TextEditingController();
  final groundController = TextEditingController();
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
                    latController.text = selectedPosition!.latitude.toString();
                    lngController.text = selectedPosition!.longitude.toString();
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
                  controller: addressController,
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
              labelTextCustom: 'Level',
              items: const ['Hardwood', 'PVC/Vinyl', 'PU (Polyurethane)', 'Rubber Flooring', 'Asphalt', 'Concrete', 'Modular Plastic Tiles (Snap-Together Courts)', 'Other'],
              controller: groundController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select Ground Type';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
