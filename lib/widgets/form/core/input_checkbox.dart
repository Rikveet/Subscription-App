import 'package:flutter/material.dart';

class CheckboxInput extends StatelessWidget {
  final Checkbox checkbox;
  final String label;
  final double gapSize;

  const CheckboxInput({super.key, required this.checkbox, required this.label, this.gapSize = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        SizedBox(width: gapSize),
        checkbox
      ],
    );
  }
}
