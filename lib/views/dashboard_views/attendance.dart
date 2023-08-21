import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/models/attendanceRecord.dart';
import 'package:radha_swami_management_system/models/attendees.dart';
import 'package:radha_swami_management_system/widgets/attendance_list.dart';
import 'package:radha_swami_management_system/widgets/attendee_list.dart';
import 'package:radha_swami_management_system/widgets/data_table_paginated.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';

class AttendanceTable extends StatefulWidget {
  final bool isClientEditor; // does the logged in client have editor permission
  final List<Map<String, dynamic>> attendees;

  const AttendanceTable({super.key, required this.isClientEditor, required this.attendees});

  @override
  AttendanceTableState createState() {
    return AttendanceTableState();
  }
}

class AttendanceTableState extends State<AttendanceTable> {
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();
  List<dynamic> attendanceList = [];
  String date = DateTime.timestamp().toIso8601String().substring(0, 10);
  String searchFilter = '';

  @override
  void initState() {
    super.initState();
    try {
      readAttendees();
    } catch (_) {}
  }

  Future<void> readAttendees() async {
    try {
      CLIENT.from('attendance').select('*').eq('date', date).then((attendees) {
        debugPrint(attendees.toString());
        setState(() {
          attendanceList = attendees;
        });
      });
    } catch (_) {}
  }

  Future<void> addAttendee(AttendanceRecord record) async {
    try {
      await CLIENT.from('attendance').insert({'date': date, 'attendee_id': record.id});
    } catch (_) {}
  }

  Future<void> removeAttendee(AttendanceRecord record) async {
    try {
      await CLIENT.from('attendance').delete();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
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
                    const Text('Attendance'),
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
                source: AttendanceList(data: attendanceList, isEditable: widget.isClientEditor, context: context),
              ),
            ],
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
                                      'Name',
                                      'Email',
                                      'Phone Number',
                                      'City',
                                    ]
                                  ] +
                                  widget.attendees
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
        ]),
      ],
    ));
  }
}
