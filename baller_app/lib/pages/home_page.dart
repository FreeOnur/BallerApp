import 'package:flutter/material.dart';

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
      body: Center(child: Text("Jo pisser")),
    );
  }
}