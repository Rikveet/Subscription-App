import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:radha_swami_management_system/constants.dart';

class Nav extends StatelessWidget {
  final SidebarXController controller;

  const Nav({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DASHBOARD_MENU_BACKGROUND_COLOR,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: ACTION_COLOR,
        hoverTextStyle: const TextStyle(color: Colors.white),
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DASHBOARD_MENU_BACKGROUND_COLOR),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ACTIVE_OPTION_COLOR.withOpacity(0.4),
          ),
          color: ACTION_COLOR,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.7),
          size: 20,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: DASHBOARD_MENU_BACKGROUND_COLOR,
        ),
      ),
      footerDivider: DIVIDER,
      headerBuilder: (context, extended) {
        return SizedBox(
          width: 200,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/avatar.png'),
          ),
        );
      },
      items: [
        const SidebarXItem(
          icon: Icons.list,
          label: 'Attendees',
        ),
        const SidebarXItem(
          icon: Icons.calendar_month,
          label: 'Attendance',
        ),
        // const SidebarXItem(
        //   icon: Icons.settings,
        //   label: 'Settings',
        // ),
        const SidebarXItem(
          icon: Icons.person,
          label: 'Editors',
        ),
        SidebarXItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () async {
              await CLIENT.auth.signOut().onError((error, stackTrace) {
                ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('Unexpected error occurred. Please contact the admin.'));
              }).whenComplete(() {
                ScaffoldMessenger.of(context).showSnackBar(SuccessSnackBar('Logged out. See you soon!'));
                //Navigator.of(context).pushReplacementNamed('/login');
              });
            }),
      ],
    );
  }
}
