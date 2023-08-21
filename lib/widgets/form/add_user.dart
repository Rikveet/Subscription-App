import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/models/user.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_checkbox.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddUserForm extends StatefulWidget {
  // update mode info
  final AuthorizedUser? user;
  final List<String> registeredEmails;

  const AddUserForm({super.key, required this.registeredEmails, this.user});

  @override
  AddUserFormState createState() {
    return AddUserFormState();
  }
}

class AddUserFormState extends State<AddUserForm> {
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  bool isSubmittable = false;
  bool isResettable = false;
  bool isSubmitting = false;

  // checkbox values for user permissions
  bool isAdmin = false;
  bool isEditor = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      final permissions = widget.user?.permissions;
      if (permissions == null) {
        return;
      }
      isAdmin = permissions.contains('ADMIN');
      isEditor = permissions.contains('EDITOR');
    });
  }

  void reset() {
    setState(() {
      formKey = GlobalKey<FormBuilderState>();
      isSubmittable = false;
      isResettable = false;
      isSubmitting = false;
      final permissions = widget.user?.permissions;
      if (permissions == null) {
        return;
      }
      isAdmin = permissions.contains('ADMIN');
      isEditor = permissions.contains('EDITOR');
    });
  }

  Future<void> submit(AuthorizedUser user) async {
    try {
      await Supabase.instance.client.from('authorized_user').insert({'name': generateName(user.name), 'email': user.email.trim().toLowerCase(), 'permissions': user.permissions});
      reset();
    } on PostgrestException catch (error) {
      if (error.details == 'Forbidden') {
        ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('You are not allowed to make this change'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error.message));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('Unexpected error occurred. Please contact the admin.'));
    }
  }

  Future<void> update(AuthorizedUser user) async {
    try {
      await Supabase.instance.client
          .from('authorized_user')
          .update({'name': user.name, 'email': user.email, 'permissions': user.permissions}).match({'email': widget.user!.email}).whenComplete(() {
        reset();
        Navigator.of(context).pop();
      });
    } on PostgrestException catch (error) {
      if (error.details == 'Forbidden') {
        ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('You are not allowed to make this change'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error.message));
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('Unexpected error occurred. Please contact the admin.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.user != null ? 'Update' : 'Authorize'),
          widget.user != null
              ? IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return (AlertDialog(
                            title: const Text('Are you sure?'),
                            content: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('You are about to delete:'),
                                FORM_VERTICAL_GAP,
                                Text('Name: ${widget.user?.name ?? "Not found"}'),
                                FORM_VERTICAL_GAP,
                                Text('Email: ${widget.user?.email ?? "Not found"}'),
                                FORM_VERTICAL_GAP,
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                        icon: const Icon(Icons.delete_forever),
                                        label: const Text("Delete"),
                                        style: FORM_BUTTON_STYLE,
                                        onPressed: widget.user?.email != null && widget.user!.email.isNotEmpty
                                            ? () async {
                                                try {
                                                  await CLIENT.from('authorized_user').delete().match({'email': widget.user?.email}).whenComplete(() {
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  });
                                                } on PostgrestException {
                                                  ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('You are not allowed to make this change.'));
                                                } catch (error) {
                                                  ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('Unexpected error occurred. Please contact the admin.'));
                                                }
                                              }
                                            : null),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton.icon(
                                        icon: const Icon(Icons.cancel),
                                        style: FORM_BUTTON_STYLE,
                                        label: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        })
                                  ],
                                )
                              ],
                            ),
                          ));
                        });
                  },
                  icon: const Icon(Icons.delete),
                  color: ACTION_COLOR,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              : Container(),
        ],
      ),
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
            bool name = isFieldEmpty(fields['Name']?.value);
            bool email = isFieldEmpty(fields['Email']?.value);
            // resettable if any of the fields are filled
            isResettable = name || email;
            // all required fields are filled
            isSubmittable = name && email;
          });
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
          width: 350,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InputField(
                labelText: 'Name',
                initialValue: widget.user?.name,
                autoFocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required*";
                  }
                  if (value.length < 3) {
                    return 'Too short, must be more than 3 letters';
                  }
                  if (!isText(value)) {
                    return 'Only alphabets are allowed';
                  }
                  return null;
                },
              ),
              FORM_VERTICAL_GAP,
              InputField(
                labelText: 'Email',
                initialValue: widget.user?.email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Required*";
                  }
                  if (!isEmail(value)) {
                    return "Not a valid email";
                  }
                  if (widget.registeredEmails.contains(value) && value.compareTo(widget.user?.email ?? '') != 0) {
                    // User entered an email that is already registered and not their email.
                    return "Email is already registered";
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
                          isSubmittable = true;
                          isResettable = true;
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
                          isSubmittable = true;
                          isResettable = true;
                        });
                      },
                    ),
                    label: 'Editor'),
              ]),
              FORM_VERTICAL_GAP,
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                ElevatedButton.icon(
                  onPressed: !isSubmittable || isSubmitting
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
                            final name = fields['Name']!.value as String;
                            final email = fields['Email']!.value as String;

                            final user = AuthorizedUser(name: name, email: email, permissions: permissions);
                            if (widget.user != null) {
                              update(user);
                            } else {
                              submit(user);
                            }
                            setState(() {
                              isSubmitting = true;
                            });
                          }
                        },
                  style: FORM_BUTTON_STYLE,
                  icon: isSubmitting ? const Icon(Icons.sync) : Icon(widget.user != null ? Icons.cloud_upload : Icons.person_add),
                  label: isSubmitting ? const Text('Uploading') : Text(widget.user != null ? 'Edit' : 'Register'),
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
                  icon: Icon(widget.user != null ? Icons.refresh : Icons.clear),
                  label: Text(widget.user != null ? 'Reset' : 'Clear All'),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
