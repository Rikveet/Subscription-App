import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/views/dashboard_views/attendees.dart';
import 'package:radha_swami_management_system/views/dashboard_views/authorized_users.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/widgets/nav.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() {
    return DashboardState();
  }
}

class DashboardState extends State<Dashboard> {
  final dashboardController = SidebarXController(selectedIndex: 0, extended: true);

  final key = GlobalKey<ScaffoldState>();

  final Stream<List<Map<String, dynamic>>> usersStream = CLIENT.from('authorized_user').stream(primaryKey: ['id']);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final isSmallScreen = MediaQuery.of(context).size.width < 600;
      return Scaffold(
        key: key,
        appBar: isSmallScreen
            ? AppBar(
                backgroundColor: DASHBOARD_MENU_BACKGROUND_COLOR,
                title: Text(getTitleByIndex(dashboardController.selectedIndex)),
                leading: IconButton(
                  onPressed: () {
                    key.currentState?.openDrawer();
                  },
                  icon: const Icon(Icons.menu),
                ),
              )
            : null,
        drawer: Nav(controller: dashboardController),
        body: Row(children: [
          if (!isSmallScreen) Nav(controller: dashboardController),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: dashboardController,
                builder: (context, child) {
                  return StreamBuilder<List<Map<String, dynamic>>>(
                      stream: usersStream,
                      builder: (context, snapshot) {
                        final String? clientEmail = CLIENT.auth.currentUser?.email;
                        bool isClientAdmin = false;
                        bool isClientEditor = false;
                        if (snapshot.hasData) {
                          final rawUserList = snapshot.data!;
                          final Map<String, dynamic>? userRow = clientEmail != null
                              ? rawUserList.firstWhere((user) => user['email'] == clientEmail, orElse: () {
                                  return {};
                                })
                              : null;
                          if (userRow != null && userRow.isNotEmpty && rawUserList.isNotEmpty) {
                            final permissions = (userRow['permissions'] as List<dynamic>).map((e) => e as String);
                            isClientAdmin = permissions.contains("ADMIN");
                            isClientEditor = permissions.contains("EDITOR");
                          }
                        }
                        switch (dashboardController.selectedIndex) {
                          // case 1:
                          //   return Container(); // Reminders
                          // case 2:
                          //   return Container(); // Settings
                          case 1:
                            return AuthorizedUsersTable(isClientAdmin: isClientAdmin, snapshot: snapshot);
                          default: // case 0 and any other case that only uses onTap functionality
                            return AttendeeListTable(isClientEditor: isClientEditor);
                        }
                      });
                },
              ),
            ),
          ),
        ]),
      );
    });
  }

  @override
  void dispose() {
    dashboardController.dispose();
    super.dispose();
  }
}
