/*

AUTH GATE - This will continously listen for auth state changes

____________________________________________________________________

unauthenticated -> Login Page
authenticated -> Profile Page

*/

import 'package:baller_app/pages/AuthenthicationPage/Register/profile_creation_page.dart';
import 'package:baller_app/pages/home_page.dart';
import 'package:baller_app/pages/AuthenthicationPage/Register/login_page.dart';
import 'package:baller_app/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  Future<bool> _hasProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response != null;
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
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
            future: _hasProfile(),
            builder: (context, snapshot) {
              if(!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child:CircularProgressIndicator()),
                );
              }
              if(snapshot.data == true) {
                return const MainPage();
              } else {
                return const ProfileCreationPage();
              }
            },            
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
