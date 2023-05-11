// This class holds constant values for the application
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final String SUPABASE_URL = dotenv.env['SUPABASE_URL'] as String;
final String SUPABASE_KEY = dotenv.env['SUPABASE_KEY'] as String;
final CLIENT = Supabase.instance.client;
const PRIMARY_COLOR = Color(0xFF2A0C4E);
const CANVAS_COLOR = Color(0xFF2A0C4E);
const SCAFFOLD_BACKGROUND_COLOR = Color(0xFFFFF8F0);
const ACCENT_CANVAS_COLOR = Color(0xFF9E2B25);
const WHITE = Colors.white;
final ACTION_COLOR = const Color(0xFF9E2B25).withOpacity(0.6);
const BUTTON_COLOR = Color(0xFF5135B4);
final DIVIDER = Divider(color: WHITE.withOpacity(0.3), height: 1);
const FORM_VERTICAL_GAP = SizedBox(height: 15);
ButtonStyle FORM_BUTTON_STYLE = ButtonStyle(
  // styling for menu buttons
  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
  textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, color: WHITE)),
  backgroundColor: MaterialStateProperty.all(BUTTON_COLOR),
  fixedSize: MaterialStateProperty.all(const Size(150, 50)),
);

Text FormTitle(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 25),
  );
}

Widget Loading(double width, double height, String type) => Center(child: SizedBox(width: width, height: height, child: Lottie.asset('assets/animations/$type.json')));

SnackBar SuccessSnackBar(String content) {
  return SnackBar(
    content: Text(
      content,
      style: const TextStyle(color: WHITE),
    ),
    backgroundColor: const Color(0xf0115d28),
  );
}


SnackBar ErrorSnackBar(String content) {
  return SnackBar(
    content: Text(
      content,
      style: const TextStyle(color: WHITE),
    ),
    backgroundColor: const Color(0xF09e2b25),
  );
}

String getTitleByIndex(int index) {
  switch (index) {
    case 0:
      return 'Home';
    case 1:
      return 'Reminders';
    case 2:
      return 'Settings';
    case 3:
      return 'Authorize Account';
    case 4:
      return 'Settings';
    default:
      return 'Not found page';
  }
}
