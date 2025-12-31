import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.screenwidth,
    required this.labelTextCustom,
  });
  final TextEditingController controller;
  final double screenwidth;
  final String? labelTextCustom;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: screenwidth * 0.9,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          textInputAction: TextInputAction.next,
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            labelText: labelTextCustom,
            labelStyle: const TextStyle(fontSize: 20),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromRGBO(231, 85, 39, 100),
              ),
            ),
            floatingLabelStyle: const TextStyle(
              color: Color.fromRGBO(231, 85, 39, 100),
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}