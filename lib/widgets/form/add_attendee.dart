import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/models/attendees.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_row.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAttendeeForm extends StatefulWidget {
  final Attendee? attendee;
  final List<String> registeredPhoneNumbers;

  const AddAttendeeForm({super.key, required this.registeredPhoneNumbers, this.attendee});

  @override
  AddAttendeeFormState createState() {
    return AddAttendeeFormState();
  }
}

class AddAttendeeFormState extends State<AddAttendeeForm> {
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  bool isSubmittable = false;
  bool isResettable = false;
  bool isSubmitting = false;
  String city = 'Brampton';
  List<String> states = <String>[];

  @override
  void initState() {
    super.initState();
    loadCities();
    setState(() {
      if (widget.attendee != null && widget.attendee?.city != null && widget.attendee!.city.isNotEmpty) {
        city = widget.attendee!.city;
      }
    });
  }

  Future<void> loadCities() async {
    final stateList = await cities;
    setState(() {
      states = stateList.where((e) => e.name.isNotEmpty).map((e) => e.name).toList();
    });
  }

  void reset() {
    setState(() {
      formKey = GlobalKey<FormBuilderState>();
      isSubmittable = false;
      isResettable = false;
    });
  }

  bool fieldsNotUpdated() {
    final fields = formKey.currentState!.fields;
    return fields['First Name']?.value == widget.attendee?.firstName &&
        fields['Last Name']?.value == widget.attendee?.lastName &&
        fields['Email']?.value == widget.attendee?.email &&
        fields['Phone Number']?.value == widget.attendee?.phoneNumber &&
        city == widget.attendee?.city;
  }

  Map<String, dynamic> getUploadableAttendee(Attendee attendee) {
    final Map<String, dynamic> attendeeInfo = {'firstName': attendee.firstName, 'lastName': attendee.lastName, 'email': attendee.email, 'city': attendee.city};
    if (attendee.phoneNumber.isNotEmpty) {
      attendeeInfo['phoneNumber'] = int.parse(attendee.phoneNumber);
    }
    return attendeeInfo;
  }

  Future<void> submit(Attendee attendee) async {
    try {
      await Supabase.instance.client.from('attendee').insert(getUploadableAttendee(attendee)).whenComplete(() {
        reset();
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
    setState(() {
      isSubmitting = false;
    });
  }

  Future<void> update(Attendee attendee) async {
    try {
      await Supabase.instance.client.from('attendee').update(getUploadableAttendee(attendee)).match({'phoneNumber': widget.attendee!.phoneNumber}).whenComplete(() {
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
    setState(() {
      isSubmitting = false;
    });
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
            if (fields == null || (widget.attendee != null && fieldsNotUpdated())) {
              isSubmittable = false;
              isResettable = false;
              return;
            }
            bool firstName = isFieldEmpty(fields['First Name']?.value);
            bool lastName = isFieldEmpty(fields['Last Name']?.value);
            bool email = isFieldEmpty(fields['Email']?.value);
            bool phoneNumber = isFieldEmpty(fields['Phone Number']?.value);
            bool _city = isFieldEmpty(city);
            // resettable if any of the fields are filled
            isResettable = firstName || lastName || email || phoneNumber || _city;
            // all required fields are filled
            isSubmittable = firstName && lastName && phoneNumber && _city;
          });
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InputRow(
                children: [
                  InputField(
                    labelText: 'First Name',
                    autoFocus: true,
                    initialValue: widget.attendee?.firstName,
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
                  InputField(
                    labelText: 'Last Name',
                    initialValue: widget.attendee?.lastName,
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
                ],
              ),
              FORM_VERTICAL_GAP,
              InputRow(children: [
                InputField(
                  labelText: 'Email',
                  initialValue: widget.attendee?.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    if (!isEmail(value)) {
                      return "Not a valid email";
                    }
                    return null;
                  },
                ),
                InputField(
                  labelText: 'Phone Number',
                  initialValue: widget.attendee?.phoneNumber,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Required*";
                    }
                    if (!isPhoneNumber(value)) {
                      return "Not a phone number";
                    }
                    if (widget.registeredPhoneNumbers.contains(value) && value.compareTo(widget.attendee?.phoneNumber ?? '') != 0) {
                      // User entered an email that is already registered and not their email.
                      return "Phone number is already registered";
                    }
                    return null;
                  },
                ),
              ]),
              FORM_VERTICAL_GAP,
              DropdownButtonFormField(
                menuMaxHeight: 200,
                items: states.map((String city) {
                  return DropdownMenuItem(
                      value: city,
                      child: Row(
                        children: <Widget>[Text(city)],
                      ));
                }).toList(),
                onChanged: (_city) {
                  if (_city != null) {
                    setState(() => city = _city);
                  }
                  if (widget.attendee?.city != _city) {
                    setState(() {
                      isSubmittable = true;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required*';
                  }
                  return null;
                },
                value: city,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'City',
                  // errorText: errorSnapshot.data == 0 ? Localization.of(context).categoryEmpty : null
                ),
                dropdownColor: Colors.white,
              ),
              FORM_VERTICAL_GAP,
              Row(children: [
                ElevatedButton.icon(
                  onPressed: !isSubmittable || isSubmitting
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            final fields = formKey.currentState!.fields;
                            final attendee = Attendee(
                                firstName: fields['First Name']!.value as String,
                                lastName: fields['Last Name']!.value as String,
                                email: (fields['Email']!.value ?? '') as String,
                                phoneNumber: fields['Phone Number']!.value as String,
                                city: city);
                            if (widget.attendee != null) {
                              update(attendee);
                            } else {
                              submit(attendee);
                            }
                            setState(() {
                              isSubmitting = true;
                            });
                          }
                        },
                  style: FORM_BUTTON_STYLE,
                  icon: isSubmitting ? const Icon(Icons.sync) : Icon(widget.attendee != null ? Icons.cloud_upload : Icons.person_add),
                  label: isSubmitting ? const Text('Uploading') : Text(widget.attendee != null ? 'Edit' : 'Register'),
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
                  icon: Icon(widget.attendee != null ? Icons.refresh : Icons.clear),
                  label: Text(widget.attendee != null ? 'Reset' : 'Clear All'),
                ),
                widget.attendee != null
                    ? IconButton(
                        color: ACTION_COLOR,
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
                                      Text('First Name: ${widget.attendee?.firstName ?? "Not found"}'),
                                      FORM_VERTICAL_GAP,
                                      Text('Last Name: ${widget.attendee?.firstName ?? "Not found"}'),
                                      FORM_VERTICAL_GAP,
                                      Text('Email: ${widget.attendee?.email ?? "Not found"}'),
                                      FORM_VERTICAL_GAP,
                                      Text('Phone Number: ${widget.attendee?.phoneNumber ?? "Not found"}'),
                                      FORM_VERTICAL_GAP,
                                      Text('City: ${widget.attendee?.city ?? "Not found"}'),
                                      FORM_VERTICAL_GAP,
                                      Row(
                                        children: [
                                          ElevatedButton.icon(
                                              icon: const Icon(Icons.delete),
                                              label: const Text("Delete"),
                                              style: FORM_BUTTON_STYLE,
                                              onPressed: widget.attendee?.phoneNumber != null && widget.attendee!.phoneNumber.isNotEmpty
                                                  ? () async {
                                                      try {
                                                        await CLIENT.from('attendee').delete().match({'phoneNumber': widget.attendee!.phoneNumber}).whenComplete(() {
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
                        icon: const Icon(Icons.delete_forever),
                      )
                    : Container(),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
