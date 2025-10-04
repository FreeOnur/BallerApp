import 'package:flutter/material.dart';

class DropDownFieldCustom extends StatelessWidget {
  final List<String> items;
  final String? labelTextCustom;
  final double width;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  const DropDownFieldCustom({
    super.key,
    required this.items,
    required this.labelTextCustom,
    required this.width,
    required this.controller,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: labelTextCustom,
          labelStyle: const TextStyle(fontSize: 20),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromRGBO(231, 85, 39, 100)),
          ),
          floatingLabelStyle: const TextStyle(
            color: Color.fromRGBO(231, 85, 39, 100),
            fontSize: 20,
          ),
        ),
        dropdownColor: const Color.fromARGB(255, 39, 39, 39),
        initialValue: controller.text.isNotEmpty ? controller.text : null,
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(color: Colors.white)),
              ),
            )
            .toList(),
        onChanged: (value) {
          controller.text = value ?? '';
        },
        validator:
            validator ??
            (value) => value == null ? 'Please select your age' : null,
      ),
    );
  }
}
