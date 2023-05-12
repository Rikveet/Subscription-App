import 'package:flutter/material.dart';

class UserList extends DataTableSource {
  final List<Map<String, dynamic>> data;

  UserList({required this.data});

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(data[index]['name'])),
      DataCell(Text(data[index]['email'])),
      DataCell(Row(
        children: (data[index]['permissions'] as List<dynamic>).map((permission) => Text(permission as String)).toList(),
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
