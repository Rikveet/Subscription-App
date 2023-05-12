import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/widgets/form/add_attendee.dart';
import 'package:radha_swami_management_system/widgets/attendee_list.dart';

class AttendeeListTable extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> attendeeStream = CLIENT.from('attendee').stream(primaryKey: ['id']);

  AttendeeListTable({super.key});

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
                    source: AttendeeList(data: attendeeList),
                  ),
                ],
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: FloatingActionButton(
                  backgroundColor: ACTION_COLOR,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AddAttendeeForm();
                      },
                    );
                  },
                  child: const Icon(Icons.person_add),
                ),
              )
            ]);
          },
        )
      ],
    ));
  }
}
