import 'package:baller_app/pages/AuthenthicationPage/Register/login_page.dart';
import 'package:baller_app/pages/Map/map_page.dart';
import 'package:baller_app/widgets/bars/bottom_navigation_bars/bottom_navigation_bar_1.dart';
import 'package:baller_app/widgets/buttons/navigation_button.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<String> getUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();

      // 'data' ist hier ein Map<String, dynamic>
      return data['username'] as String;
    } catch (e) {
      throw Exception('Error fetching username: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FutureBuilder(
              future: getUserName(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  return Text(
                    'Hi, ${snapshot.data}!',
                    style: TextStyle(
                      color: Color.fromRGBO(231, 85, 39, 100),
                      fontSize: 24 * screenHeight / 400,
                    ),
                  );
                } else {
                  return Text('No username found');
                }
              },
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/homepage_box_image_1.png',
                    fit: BoxFit.contain,
                  ),
                  Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Color.fromRGBO(231, 85, 39, 100),
                        size: 40 * screenHeight / 400,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      NavigationButton(
                        title: 'Find a Court',
                        page: MapPage(),
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/homepage_box_image_2.png',
                    fit: BoxFit.contain,
                  ),
                  Column(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.74,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.sports_basketball_rounded,
                              color: Color.fromRGBO(231, 85, 39, 100),
                              size: 40 * screenHeight / 500,
                            ),
                            Spacer(),
                            Text(
                              'Find a Match',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18 * screenHeight / 490,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      NavigationButton(
                        title: 'Find a Match',
                        page: LoginPage(),
                        screenHeight: screenHeight,
                        screenWidth: screenWidth,
                      ),
                      SizedBox(height: screenHeight * 0.02),
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
