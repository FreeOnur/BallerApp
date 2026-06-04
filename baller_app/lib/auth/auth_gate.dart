import 'package:baller_app/core/config/app_config.dart';
import 'package:baller_app/pages/AuthenthicationPage/Register/login_page.dart';
import 'package:baller_app/pages/AuthenthicationPage/Register/profile_creation_page.dart';
import 'package:baller_app/pages/Home/main_page.dart';
import 'package:baller_app/repositories/api_auth_repository.dart';
import 'package:baller_app/repositories/repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> _hasProfile({String? userId}) {
    return RepositoryProvider.profiles.hasProfile(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    if (AppConfig.useLegacySupabase) {
      return _LegacyAuthGate(hasProfile: _hasProfile);
    }
    return const _ApiAuthGate();
  }
}

class _LegacyAuthGate extends StatelessWidget {
  const _LegacyAuthGate({required this.hasProfile});

  final Future<bool> Function({String? userId}) hasProfile;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          return FutureBuilder<bool>(
            future: hasProfile(),
            builder: (context, profileSnap) {
              if (!profileSnap.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (profileSnap.data == true) {
                return const MainPage();
              }
              return const ProfileCreationPage();
            },
          );
        }
        return const LoginPage();
      },
    );
  }
}

class _ApiAuthGate extends StatefulWidget {
  const _ApiAuthGate();

  @override
  State<_ApiAuthGate> createState() => _ApiAuthGateState();
}

class _ApiAuthGateState extends State<_ApiAuthGate> {
  late Future<_ApiGateState> _stateFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _stateFuture = _loadState();
    });
  }

  Future<_ApiGateState> _loadState() async {
    final hasSession = await RepositoryProvider.auth.hasSession();
    if (!hasSession) {
      return _ApiGateState.loggedOut;
    }
    final apiAuth = RepositoryProvider.auth as ApiAuthRepository;
    final userId = await apiAuth.getUserIdAsync();
    if (userId == null) {
      return _ApiGateState.loggedOut;
    }
    final hasProfile = await RepositoryProvider.profiles.hasProfile(userId: userId);
    return hasProfile ? _ApiGateState.home : _ApiGateState.needsProfile;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ApiGateState>(
      future: _stateFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        switch (snapshot.data!) {
          case _ApiGateState.loggedOut:
            return LoginPage(onAuthSuccess: _reload);
          case _ApiGateState.needsProfile:
            return ProfileCreationPage(onProfileComplete: _reload);
          case _ApiGateState.home:
            return const MainPage();
        }
      },
    );
  }
}

enum _ApiGateState { loggedOut, needsProfile, home }
