import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/constants.dart';

import 'package:radha_swami_management_system/screens/register_attendee.dart';
import 'package:radha_swami_management_system/widgets/attendee_list_display.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> attendeeStream = Supabase.instance.client.from('attendee').stream(primaryKey: ['id']);

  Home({super.key});

  @override
  Widget build(BuildContext context) {
    return (Stack(
      children: [
        StreamBuilder<List<Map<String, dynamic>>>(
            stream: attendeeStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final attendeeList = snapshot.data!;
              return ListView(
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
                    source: AttendeeListDisplay(data: attendeeList),
                  ),
                ],
              );
            }),
        Positioned(
          right: 10,
          bottom: 10,
          child: FloatingActionButton(
            backgroundColor: Constants.primaryColor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const RegisterAttendeeForm();
                },
              );
            },
            child: const Icon(Icons.person_add),
          ),
        )
      ],
    ));
  }
}
