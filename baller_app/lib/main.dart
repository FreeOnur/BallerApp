import 'package:baller_app/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vsqdqyvjykmbkxbiwwvm.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZzcWRxeXZqeWttYmt4Yml3d3ZtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5Mjc0MzEsImV4cCI6MjA3MjUwMzQzMX0.TJpO32G-9jILRyx3kL-dH19WvwrPll7yBqOGvM7wtKc',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}
