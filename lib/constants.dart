// This class holds constant values for the application
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Constants {

  static final String supabaseUrl = dotenv.env['SUPABASE_URL'] as String;
  static final String supabaseKey = dotenv.env['SUPABASE_KEY'] as String;
  static const primaryColor = Color(0xFF2A0C4E);
  static const canvasColor = Color(0xFF2A0C4E);
  static const scaffoldBackgroundColor = Color(0xFFFFF8F0);
  static const accentCanvasColor = Color(0xFF9E2B25);
  static const white = Colors.white;
  static final actionColor = const Color(0xFF9E2B25).withOpacity(0.6);
  static final divider = Divider(color: white.withOpacity(0.3), height: 1);

  static String getTitleByIndex(int index) {
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
}
