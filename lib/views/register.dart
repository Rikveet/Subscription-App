import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:lottie/lottie.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterState createState() {
    return RegisterState();
  }
}

class RegisterState extends State<Register> with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> formStateKey = GlobalKey<FormBuilderState>();
  late AnimationController controller;
  bool fieldsEmpty = true;
  bool registering = false;

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formStateKey,
      onChanged: () {
        setState(() {
          // check if all fields are empty
          final fields = formStateKey.currentState?.fields;
          if (fields == null) {
            fieldsEmpty = true;
            return;
          }
          fieldsEmpty = fields['Email']?.value == null ||
              (fields['Email']?.value as String).isEmpty ||
              fields['Password']?.value == null ||
              (fields['Password']?.value as String).isEmpty ||
              fields['Confirm Password']?.value == null ||
              (fields['Confirm Password']?.value as String).isEmpty;
        });
      },
      child: Scaffold(
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: registering ? Lottie.asset('assets/animations/auth_loading.json') : Lottie.asset('assets/animations/register.json'),
                ),
                FormTitle('Join Us!'),
                FORM_VERTICAL_GAP,
                InputField(
                  labelText: 'Email',
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Required*";
                    }
                    return null;
                  },
                ),
                FORM_VERTICAL_GAP,
                InputField(
                  labelText: 'Password',
                  obscureText: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Required*";
                    }
                    return null;
                  },
                ),
                FORM_VERTICAL_GAP,
                InputField(
                  labelText: 'Confirm Password',
                  obscureText: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Required*";
                    }
                    return null;
                  },
                ),
                FORM_VERTICAL_GAP,
                Align(
                  alignment: Alignment.bottomLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      "Already Registered?",
                      style: TextStyle(decoration: TextDecoration.underline, color: Colors.black54),
                    ),
                  ),
                ),
                FORM_VERTICAL_GAP,
                ElevatedButton.icon(
                  onPressed: fieldsEmpty || registering
                      ? null
                      : () async {
                          if (formStateKey.currentState!.validate()) {
                            final fields = formStateKey.currentState!.fields;
                            setState(() {
                              registering = true;
                            });
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(content: Text('Processing Data')),
                            // );
                          }
                        },
                  icon: registering ? Loading(20, 20, 'loading_plane') : const Icon(Icons.person_add),
                  label: registering ? const Text('Registering') : const Text('Register'),
                  style: FORM_BUTTON_STYLE,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
