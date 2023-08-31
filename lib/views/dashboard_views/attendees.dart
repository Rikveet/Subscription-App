import 'dart:io';
import 'package:csv/csv.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:path_provider/path_provider.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/redux/app_state.dart';
import 'package:radha_swami_management_system/widgets/data_table_paginated.dart';
import 'package:radha_swami_management_system/widgets/form/add_attendee.dart';
import 'package:radha_swami_management_system/widgets/attendee_list.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';

class AttendeeListTable extends StatefulWidget {
  const AttendeeListTable({super.key});

  @override
  AttendeeListTableState createState() {
    return AttendeeListTableState();
  }
}

class Store {
  // combine stores into one model user for store connector
  final List<Map<String, dynamic>> attendees;
  final bool isClientEditor;

  Store({required this.attendees, required this.isClientEditor});
}

class AttendeeListTableState extends State<AttendeeListTable> {
  // search
  String searchFilter = '';
  bool isExportingCsv = false;
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, Store>(
        converter: (store) => Store(attendees: store.state.attendeeStore.list, isClientEditor: store.state.userStore.isEditor),
        builder: (context, store) {
          final registeredPhoneNumbers = store.attendees.map((e) {
            return (e['phoneNumber'] as int).toString();
          }).toList();

          List<Map<String, dynamic>>? filteredList = store.attendees;

          if (searchFilter.isNotEmpty) {
            // generate filtered list
            filteredList = store.attendees
                .where((user) => ((user['name'] as String).toLowerCase().contains(searchFilter) ||
                    (user['email'] ?? '').toLowerCase().contains(searchFilter) ||
                    (user['phoneNumber']).toString().toLowerCase().contains(searchFilter) ||
                    (user['city'] as String).toLowerCase().contains(searchFilter)))
                .toList();
          }
          return (Stack(
            children: [
              Stack(children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    DataTablePaginated(
                      header: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Attendee List'),
                          FormBuilder(
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
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 9, 0, 0),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: InputField(
                                  labelText: 'Search',
                                  autoFocus: false,
                                  validator: (value) {
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Phone Number')),
                        DataColumn(label: Text('City')),
                        DataColumn(label: Text('Email')),
                      ],
                      source: AttendeeList(
                          data: filteredList, registeredEmails: registeredPhoneNumbers, isEditable: store.isClientEditor, context: context),
                    ),
                  ],
                ),
                store.isClientEditor
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
                store.isClientEditor
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
                                            'Name',
                                            'Email',
                                            'Phone Number',
                                            'City',
                                          ]
                                        ] +
                                        store.attendees
                                            .map((user) => [
                                                  user['name'] as String,
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
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(ErrorSnackBar('Access denied. Please close the file or select another directory.'));
                                  }
                                  setState(() {
                                    isExportingCsv = false;
                                  });
                                }
                              : null,
                          child: const Icon(Icons.download_rounded),
                        ))
                    : Container(),
              ]),
            ],
          ));
        });
  }
}
