import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';

class InputField extends StatefulWidget {
  final String labelText;
  final FormFieldValidator<String> validator;
  final bool autoFocus;
  final bool obscureText;

  const InputField({super.key, required this.labelText, required this.validator, this.autoFocus = false, this.obscureText = false});

  @override
  InputFieldState createState() {
    return InputFieldState();
  }
}

class InputFieldState extends State<InputField> {
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    return FormBuilderTextField(
      name: widget.labelText,
      validator: widget.validator,
      autofocus: widget.autoFocus,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: widget.obscureText && isObscured,
      decoration: InputDecoration(
          suffixIcon: widget.obscureText
              ? IconButton(
                  alignment: Alignment.centerRight,
                  onPressed: () => {
                        setState(() {
                          isObscured = !isObscured;
                        })
                      },
                  icon: Icon(isObscured ? Icons.remove_red_eye : Icons.remove_red_eye_outlined))
              : null,
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey)),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: PRIMARY_COLOR)),
          errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          fillColor: WHITE,
          filled: true,
          labelText: widget.labelText,
          labelStyle: const TextStyle(color: PRIMARY_COLOR)),
    );
  }
}
