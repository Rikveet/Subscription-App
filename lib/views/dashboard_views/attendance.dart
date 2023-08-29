import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/models/attendanceRecord.dart';
import 'package:radha_swami_management_system/models/attendees.dart';
import 'package:radha_swami_management_system/widgets/attendance_list.dart';
import 'package:radha_swami_management_system/widgets/attendee_list.dart';
import 'package:radha_swami_management_system/widgets/data_table_paginated.dart';
import 'package:radha_swami_management_system/widgets/form/add_attendee.dart';
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
        setState(() {
          attendanceList = (attendees as List<dynamic>).map((attendee) => {
            ...(attendee as Map<String, dynamic>),
            ...(
                widget.attendees.where((_attendee) =>
                _attendee['id'] == attendee['attendee_id']
                ).single
            )
          }).toList();
          debugPrint(attendanceList.toString());
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
                          return Container();
                        },
                      );
                    },
                    child: const Icon(Icons.person_add),
                  ),
                )
              : Container()
        ]),
      ],
    ));
  }
}
