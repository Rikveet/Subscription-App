import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/views/dashboard_views/attendee_list_table.dart';
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

  late final Stream<List<Map<String, dynamic>>>? usersStream;

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
                  switch (dashboardController.selectedIndex) {
                    case 1:
                      return Container(); // Reminders
                    case 2:
                      return Container(); // Settings
                    case 3:
                      return AuthorizedUsersTable(); // Authorize Accounts
                    default: // case 0 and any other case that only uses onTap functionality
                      return AttendeeListTable();
                  }
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
