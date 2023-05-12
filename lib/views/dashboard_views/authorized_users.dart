import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/widgets/form/add_user.dart';
import 'package:radha_swami_management_system/widgets/user_list.dart';

class AuthorizedUsersTable extends StatelessWidget {
  final Stream<List<Map<String, dynamic>>> usersStream = CLIENT.from('authorized_user').stream(primaryKey: ['id']);

  AuthorizedUsersTable({super.key});

  @override
  Widget build(BuildContext context) {
    return ((Stack(
      children: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: usersStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Loading(300, 300, 'loading_cloud_data');
            }
            final userList = snapshot.data!;
            bool isUserAdmin =
                ((userList.firstWhere((value) => value['email'] == CLIENT.auth.currentUser?.email)['permissions']) as List<dynamic>).map((e) => e as String).contains("ADMIN");
            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PaginatedDataTable(
                      header: const Text('Authorized Users'),
                      rowsPerPage: 6,
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('Permissions')),
                      ],
                      source: UserList(data: userList),
                    ),
                  ],
                ),
                isUserAdmin
                    ? Positioned(
                        right: 10,
                        bottom: 10,
                        child: FloatingActionButton(
                          backgroundColor: ACTION_COLOR,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const AddUserForm();
                              },
                            );
                          },
                          child: const Icon(Icons.person_add),
                        ),
                      )
                    : Container()
              ],
            );
          },
        ),
      ],
    )));
  }
}
