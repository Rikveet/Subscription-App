import 'package:flutter/material.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget{
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: Colors.brown,
          width: 80,
          height: double.maxFinite,
          alignment: Alignment.center,

          child: const Text('RS', style: TextStyle(color: Colors.white, fontSize: 40),),
        )
      ],
    );
  }

  @override
  Size get preferredSize => const Size(
    double.maxFinite,
    80
  );
}