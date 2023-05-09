import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class InputField extends StatelessWidget {
  final String labelText;
  final FormFieldValidator<String> validator;
  final bool autoFocus;

  const InputField({super.key, required this.labelText, required this.validator, this.autoFocus = false});

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: labelText,
      validator: validator,
      autofocus: autoFocus,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
          // border styling
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
          errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          fillColor: const Color(0xFFEEEEEE),
          filled: true,
          labelText: labelText),
    );
  }
}
