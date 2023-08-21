import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddAttendanceForm extends StatefulWidget {
  final List<Map<String, dynamic>> attendees;
  final List<dynamic> currentAttendees;

  const AddAttendanceForm({super.key, required this.attendees, required this.currentAttendees});

  @override
  AddAttendanceFormState createState() {
    return AddAttendanceFormState();
  }
}

class AddAttendanceFormState extends State<AddAttendanceForm> {
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  List<Map<String, String>> attendees = [];
  List<Map<String, dynamic>> filteredList = [];
  bool isSubmittable = false;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
  }

  void reset() {
    setState(() {
      attendees = [];
    });
  }

  bool isAttending(String id) {
    return widget.currentAttendees.where((attendee) => attendee['attendee_id'] == id).isNotEmpty;
  }

  Future<void> addAttendees() async {
    try {
      await Supabase.instance.client.from('attendance').insert(attendees);
      setState(() {
        attendees = [];
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
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Add attendees'),
        ],
      ),
      content: FormBuilder(
        key: formKey,
        onChanged: () {
          setState(() {
            // check if all fields are empty
            final fields = formKey.currentState?.fields;
            if (fields == null || isFieldEmpty(fields['Search']?.value)) {
              return;
            }
            final searchFilter = fields['Search']!.value;
            filteredList = widget.attendees
                .where((user) => (!isAttending(user['id']) &&
                    ((user['name'] as String).toLowerCase().contains(searchFilter) ||
                        (user['email'] ?? '').toLowerCase().contains(searchFilter) ||
                        (user['phoneNumber']).toString().toLowerCase().contains(searchFilter) ||
                        (user['city'] as String).toLowerCase().contains(searchFilter))))
                .toList();
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
                labelText: 'Search',
                autoFocus: true,
                validator: (value) {
                  return null;
                },
              ),
              FORM_VERTICAL_GAP,
              DropdownButtonFormField(
                menuMaxHeight: 200,
                items: filteredList.map((Map<String, dynamic> attendee) {
                  return DropdownMenuItem(
                      value: '${attendee['id']}',
                      child: Row(
                        children: <Widget>[SizedBox(height: 50, width: 200, child: Text('${attendee['name']} ${attendee['phoneNumber']}'))],
                      ));
                }).toList(),
                onChanged: (attendeeID) {
                  if (attendeeID != null) {
                    setState(() => attendees = [
                          ...attendees,
                          {'date': DateTime.timestamp().toIso8601String().substring(0, 10), 'attendee_id': attendeeID}
                        ]);
                  }
                },
                validator: (value) {
                  return null;
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                  filled: true,
                  fillColor: Colors.grey[200],
                  hintText: 'Select Attendees',
                ),
                dropdownColor: Colors.white,
              ),
              FORM_VERTICAL_GAP,
              ListView(
                children: attendees
                    .map((attendee) => SizedBox(
                          height: 10,
                          child: Text(widget.attendees.firstWhere((selectedAttendees) => selectedAttendees['id'] == attendee['attendee_id'])['name']),
                        ))
                    .toList(),
              ),
              FORM_VERTICAL_GAP,
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                ElevatedButton.icon(
                  onPressed: !isSubmittable || isSubmitting
                      ? null
                      : () async {

                        },
                  style: FORM_BUTTON_STYLE,
                  icon: isSubmitting ? const Icon(Icons.sync) :  const Icon(Icons.person_add),
                  label: isSubmitting ? const Text('Uploading') : const Text('Add Attendees'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
