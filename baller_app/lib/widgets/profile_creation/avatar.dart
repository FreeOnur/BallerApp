import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.imageUrl, required this.onUpload});

  final String? imageUrl;
  final void Function(String imageUrl) onUpload;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final ImagePicker picker = ImagePicker();
        XFile? image = await picker.pickImage(source: ImageSource.gallery);
        if (image == null) return;
        final imageExtension = image.path.split('.').last.toLowerCase();
        final imageBytes = await image.readAsBytes();
        final userId = Supabase.instance.client.auth.currentUser!.id;
        final imagePath = '/$userId/image';
        await Supabase.instance.client.storage
            .from('images')
            .uploadBinary(imagePath, imageBytes, fileOptions: FileOptions(
              upsert: true,
              contentType: 'image/$imageExtension',
            ));
        String imageUrl = Supabase.instance.client.storage
            .from('images')
            .getPublicUrl(imagePath);
            imageUrl = Uri.parse(imageUrl).replace(queryParameters: {'t': DateTime.now().millisecondsSinceEpoch.toString()}).toString();
        onUpload(imageUrl);
      },
      child: CircleAvatar(
        radius: 60,
        backgroundColor: const Color.fromRGBO(231, 85, 39, 100),
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child: imageUrl == null
            ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
            : null,
      ),
    );
  }
}
