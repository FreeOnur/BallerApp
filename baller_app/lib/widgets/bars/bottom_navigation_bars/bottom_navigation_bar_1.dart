import 'package:flutter/material.dart';

class btmNavigationBar extends StatelessWidget {
  const btmNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 27, 27, 27),
      selectedItemColor: const Color.fromRGBO(231, 85, 39, 100),
      unselectedItemColor: const Color.fromARGB(255, 102, 102, 102),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      iconSize: 40,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Transform.scale(
            scale: 2.4,
            child: ImageIcon(AssetImage('assets/icons/Basketball_Player.png')),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Transform.scale(
            scale: 1.2,
            child: Icon(Icons.location_on_outlined),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Transform.scale(
            scale: 1.2,
            child: Icon(Icons.account_circle_outlined),
          ),
          label: '',
        ),
      ],
    );
  }
}
