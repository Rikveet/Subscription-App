import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/models/attendanceRecord.dart';
import 'package:radha_swami_management_system/models/attendees.dart';
import 'package:radha_swami_management_system/models/user.dart';
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

  final String? clientEmail = CLIENT.auth.currentUser?.email;
  bool isClientAdmin = false;
  bool isClientEditor = false;

  List<Map<String, dynamic>> attendees = [];
  List<Map<String, dynamic>> authorizedUsers = [];
  List<Map<String, dynamic>> attendanceRecords = [];

  @override
  void initState() {
    CLIENT.from('authorized_user').stream(primaryKey: ['id']).order('name', ascending: true).listen((List<Map<String, dynamic>> data) {
          // subscribe to the authorized users table
          setState(() {
            authorizedUsers = data;
            final Map<String, dynamic>? userRow = clientEmail != null
                ? authorizedUsers.firstWhere((user) => user['email'] == clientEmail, orElse: () {
                    return {};
                  })
                : null;
            if (userRow != null && userRow.isNotEmpty && authorizedUsers.isNotEmpty) {
              final permissions = (userRow['permissions'] as List<dynamic>).map((e) => e as String);
              isClientAdmin = permissions.contains("ADMIN");
              isClientEditor = permissions.contains("EDITOR");
            }
          });
        });

    CLIENT.from('attendee').stream(primaryKey: ['id']).order('name', ascending: true).listen((List<Map<String, dynamic>> data) {
          // subscribe to the attendee table
          setState(() {
            attendees = data;
          });
        });

    CLIENT.from('attendance').stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      // subscribe to the attendance table
      setState(() {
        attendanceRecords = data;
      });
    });

    setState(() {
      // all table have been subscribed to
      loading = false;
    });

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
                  if (loading) {
                    return Loading(300, 300, 'loading_cloud_data');
                  }
                  switch (dashboardController.selectedIndex) {
                    // case 1:
                    //   return Container(); // Reminders
                    // case 2:
                    //   return Container(); // Settings
                    case 1:
                      return AttendanceTable(isClientEditor: isClientEditor, attendees: attendees);
                    case 2:
                      return AuthorizedUsersTable(isClientAdmin: isClientAdmin, users: authorizedUsers);
                    default: // case 0 and any other case that only uses onTap functionality
                      return AttendeeListTable(isClientEditor: isClientEditor, attendees: attendees);
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
