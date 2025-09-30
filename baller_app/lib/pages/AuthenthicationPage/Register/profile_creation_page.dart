import 'dart:io';

import 'package:baller_app/widgets/profile_creation/avatar.dart';
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
  String? _imageUrl;
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
    Supabase.instance.client.from('profiles').select('avatar_url').eq('id', userId).single().then((data) {
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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: screenheight * 0.2),
            // Avatar widget soll hier kommen
            Avatar(imageUrl: _imageUrl, onUpload: (imageUrl) async{
              setState(() {
                _imageUrl = imageUrl;
              });
              final userId = Supabase.instance.client.auth.currentUser!.id;
              await Supabase.instance.client.from('profiles').update({
                'avatar_url': imageUrl,
              }).eq('id', userId);
            }),
            Form(
              key: _formkey,
              child: Column(children: [
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
