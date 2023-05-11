import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:lottie/lottie.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/widgets/form/core/input_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> with SingleTickerProviderStateMixin {
  final GlobalKey<FormBuilderState> formStateKey = GlobalKey<FormBuilderState>(); // form state
  late final StreamSubscription<AuthState> authStateSubscription; // auth state
  bool fieldsEmpty = true;
  bool invalidCredentials = false;
  bool verifying = false;
  bool redirecting = false; // to avoid multiple redirects on auth state change

  Future<void> signIn(String email, String password) async {
    setState(() {
      verifying = true;
      invalidCredentials = false;
    });
    try {
      await CLIENT.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (error) {
      setState(() {
        invalidCredentials = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar(error.message));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(ErrorSnackBar('Unexpected error occurred. Please contact the admin.'));
    }

    setState(() {
      verifying = false;
    });
  }

  @override
  void initState() {
    authStateSubscription = CLIENT.auth.onAuthStateChange.listen((data) {
      if (redirecting) return;
      final session = data.session;
      if (session != null) {
        redirecting = true;
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formStateKey,
      onChanged: () {
        setState(() {
          // check if all fields are empty
          final fields = formStateKey.currentState?.fields;
          if (fields == null) {
            fieldsEmpty = true;
            return;
          }
          fieldsEmpty =
              fields['Email']?.value == null || (fields['Email']?.value as String).isEmpty || fields['Password']?.value == null || (fields['Password']?.value as String).isEmpty;
        });
      },
      child: Scaffold(
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: invalidCredentials
                      ? Lottie.asset('assets/animations/invalid_credentials.json')
                      : verifying
                          ? Lottie.asset('assets/animations/auth_loading.json')
                          : Lottie.asset('assets/animations/login.json'),
                ),
                FormTitle('Welcome Back!'),
                FORM_VERTICAL_GAP,
                InputField(
                  labelText: 'Email',
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Required*";
                    }
                    return null;
                  },
                ),
                FORM_VERTICAL_GAP,
                InputField(
                  labelText: 'Password',
                  obscureText: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Required*";
                    }
                    return null;
                  },
                ),
                FORM_VERTICAL_GAP,
                Align(
                  alignment: Alignment.bottomLeft,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text(
                      "Don't have an account?",
                      style: TextStyle(decoration: TextDecoration.underline, color: Colors.black54),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: TextButton(
                    onPressed: () {
                      //Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text(
                      "Forgot your password?",
                      style: TextStyle(decoration: TextDecoration.underline, color: Colors.black54),
                    ),
                  ),
                ),
                FORM_VERTICAL_GAP,
                ElevatedButton.icon(
                  onPressed: fieldsEmpty || verifying
                      ? null
                      : () async {
                          if (formStateKey.currentState!.validate()) {
                            final fields = formStateKey.currentState!.fields;
                            signIn(fields['Email']!.value as String, fields['Password']!.value as String);
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(content: Text('Processing Data')),
                            // );
                          }
                        },
                  icon: verifying ? const Icon(Icons.sync) : const Icon(Icons.person),
                  label: verifying ? const Text('Checking') : const Text('Login'),
                  style: FORM_BUTTON_STYLE,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    authStateSubscription.cancel();
    super.dispose();
  }
}
