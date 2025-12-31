import 'package:flutter/material.dart';

class CheckBoxCustom extends StatelessWidget {
  const CheckBoxCustom({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v!),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: MediaQuery.of(context).size.height * 0.03,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
