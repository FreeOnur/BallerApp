import 'package:flutter/material.dart';

class btmNavigationBar extends StatelessWidget {
  const btmNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 27, 27, 27),
        selectedItemColor: const Color.fromRGBO(231, 85, 39, 100),
        unselectedItemColor: const Color.fromARGB(255, 102, 102, 102),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('Basketball_Player.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      );
  }
}