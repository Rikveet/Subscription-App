import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/widgets/data_table_paginated.dart';
import 'package:radha_swami_management_system/widgets/form/add_user.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';
import 'package:radha_swami_management_system/widgets/user_list.dart';

class AuthorizedUsersTable extends StatefulWidget {
  final List<Map<String, dynamic>> users;
  final bool isClientAdmin;

  const AuthorizedUsersTable({super.key, required this.users, this.isClientAdmin = false});

  @override
  AuthorizedUsersTableState createState() {
    return AuthorizedUsersTableState();
  }
}

class AuthorizedUsersTableState extends State<AuthorizedUsersTable> {
  // search
  String searchFilter = '';
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final registeredEmails = widget.users.map((user) => user['email'] as String).toList();
    List<Map<String, dynamic>> filteredList = widget.users;

    if (searchFilter.isNotEmpty) {
      // generate filtered list
      filteredList = widget.users
          .where((user) => ((user['name'] as String).toLowerCase().contains(searchFilter) ||
              (user['email'] as String).toLowerCase().contains(searchFilter) ||
              (user['permissions'] as List<dynamic>).where((permission) => (permission as String).toLowerCase().contains(searchFilter)).toList().isNotEmpty))
          .toList();
    }

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DataTablePaginated(
              header: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Authorized Users'),
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
                        )),
                  ),
                ],
              ),
              columns: const [
                DataColumn(
                  label: Text('Name'),
                ),
                DataColumn(
                  label: Text('Email'),
                ),
                DataColumn(
                  label: Text('Permissions'),
                )
              ],
              source: UserList(
                data: filteredList,
                registeredEmails: registeredEmails,
                context: context,
                isEditable: widget.isClientAdmin,
              ),
            ),
          ],
        ),
        widget.isClientAdmin
            ? Positioned(
                right: 10,
                bottom: 10,
                child: FloatingActionButton(
                  backgroundColor: ACTION_COLOR,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddUserForm(registeredEmails: registeredEmails);
                      },
                    );
                  },
                  child: const Icon(Icons.person_add),
                ),
              )
            : Container()
      ],
    );
  }
}
