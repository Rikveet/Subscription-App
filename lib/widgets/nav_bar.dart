import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:radha_swami_management_system/constants.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    Key? key,
    required SidebarXController controller,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: _controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Constants.canvasColor,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: Constants.actionColor,
        textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        itemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Constants.canvasColor),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Constants.actionColor.withOpacity(0.37),
          ),
          gradient: const LinearGradient(
            colors: [Constants.accentCanvasColor, Constants.canvasColor],
          ),
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
          color: Constants.canvasColor,
        ),
      ),
      footerDivider: Constants.divider,
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/avatar.png'),
          ),
        );
      },
      items: [
        const SidebarXItem(
          icon: Icons.list,
          label: 'Home',
        ),
        const SidebarXItem(
          icon: Icons.favorite,
          label: 'Reminders',
        ),
        const SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
        ),
        const SidebarXItem(
          icon: Icons.person,
          label: 'Authorize Account',
        ),
        SidebarXItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: () {
              debugPrint('Logout');
            }),
      ],
    );
  }
}
