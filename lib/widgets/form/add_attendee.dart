import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/models/attendees.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAttendeeForm extends StatefulWidget {
  const AddAttendeeForm({super.key});

  @override
  AddAttendeeFormState createState() {
    return AddAttendeeFormState();
  }
}

class AddAttendeeFormState extends State<AddAttendeeForm> {
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  bool fieldsEmpty = true;
  bool submitting = false;

  void reset() {
    formKey = GlobalKey<FormBuilderState>();
    setState(() {
      fieldsEmpty = true;
      submitting = false;
    });
  }

  Future<void> submit(Attendee attendee) async {
    await Supabase.instance.client.from('attendee').insert({
      'firstName': attendee.firstName,
      'lastName': attendee.lastName,
      'email': attendee.email,
      //'phoneNumber': 1234, //attendee.phoneNumber ?? ''
      'city': attendee.city
    });
    reset();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Register'),
      content: FormBuilder(
        key: formKey,
        onChanged: () {
          if (fieldsEmpty) {
            setState(() {
              // check if all fields are empty
              final fields = formKey.currentState?.fields;
              if (fields == null) {
                fieldsEmpty = true;
                return;
              }
              fieldsEmpty = fields['First Name']?.value == null &&
                  fields['Last Name']?.value == null &&
                  fields['Email']?.value == null &&
                  fields['Phone Number']?.value == null &&
                  fields['City']?.value == null;
            });
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
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
            FORM_VERTICAL_GAP,
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
            FORM_VERTICAL_GAP,
            InputField(
              labelText: 'City',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Required*";
                }
                return null;
              },
            ),
            FORM_VERTICAL_GAP,
            Row(children: [
              ElevatedButton.icon(
                onPressed: fieldsEmpty || submitting
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          final fields = formKey.currentState!.fields;
                          submit(
                            Attendee(
                                firstName: fields['First Name']!.value as String,
                                lastName: fields['Last Name']!.value as String,
                                email: fields['Email']!.value as String,
                                phoneNumber: (fields['Phone Number']!.value ?? '') as String,
                                city: fields['City']!.value as String),
                          );
                          setState(() {
                            submitting = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Processing Data')),
                          );
                        }
                      },
                style: FORM_BUTTON_STYLE,
                icon: submitting ? const Icon(Icons.sync) : const Icon(Icons.person),
                label: submitting ? const Text('Uploading') : const Text('Register'),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton.icon(
                onPressed: fieldsEmpty
                    ? null
                    : () {
                        reset();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cleared')),
                        );
                      },
                style: FORM_BUTTON_STYLE,
                icon: const Icon(Icons.clear),
                label: const Text('Clear All'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
