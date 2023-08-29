import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/models/attendees.dart';
import 'package:radha_swami_management_system/widgets/form/add_attendance.dart';
import 'package:radha_swami_management_system/widgets/form/add_attendee.dart';

class AttendanceList extends DataTableSource {
  final List<dynamic> data; // db data
  final bool isEditable; // is the row editable
  final BuildContext? context; // context used to show a dialog

  AttendanceList({required this.data, required this.context, this.isEditable = false});

  @override
  DataRow? getRow(int index) {
    final rawPhoneNumber = ((data[index]['phoneNumber'] ?? '')).toString();

    final String formattedPhoneNumber = rawPhoneNumber.isNotEmpty && rawPhoneNumber.length == 10
        ? '${rawPhoneNumber.substring(0, 3)}-${rawPhoneNumber.substring(3, 6)}-${rawPhoneNumber.substring(6)}'
        : rawPhoneNumber;

    debugPrint('data[index]: ${data[index].toString()}');

    return DataRow(
        onLongPress: isEditable && context != null
            ? () {
          showDialog(
              builder: (context) {
                final id = data[index]['id'] as int;
                final name = data[index]['name'] as String;
                final email = (data[index]['email'] ?? '') as String;
                final phoneNumber = data[index]['phoneNumber'].toString();
                final city = data[index]['city'];
                return Container();
                //AddAttendanceForm(attendees: attendees, currentAttendees: currentAttendees);
              },
              context: context as BuildContext);
        }
            : null,
        cells: [
          DataCell(Text(data[index]['name'])),
          DataCell((Text(formattedPhoneNumber))),
          DataCell(Text(data[index]['city'])),
          DataCell(Text(data[index]['email'] ?? '')),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
