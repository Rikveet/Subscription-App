import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;

  const InputField(
      {super.key,
      required this.labelText,
      required this.validator,
      required this.controller});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: validator,
      decoration: InputDecoration(
          // border styling
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red)),
          fillColor: const Color(0xFFEEEEEE),
          filled: true,
          labelText: labelText),
    );
  }
}
