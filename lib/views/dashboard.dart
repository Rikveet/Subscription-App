import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/views/dashboard_views/attendance.dart';
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

  bool loading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // dispatch actions to listen to the supabase changes to the attendee and authorized user tables

    setState(() {
      // all table have been subscribed to
      loading = false;
    });

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
                  if (loading) {
                    return Loading(300, 300, 'loading_cloud_data');
                  }
                  switch (dashboardController.selectedIndex) {
                    // case 1:
                    //   return Container(); // Reminders
                    // case 2:
                    //   return Container(); // Settings
                    case 1:
                      return AttendanceTable();
                    case 2:
                      return AuthorizedUsersTable();
                    default: // case 0 and any other case that only uses onTap functionality
                      return const AttendeeListTable();
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
