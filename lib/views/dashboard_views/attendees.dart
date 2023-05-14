import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/widgets/form/add_attendee.dart';
import 'package:radha_swami_management_system/widgets/attendee_list.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';

class AttendeeListTable extends StatefulWidget {
  final bool isClientEditor; // does the logged in client have editor permission

  const AttendeeListTable({super.key, required this.isClientEditor});

  @override
  AttendeeListTableState createState() {
    return AttendeeListTableState();
  }
}

class AttendeeListTableState extends State<AttendeeListTable> {
  // search
  String? searchFilter;
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  // attendee list db stream
  final Stream<List<Map<String, dynamic>>> attendeeStream = CLIENT.from('attendee').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return (Stack(
      children: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: attendeeStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Loading(300, 300, 'loading_cloud_data');
            }
            final attendeeList = snapshot.data!;
            final registeredEmails = attendeeList.map((e) => e['email'] as String).toList();

            List<Map<String, dynamic>>? filteredList;

            if (searchFilter != null && searchFilter!.isNotEmpty) {
              // generate filtered list
              filteredList = attendeeList
                  .where((user) => ((user['firstName'] as String).toLowerCase().contains(searchFilter as String) ||
                      (user['lastName'] as String).toLowerCase().contains(searchFilter as String) ||
                      (user['email'] as String).toLowerCase().contains(searchFilter as String) ||
                      (user['phoneNumber'] ?? '').toString().toLowerCase().contains(searchFilter as String) ||
                      (user['city'] as String).toLowerCase().contains(searchFilter as String)))
                  .toList();
            }
            return Stack(children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  PaginatedDataTable(
                    header: const Text('Attendee List'),
                    rowsPerPage: 6,
                    columns: const [
                      DataColumn(label: Text('First Name')),
                      DataColumn(label: Text('Last Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Phone Number')),
                      DataColumn(label: Text('City')),
                    ],
                    source: AttendeeList(
                        data: filteredList != null && filteredList.isNotEmpty ? filteredList : attendeeList,
                        registeredEmails: registeredEmails,
                        isEditable: widget.isClientEditor,
                        context: context),
                  ),
                ],
              ),
              Positioned(
                right: 30,
                top: 25,
                child: FormBuilder(
                  key: formKey,
                  onChanged: () {
                    setState(() {
                      // check if all fields are empty
                      final fields = formKey.currentState?.fields;
                      if (fields == null) {
                        return;
                      }
                      String search = (fields['Search']?.value ?? '') as String;
                      if (search.isNotEmpty) {
                        setState(() {
                          searchFilter = search;
                        });
                      } else {
                        setState(() {
                          searchFilter = null;
                        });
                      }
                    });
                  },
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: InputField(
                      labelText: 'Search',
                      autoFocus: false,
                      validator: (value) {
                        if (value != null && value.isNotEmpty && filteredList != null && filteredList.isEmpty) {
                          return 'No search results found!';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              widget.isClientEditor
                  ? Positioned(
                      right: 10,
                      bottom: 10,
                      child: FloatingActionButton(
                        backgroundColor: ACTION_COLOR,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AddAttendeeForm(registeredEmails: registeredEmails);
                            },
                          );
                        },
                        child: const Icon(Icons.person_add),
                      ),
                    )
                  : Container()
            ]);
          },
        )
      ],
    ));
  }
}
