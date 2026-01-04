import 'dart:io';

import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final String title;
  final page;
  final double screenHeight;
  final double screenWidth;
  const NavigationButton({
    super.key,
    required this.title,
    required this.page,
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: screenHeight * 0.09,
      width: screenWidth * 0.74,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(231, 85, 39, 100),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Center(
          child: Text(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenHeight * 0.035,
            ),
            title,
          ),
        ),
      ),
    );
  }
}
