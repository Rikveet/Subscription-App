// This class holds constant values for the application
import 'package:country_state_city/utils/city_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final String SUPABASE_URL = dotenv.env['SUPABASE_URL'] as String;
final String SUPABASE_KEY = dotenv.env['SUPABASE_KEY'] as String;
final CLIENT = Supabase.instance.client;
const DASHBOARD_MENU_BACKGROUND_COLOR = Color(0xFF13293D);
const BACKGROUND_COLOR = Color(0xFFDDDBF1);
const ACTIVE_OPTION_COLOR = Color(0xFFD1BEB0);
const ACTION_COLOR = Color(0xFF5F021F);
const WHITE = Colors.white;
final DIVIDER = Divider(color: WHITE.withOpacity(0.3), height: 1);
const FORM_VERTICAL_GAP = SizedBox(height: 15);
final cities = getCountryCities('CA');

ButtonStyle FORM_BUTTON_STYLE = ButtonStyle(
  // styling for menu buttons
  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
  textStyle: MaterialStateProperty.all(const TextStyle(fontSize: 18, color: WHITE)),
  backgroundColor: MaterialStateProperty.all(ACTION_COLOR),
  fixedSize: MaterialStateProperty.all(const Size(150, 50)),
);

Text FormTitle(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 25),
  );
}

bool isFieldEmpty(dynamic field){
  // function to check if a given field in form is empty
  return(field != null && (field as String).isNotEmpty);
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
    // case 1:
    //   return 'Reminders';
    // case 2:
    //   return 'Settings';
    case 1:
      return 'Authorize Account';
    default:
      return 'Home';
  }
}

bool isEmail(String value){
  return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value);
}

bool isText(String value){
  return RegExp(r"^[a-zA-Z ]*$").hasMatch(value);
}

bool isPhoneNumber(String value){
  return RegExp(r"^[0-9]{10}$").hasMatch(value);
}

String generateName(String name){
  return name.trim().split(' ').map((val) => '${val[0].toUpperCase()}${val.substring(1).toLowerCase()}').toList().join(' ');
}