import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/widgets/input_field.dart';
import 'package:radha_swami_management_system/widgets/input_row.dart';

class RegisterAttendeeForm extends StatefulWidget {
  const RegisterAttendeeForm({super.key});

  @override
  RegisterAttendeeFormState createState() {
    return RegisterAttendeeFormState();
  }
}

class RegisterAttendeeFormState extends State<RegisterAttendeeForm> {
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  static const title = Text(
    'Register',
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
  );

  static const gapH = SizedBox(height: 15); // standard gap between rows

  static ButtonStyle buttonStyle = ButtonStyle(
    // styling for menu buttons
    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
    textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18)),
    backgroundColor: MaterialStateProperty.all(Colors.blue),
    fixedSize: MaterialStateProperty.all(const Size(150, 50)),
  );

  bool fieldsEmpty = true;

  void reset() {
    formKey = GlobalKey<FormBuilderState>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(maxWidth: 400),
          height: MediaQuery.of(context).size.height,
          child: FormBuilder(
            key: formKey,
            onChanged: () {
              debugPrint('changed');
              if (fieldsEmpty) {
                setState(() {
                  // check if all fields are empty
                  final fields = formKey.currentState?.fields;
                  if (fields == null) {
                    fieldsEmpty = true;
                  }
                  fieldsEmpty = fields!['First Name']?.value == null &&
                      fields['Last Name']?.value == null &&
                      fields['Email']?.value == null &&
                      fields['Phone Number']?.value == null &&
                      fields['City']?.value == null;
                });
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                title,
                gapH,
                InputRow(
                  children: [
                    InputField(
                      labelText: 'First Name',
                      autoFocus: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required*";
                        }
                        return null;
                      },
                    ),
                    InputField(
                      labelText: 'Last Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required*";
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                gapH,
                InputRow(children: [
                  InputField(
                    labelText: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required*";
                      }
                      return null;
                    },
                  ),
                  InputField(
                    labelText: 'Phone Number',
                    validator: (value) {
                      return null;
                    },
                  ),
                ]),
                gapH,
                InputField(
                  labelText: 'City',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Required*";
                    }
                    return null;
                  },
                ),
                gapH,
                Row(children: [
                  ElevatedButton.icon(
                    onPressed: fieldsEmpty
                        ? null
                        : () {
                            if (formKey.currentState!.validate()) {
                              Map<dynamic, String> payload = {
                                'firstName': formKey.currentState?.fields['First Name']!.value as String,
                                'lastName': formKey.currentState?.fields['Last Name']!.value as String,
                                'email': formKey.currentState?.fields['Email']!.value as String,
                                'city': formKey.currentState?.fields['City']!.value as String
                              };
                              if (formKey.currentState?.fields['Phone Number']!.value != null) {
                                payload['phoneNumber'] = formKey.currentState?.fields['Phone Number']!.value as String;
                              }
                              debugPrint(payload.toString());
                              setState(() {
                                fieldsEmpty = true;
                              });
                              reset();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Processing Data')),
                              );
                            }
                          },
                    style: buttonStyle,
                    icon: const Icon(Icons.person),
                    label: const Text('Register'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: fieldsEmpty
                        ? null
                        : () {
                            setState(() {
                              fieldsEmpty = true;
                            });
                            reset();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cleared')),
                            );
                          },
                    style: buttonStyle,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear All'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
