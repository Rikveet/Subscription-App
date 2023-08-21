import 'package:flutter/material.dart';

class DataTablePaginated extends StatelessWidget {
  static const double topViewHeight = 50.0;
  static const double paginateDataTableHeaderRowHeight = 35.0;
  static const double pagerWidgetHeight = 56;
  static const double paginateDataTableRowHeight = kMinInteractiveDimension;

  final Widget header;
  final List<DataColumn> columns;
  final DataTableSource source;

  const DataTablePaginated({super.key, required this.header, required this.columns, required this.source});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height;
    int rowsPerPage = ((maxHeight - topViewHeight - paginateDataTableHeaderRowHeight - pagerWidgetHeight) ~/ paginateDataTableRowHeight).toInt();
    if (rowsPerPage >= 8) {
      rowsPerPage -= 2;
    }
    return PaginatedDataTable(
      showCheckboxColumn: false,
      header: header,
      headingRowHeight: paginateDataTableHeaderRowHeight,
      rowsPerPage: rowsPerPage,
      columns: columns,
      source: source,
    );
  }
}
