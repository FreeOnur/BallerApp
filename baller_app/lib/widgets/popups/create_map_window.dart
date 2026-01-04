import 'dart:ffi';
import 'dart:io';

import 'package:baller_app/models/Court.dart';
import 'package:baller_app/pages/Map/map_selection_page.dart';
import 'package:baller_app/services/http/get_address.dart';
import 'package:baller_app/supabase/court_services.dart';
import 'package:baller_app/widgets/buttons/custom_button.dart';
import 'package:baller_app/widgets/text_fields/check_box_custom.dart';
import 'package:baller_app/widgets/text_fields/drop_down_field_custom.dart';
import 'package:baller_app/widgets/text_fields/text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  List<File> imageFileList = [];

  Future<void> submit() async {
    if (selectedPosition == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Standort fehlt')));
      return;
    }

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name fehlt')));
      return;
    }

    try {
      final address = await addressService.getAddressFromCoordinates(
        selectedPosition!.latitude,
        selectedPosition!.longitude,
      );

      final courtId = await courtServices.createCourt(
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

      // ✅ Upload nach Court-Erstellung
      if (imageFileList.isNotEmpty) {
        await uploadImages(courtId);
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Court + Bilder erstellt ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    }
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();

    final List<XFile>? images = await _picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 2000,
      maxHeight: 2000,
    );

    if (images != null) {
      setState(() {
        imageFileList = images.map((image) => File(image.path)).toList();
      });
    }
  }

  Future<void> upload(String path, File file) async {
    await Supabase.instance.client.storage
        .from('court_images')
        .upload(path, file)
        .then((data) => print('Upload successful: $data'));
  }

  Future<void> uploadImages(String courtId) async {
    final supabase = Supabase.instance.client;

    for (final file in imageFileList) {
      final fileExt = file.path.split('.').last;
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${courtId}.$fileExt';
      final storagePath = 'courts/$courtId/$fileName';
      await supabase.storage.from('court_images').upload(storagePath, file);

      final publicUrl = supabase.storage
          .from('court_images')
          .getPublicUrl(storagePath);

      await supabase.from('court_images').insert({
        'court_id': courtId,
        'file_path': publicUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  void createMap() {}
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomButton(
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
              text: "Select Location",
            ),
            CustomTextFormField(
              controller: nameController,
              screenwidth: MediaQuery.of(context).size.width,
              labelTextCustom: "Name",
            ),
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                DropDownFieldCustom(
                  width: MediaQuery.of(context).size.width * 0.3,
                  labelTextCustom: 'Hoops',
                  items: [for (var i = 1; i <= 100; i++) i.toString()],
                  controller: hoopsController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select amount of Hoops';
                    }
                    return null;
                  },
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
            Padding(
              padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.04,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: DropDownFieldCustom(
                  width: MediaQuery.of(context).size.width * 0.5,
                  labelTextCustom: 'Ground Type',
                  items: const [
                    'Hardwood',
                    'PVC/Vinyl',
                    'PU (Polyurethane)',
                    'Rubber Flooring',
                    'Asphalt',
                    'Concrete',
                    'Modular Plastic Tiles (Snap-Together Courts)',
                    'Other',
                  ],
                  controller: groundController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select Ground Type';
                    }
                    return null;
                  },
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            CustomButton(
              onPressed: pickImage,
              text: "Bilder auswählen",
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),

            CustomButton(
              onPressed: () {
                submit();
              },
              text: "Create Court",
            ),
          ],
        ),
      ),
    );
  }
}
