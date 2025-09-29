import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key});

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  File? _imageFile;
  final _formkey = GlobalKey<FormState>();

  // pick image
  Future pickImage() async {
    // picker
    final ImagePicker _picker = ImagePicker();

    //pick from gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    //update image preview
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  // upload
  Future uploadImage() async {
    if (_imageFile == null) return;
    
    //generate unique file path for image
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    //upload to supabase storage to this bucket
    await Supabase.instance.client.storage.from('images').upload(path, _imageFile!).then((value) => ScaffoldMessenger(child: SnackBar(content: Text("Image uploaded successfully!"))));
  }
  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenheight * 0.2),
            GestureDetector(
              onTap: pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: const Color.fromRGBO(231, 85, 39, 100),
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            Form(
              key: _formkey,
              child: Column(
                children: [
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}