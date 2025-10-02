import 'dart:io';

import 'package:baller_app/services/badword_filter.dart';
import 'package:baller_app/widgets/profile_creation/avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _imageUrl;

  final usernameController = TextEditingController();
  int? selectedAge;
  final locationController = TextEditingController();
  final levelController = TextEditingController();
  final genderController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    final userId = Supabase.instance.client.auth.currentUser!.id;
    Supabase.instance.client
        .from('profiles')
        .select('avatar_url')
        .eq('id', userId)
        .single()
        .then((data) {
          setState(() {
            _imageUrl = data['avatar_url'] as String?;
          });
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // upload
  Future uploadImage() async {
    if (_imageFile == null) return;

    //generate unique file path for image
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final path = 'uploads/$fileName';

    //upload to supabase storage to this bucket
    await Supabase.instance.client.storage
        .from('images')
        .upload(path, _imageFile!)
        .then(
          (data) => ScaffoldMessenger(
            child: SnackBar(content: Text("Image uploaded successfully!")),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    final fieldSize = screenwidth * 0.9;
    final dropDownSize = fieldSize * 0.3;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenheight * 0.2),
            // Avatar widget soll hier kommen
            Avatar(
              imageUrl: _imageUrl,
              onUpload: (imageUrl) async {
                setState(() {
                  _imageUrl = imageUrl;
                });
                final userId = Supabase.instance.client.auth.currentUser!.id;
                await Supabase.instance.client
                    .from('profiles')
                    .update({'avatar_url': imageUrl})
                    .eq('id', userId);
              },
            ),
            Form(
              key: _formkey,
              child: Column(
                children: [
                  SizedBox(
                    width: screenwidth * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(),
                          labelText: 'Username',
                          labelStyle: const TextStyle(fontSize: 20),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromRGBO(231, 85, 39, 100),
                            ),
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: Color.fromRGBO(231, 85, 39, 100),
                            fontSize: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          if (BadwordFilter.containsBadWord(value)) {
                            return 'Username contains inappropriate language';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: dropDownSize,
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Age',
                            labelStyle: const TextStyle(fontSize: 20),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(231, 85, 39, 100),
                              ),
                            ),
                          ),
                          initialValue: selectedAge,
                          items: [
                            for (int age = 0; age <= 100; age++)
                              DropdownMenuItem<int>(
                                value: age,
                                child: Text(
                                  age.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                          onChanged: (value) => setState(() {
                            selectedAge = value;
                          }),
                          validator: (value) =>
                              value == null ? 'Please select your age' : null,
                        ),
                      ),
                      SizedBox(width: screenwidth * 0.15),
                      SizedBox(
                        width: screenwidth * 0.4,
                        child: TextFormField(
                          textInputAction: TextInputAction.next,
                          style: const TextStyle(color: Colors.white),
                          controller: locationController,
                          decoration: InputDecoration(
                            border: const UnderlineInputBorder(),
                            labelText: 'Location',
                            labelStyle: const TextStyle(fontSize: 20),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(231, 85, 39, 100),
                              ),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Color.fromRGBO(231, 85, 39, 100),
                              fontSize: 20,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your location';
                            }
                            return null;
                          },
                        ),
                      )

                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
