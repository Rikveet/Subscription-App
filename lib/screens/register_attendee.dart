import 'package:flutter/material.dart';
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
  final formKey = GlobalKey<FormState>();

  static const title = Text(
    'Register',
    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50),
  );

  static const gapH = SizedBox(
    // standard gap between rows
    height: 15,
  );

  static ButtonStyle buttonStyle = ButtonStyle(
      // styling for menu buttons
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      ),
      textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18)),
      backgroundColor: MaterialStateProperty.all(Colors.blue),
      fixedSize: MaterialStateProperty.all(const Size(150, 50)));

  // field value controllers to retrive latest value
  TextEditingController firstNameC = TextEditingController();
  TextEditingController lastNameC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController phoneNumberC = TextEditingController();
  TextEditingController cityC = TextEditingController();

  bool fieldsEmpty = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(maxWidth: 400),
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: formKey,
            onChanged: () {
              if (fieldsEmpty) {
                setState(() {
                  // check if all fields are empty
                  fieldsEmpty = firstNameC.text.isEmpty &&
                      lastNameC.text.isEmpty &&
                      emailC.text.isEmpty &&
                      phoneNumberC.text.isEmpty &&
                      cityC.text.isEmpty;
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
                      controller: firstNameC,
                      labelText: 'First Name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required*";
                        }
                        return null;
                      },
                    ),
                    InputField(
                      controller: lastNameC,
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
                    controller: emailC,
                    labelText: 'Email',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Required*";
                      }
                      return null;
                    },
                  ),
                  InputField(
                    controller: phoneNumberC,
                    labelText: 'Phone Number',
                    validator: (value) {
                      return null;
                    },
                  ),
                ]),
                gapH,
                InputField(
                  controller: cityC,
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
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        Map<dynamic, String> payload = {
                          'firstName': firstNameC.text,
                          'lastName': lastNameC.text,
                          'email': emailC.text,
                          'city': cityC.text
                        };
                        if (phoneNumberC.text.isNotEmpty) {
                          payload['phoneNumber'] = phoneNumberC.text;
                        }
                        debugPrint('${payload}');
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
                            formKey.currentState?.reset();
                            setState(() {
                              firstNameC.text = '';
                              lastNameC.text = '';
                              emailC.text = '';
                              phoneNumberC.text = '';
                              cityC.text = '';
                              fieldsEmpty = true;
                            });
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
