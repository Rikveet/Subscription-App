import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/models/attendees.dart';
import 'package:radha_swami_management_system/widgets/form/add_attendee.dart';

class AttendeeList extends DataTableSource {
  final List<Map<String, dynamic>> data; // db data
  final List<String> registeredEmails; // emails that are already registered used for new email validation
  final bool isEditable; // is the row editable
  final BuildContext? context; // context used to show a dialog

  AttendeeList({required this.data, required this.registeredEmails, required this.context, this.isEditable = false});

  @override
  DataRow? getRow(int index) {
    final rawPhoneNumber = ((data[index]['phoneNumber'] ?? '')).toString();

    final String formattedPhoneNumber = rawPhoneNumber.isNotEmpty && rawPhoneNumber.length == 10
        ? '${rawPhoneNumber.substring(0, 3)}-${rawPhoneNumber.substring(3, 6)}-${rawPhoneNumber.substring(6)}'
        : rawPhoneNumber;

    return DataRow(
        onLongPress: isEditable && context != null
            ? () {
                showDialog(
                    builder: (context) {
                      final firstName = data[index]['firstName'] as String;
                      final lastName = data[index]['lastName'] as String;
                      final email = data[index]['email'] as String;
                      final phoneNumber = (data[index]['phoneNumber'] ?? '').toString();
                      final city = data[index]['city'];
                      return AddAttendeeForm(
                        registeredEmails: registeredEmails,
                        attendee: Attendee(firstName: firstName, lastName: lastName, email: email, phoneNumber: phoneNumber, city: city),
                      );
                    },
                    context: context as BuildContext);
              }
            : null,
        cells: [
          DataCell(Text(data[index]['firstName'])),
          DataCell(Text(data[index]['lastName'])),
          DataCell(Text(data[index]['email'])),
          DataCell((Text(formattedPhoneNumber))),
          DataCell(Text(data[index]['city'])),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
