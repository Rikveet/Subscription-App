import 'dart:io';
import 'package:csv/csv.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:path_provider/path_provider.dart';
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
  String searchFilter = '';
  bool isExportingCsv = false;
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

            final registeredPhoneNumbers = attendeeList.map((e) {
              return (e['phoneNumber'] as int).toString();
            }).toList();

            List<Map<String, dynamic>>? filteredList = attendeeList;

            if (searchFilter.isNotEmpty) {
              // generate filtered list
              filteredList = attendeeList
                  .where((user) => ((user['firstName'] as String).toLowerCase().contains(searchFilter) ||
                      (user['lastName'] as String).toLowerCase().contains(searchFilter) ||
                      (user['email'] ?? '').toLowerCase().contains(searchFilter) ||
                      (user['phoneNumber']).toString().toLowerCase().contains(searchFilter) ||
                      (user['city'] as String).toLowerCase().contains(searchFilter)))
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
                    source: AttendeeList(data: filteredList, registeredEmails: registeredPhoneNumbers, isEditable: widget.isClientEditor, context: context),
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
                      String search = ((fields['Search']?.value ?? '') as String).toLowerCase().replaceAll('-', '');
                      if (search.isNotEmpty) {
                        setState(() {
                          searchFilter = search;
                        });
                      } else {
                        setState(() {
                          searchFilter = '';
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
                              return AddAttendeeForm(registeredPhoneNumbers: registeredPhoneNumbers);
                            },
                          );
                        },
                        child: const Icon(Icons.person_add),
                      ),
                    )
                  : Container(),
              widget.isClientEditor
                  ? Positioned(
                      right: 75,
                      bottom: 10,
                      child: FloatingActionButton(
                        backgroundColor: ACTION_COLOR,
                        onPressed: !isExportingCsv
                            ? () async {
                                setState(() {
                                  isExportingCsv = true;
                                });
                                try {
                                  final rootDirectory = await getApplicationDocumentsDirectory();
                                  // ignore: use_build_context_synchronously
                                  String? directory = await FilesystemPicker.openDialog(
                                    context: context,
                                    rootDirectory: rootDirectory,
                                    fsType: FilesystemType.folder,
                                    rootName: 'Documents',
                                    title: 'Select your save folder',
                                    theme: FilesystemPickerTheme(
                                      topBar: FilesystemPickerTopBarThemeData(
                                          backgroundColor: DASHBOARD_MENU_BACKGROUND_COLOR,
                                          titleTextStyle: const TextStyle(
                                            color: Colors.white,
                                          )),
                                    ),
                                  );

                                  if (directory == null) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('Directory was not selected.'));
                                    setState(() {
                                      isExportingCsv = false;
                                    });
                                    return;
                                  }

                                  String path = '$directory\\Attendee List ${DateTime.now().toString().replaceAll(':', '-').split('.')[0]}.csv';
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Saving attendee list to $path')),
                                  );

                                  List<List<String>> data = [
                                        [
                                          'First Name',
                                          'Last Name',
                                          'Email',
                                          'Phone Number',
                                          'City',
                                        ]
                                      ] +
                                      attendeeList
                                          .map((user) => [
                                                user['firstName'] as String,
                                                user['lastName'] as String,
                                                (user['email'] ?? '') as String,
                                                user['phoneNumber'].toString(),
                                                user['city'] as String,
                                              ])
                                          .toList();
                                  String csvData = const ListToCsvConverter().convert(data);

                                  final File file = await File(path).create(recursive: true);
                                  await file.writeAsString(csvData);

                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Attendee list exported')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('Access denied. Please close the file or select another directory.'));
                                }
                                setState(() {
                                  isExportingCsv = false;
                                });
                              }
                            : null,
                        child: const Icon(Icons.download_rounded),
                      ))
                  : Container(),
            ]);
          },
        )
      ],
    ));
  }
}
