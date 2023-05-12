import 'package:flutter/material.dart';

class AttendeeList extends DataTableSource {
  final List<Map<String, dynamic>> data;

  AttendeeList({required this.data});

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(data[index]['firstName'])),
      DataCell(Text(data[index]['lastName'])),
      DataCell(Text(data[index]['email'])),
      DataCell((Text((data[index]['phoneNumber'] ?? '').toString()))),
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
