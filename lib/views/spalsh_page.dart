import 'dart:async';

import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  SplashPageState createState() {
    return SplashPageState();
  }
}

class SplashPageState extends State<SplashPage> {
  bool redirectCalled = false;
  late final StreamSubscription<AuthState> authStateSubscription; // auth state

  Future<void> _redirect(Session? session) async {
    if (redirectCalled || !mounted) {
      return;
    }
    setState(() {
      redirectCalled = true;
    });
    await Future.delayed(Duration.zero).whenComplete(() {
      if (session != null) {
        Navigator.of(context).pushNamed('/home');
      } else {
        Navigator.of(context).pushNamed('/login');
      }
    });
    setState(() {
      redirectCalled = false;
    });
  }

  @override
  void initState() {
    authStateSubscription = CLIENT.auth.onAuthStateChange.listen((data) {
      _redirect(data.session);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect(CLIENT.auth.currentSession);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Loading(200, 200, 'loading_circular'));
  }

  @override
  void dispose() {
    authStateSubscription.cancel();
    super.dispose();
  }
}
