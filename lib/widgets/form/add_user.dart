import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/models/user.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_checkbox.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddUserForm extends StatefulWidget {
  const AddUserForm({super.key});

  @override
  AddUserFormState createState() {
    return AddUserFormState();
  }
}

class AddUserFormState extends State<AddUserForm> {
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  bool isSubmittable = false;
  bool isResettable = false;
  bool submitting = false;

  // checkbox values
  bool isAdmin = false;
  bool isEditor = false;

  void reset() {
    setState(() {
      formKey = GlobalKey<FormBuilderState>();
      isSubmittable = false;
      isResettable = false;
      submitting = false;
    });
  }

  Future<void> submit(AuthorizedUser user) async {
    try {
      await Supabase.instance.client.from('authorized_user').insert({'name': user.name, 'email': user.email, 'permissions': user.permissions});
    } on PostgrestException catch (error) {
      debugPrint('${error.toString()}');
      if(error.details == 'Forbidden'){
        ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('You are not allowed to make this change'));
      }else{
        ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error.message));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('Unexpected error occurred. Please contact the admin.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Register'),
      content: FormBuilder(
        key: formKey,
        onChanged: () {
          setState(() {
            // check if all fields are empty
            final fields = formKey.currentState?.fields;
            if (fields == null) {
              isSubmittable = false;
              isResettable = false;
              return;
            }
            bool name = (fields['Name']?.value != null && (fields['Name']?.value as String).isNotEmpty);
            bool email = (fields['Email']?.value != null && (fields['Email']?.value as String).isNotEmpty);
            // resettable if any of the fields are filled
            isResettable = name || email;
            // all required fields are filled
            isSubmittable = name && email;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            InputField(
              labelText: 'Name',
              autoFocus: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Required*";
                }
                return null;
              },
            ),
            FORM_VERTICAL_GAP,
            InputField(
              labelText: 'Email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Required*";
                }
                return null;
              },
            ),
            FORM_VERTICAL_GAP,
            InputRow(children: [
              CheckboxInput(
                  checkbox: Checkbox(
                    value: isAdmin,
                    onChanged: (value) {
                      setState(() {
                        isAdmin = value ?? false;
                      });
                    },
                  ),
                  label: 'Admin'),
              CheckboxInput(
                  checkbox: Checkbox(
                    value: isEditor,
                    onChanged: (value) {
                      setState(() {
                        isEditor = value ?? false;
                      });
                    },
                  ),
                  label: 'Editor'),
            ]),
            FORM_VERTICAL_GAP,
            Row(children: [
              ElevatedButton.icon(
                onPressed: !isSubmittable || submitting
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          final fields = formKey.currentState!.fields;
                          List<String> permissions = [];
                          if (isAdmin) {
                            permissions.add('ADMIN');
                          }
                          if (isEditor) {
                            permissions.add('EDITOR');
                          }
                          submit(AuthorizedUser(
                            name: fields['Name']!.value as String,
                            email: fields['Email']!.value as String,
                            permissions: permissions,
                          ));
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
                onPressed: !isResettable
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
