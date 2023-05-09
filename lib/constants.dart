// This class holds constant values for the application
import 'package:flutter/material.dart';

abstract class Constants {
  // Loading supabase credentials from environment
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseKey = String.fromEnvironment('SUPABASE_KEY');
  static const primaryColor = Color(0xFF685BFF);
  static const canvasColor = Color(0xFF2E2E48);
  static const scaffoldBackgroundColor = Color(0xFF464667);
  static const accentCanvasColor = Color(0xFF3E3E61);
  static const white = Colors.white;
  static final actionColor = const Color(0xFF5F5FA7).withOpacity(0.6);
  static final divider = Divider(color: white.withOpacity(0.3), height: 1);

  static String getTitleByIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Search';
      case 2:
        return 'Register';
      case 3:
        return 'Reminders';
      case 4:
        return 'Settings';
      case 5:
        return 'Authorize Account';
      case 6:
        return 'Settings';
      default:
        return 'Not found page';
    }
  }
}
