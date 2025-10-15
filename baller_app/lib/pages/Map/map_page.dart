import 'package:flutter/material.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 15, 100),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: Color.fromRGBO(231, 85, 39, 100),
              size: screenHeight * 0.09,
            ),
            // Search Bar
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.05),
              child: Center(
                child: Container(
                  width: screenWidth * 0.7,
                  height: screenHeight * 0.06,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(156, 26, 24, 24),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color.fromARGB(255, 49, 49, 49),
                      width: 2,
                    ),
                  ),
                  child: TextField(
                    style: TextStyle(color: Colors.white, fontSize: screenHeight*0.025),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenHeight * 0.01,
                      ),
                      prefixIcon: Icon(Icons.search, size: screenHeight*0.05),
                      suffixIcon: Icon(Icons.filter_alt_rounded, size: screenHeight*0.05),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
