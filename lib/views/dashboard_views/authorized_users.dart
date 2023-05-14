import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/widgets/form/add_user.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';
import 'package:radha_swami_management_system/widgets/user_list.dart';

class AuthorizedUsersTable extends StatefulWidget {
  final AsyncSnapshot<List<Map<String, dynamic>>> snapshot;
  final bool isClientAdmin;

  const AuthorizedUsersTable({super.key, required this.snapshot, this.isClientAdmin = false});

  @override
  AuthorizedUsersTableState createState() {
    return AuthorizedUsersTableState();
  }
}

class AuthorizedUsersTableState extends State<AuthorizedUsersTable> {
  // search
  String? searchFilter;
  GlobalKey<FormBuilderState> formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    if (!widget.snapshot.hasData) {
      return Loading(300, 300, 'loading_cloud_data');
    }
    // get the data from snapshot and remove current user's row
    final String? clientEmail = CLIENT.auth.currentUser?.email;
    final rawUserList = widget.snapshot.data!;
    final userList = rawUserList.where((user) {
      if (clientEmail == null) {
        return true;
      }
      return (user['email'] as String).compareTo(clientEmail) != 0;
    }).toList();

    final registeredEmails = rawUserList.map((user) => user['email'] as String).toList();

    List<Map<String, dynamic>>? filteredList;

    if (searchFilter != null && searchFilter!.isNotEmpty) {
      // generate filtered list
      filteredList = userList
          .where((user) => ((user['name'] as String).toLowerCase().contains(searchFilter as String) ||
              (user['email'] as String).toLowerCase().contains(searchFilter as String) ||
              (user['permissions'] as List<dynamic>).where((permission) => (permission as String).toLowerCase().contains(searchFilter as String)).toList().isNotEmpty))
          .toList();
    }
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            PaginatedDataTable(
              header: const Text('Authorized Users'),
              rowsPerPage: 6,
              checkboxHorizontalMargin: 20,
              horizontalMargin: 60,
              columns: const [DataColumn(label: Text('Name')), DataColumn(label: Text('Email')), DataColumn(label: Text('Permissions'))],
              source: UserList(
                data: filteredList != null && filteredList.isNotEmpty ? filteredList : userList,
                registeredEmails: registeredEmails,
                context: context,
                isEditable: widget.isClientAdmin,
              ),
            ),
          ],
        ),
        Positioned(
          right: 30,
          top: 35,
          child: FormBuilder(
            key: formKey,
            onChanged: () {
              setState(() {
                // check if all fields are empty
                final fields = formKey.currentState?.fields;
                if (fields == null) {
                  return;
                }
                String search = (fields['Search']?.value ?? '') as String;
                if (search.isNotEmpty) {
                  setState(() {
                    searchFilter = search;
                  });
                }
              });
            },
            child: Container(
              constraints: const BoxConstraints(maxWidth: 200),
              child: InputField(
                labelText: 'Search',
                autoFocus: false,
                validator: (value) {
                  if (value != null && value.isNotEmpty && filteredList != null && filteredList.isEmpty) {
                    return 'No search results found!';
                  }
                  return null;
                },
              ),
            ),
          ),
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
