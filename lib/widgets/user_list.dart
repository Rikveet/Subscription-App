import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/models/user.dart';
import 'package:radha_swami_management_system/widgets/form/add_user.dart';

class UserList extends DataTableSource {
  final List<Map<String, dynamic>> data; // db data
  final List<String> registeredEmails; // emails that are already registered used for new email validation
  final bool isEditable; // is the row editable
  final BuildContext? context; // context used to show a dialog

  UserList({required this.data, required this.registeredEmails, this.isEditable = false, this.context});

  @override
  DataRow? getRow(int index) {
    return DataRow(
      onLongPress: isEditable && context != null
          ? () {
              showDialog(
                  builder: (context) {
                    final name = data[index]['name'] as String;
                    final email = data[index]['email'] as String;
                    final permissions = (data[index]['permissions'] as List<dynamic>).map((permission) => permission as String).toList();
                    return AddUserForm(user: AuthorizedUser(name: name, email: email, permissions: permissions), registeredEmails: registeredEmails);
                  },
                  context: context as BuildContext);
            }
          : null,
      cells: [
        DataCell(Text(data[index]['name'])),
        DataCell(Text(data[index]['email'])),
        DataCell(Row(
          children: (data[index]['permissions'] as List<dynamic>).map((permission) => Text(permission as String)).toList(),
        ))
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
