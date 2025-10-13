import 'package:baller_app/pages/Home/home_page.dart';
import 'package:flutter/material.dart';

class BtmNavigationBar extends StatelessWidget {
  const BtmNavigationBar({
    super.key,
    required this.onTap,
    required this.currentIndex,
  });
  final ValueChanged<int> onTap;
  final int currentIndex;
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color.fromARGB(255, 27, 27, 27),
      unselectedItemColor: const Color.fromARGB(255, 102, 102, 102),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: onTap,
      currentIndex: currentIndex,
      iconSize: 40,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Transform.scale(
            scale: 2.4,
            child: ImageIcon(
              AssetImage('assets/icons/Basketball_Player.png'),
              color: const Color.fromARGB(255, 102, 102, 102),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Transform.scale(
            scale: 1.2,
            child: Icon(
              Icons.location_on_outlined,
              color: const Color.fromARGB(255, 102, 102, 102),
            ),
          ),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Transform.scale(
            scale: 1.2,
            child: Icon(
              Icons.account_circle_outlined,
              color: const Color.fromARGB(255, 102, 102, 102),
            ),
          ),
          label: '',
        ),
      ],
    );
  }
}
