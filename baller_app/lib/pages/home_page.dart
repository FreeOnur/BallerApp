import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(15, 15, 15, 100),
        foregroundColor: Color.fromRGBO(231, 85, 39, 100),
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(231, 85, 39, 100),
          ),
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
          },
          child: const Text("Sign Out"),
        ),
      ),
      
    );
  }
}