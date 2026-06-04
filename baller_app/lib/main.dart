import 'package:baller_app/auth/auth_gate.dart';
import 'package:baller_app/core/config/app_config.dart';
import 'package:baller_app/services/badword_filter.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BadwordFilter.loadWords();

  final useLegacy = AppConfig.useLegacySupabase;
  if (useLegacy) {
    if (!AppConfig.hasSupabaseCredentials) {
      throw StateError(
        'USE_LEGACY_SUPABASE=true requires SUPABASE_URL and SUPABASE_ANON_KEY dart-defines.',
      );
    }
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

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
