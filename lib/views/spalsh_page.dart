import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() {
    return SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> {
  bool redirectCalled = false;

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 2000));

    if (redirectCalled || !mounted) {
      return;
    }

    redirectCalled = true;
    final session = CLIENT.auth.currentUser;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Loading(200, 200, 'loading_circular'));
  }
}
