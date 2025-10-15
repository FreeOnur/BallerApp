import 'package:baller_app/pages/Map/map_page.dart';
import 'package:baller_app/widgets/bars/bottom_navigation_bars/bottom_navigation_bar_1.dart';
import 'package:flutter/material.dart';
import 'package:baller_app/pages/Home/home_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [HomePage(), MapPage(), HomePage()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BtmNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
