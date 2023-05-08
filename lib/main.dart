import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/screens/register_attendee.dart';
// import 'package:radha_swami_management_system/constants.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // await Supabase.initialize( // initialize supabase
  //   url: Constants.SUPABASE_URL,
  //   anonKey: Constants.SUPABASE_KEY,
  // );

  runApp(const MyApp()); // launch app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Text'),
        ),
        body: const RegisterAttendeeForm(),
      ),
    );
  }
}
