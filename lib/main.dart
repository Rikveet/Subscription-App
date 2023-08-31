import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:radha_swami_management_system/redux/app_state.dart';
import 'package:radha_swami_management_system/redux/models.dart';
import 'package:radha_swami_management_system/redux/reducers.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/views/login.dart';
import 'package:radha_swami_management_system/views/register.dart';
import 'package:radha_swami_management_system/views/spalsh_page.dart';
import 'package:radha_swami_management_system/views/dashboard.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    // initialize supabase
    url: SUPABASE_URL,
    anonKey: SUPABASE_KEY,
  );

  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowManager.instance.setMinimumSize(const Size(1000, 563));
    WindowManager.instance.setMaximumSize(const Size(1920, 1080));
    WindowManager.instance.setTitle('Radha Swami');
  }

  final store = Store<AppState>(
      // create store
      combineReducers<AppState>([
        // combine reducers
        authorizedUsersReducer,
        attendeesReducer,
        userReducer,
      ]),
      initialState: AppState(
          attendeeStore: AttendeeListStore(list: []),
          authorizedUserStore: AuthorizedUserListStore(list: []),
          attendanceRecords: [],
          userStore: UserStore()));

  runApp(StoreProvider(store: store, child: const App())); // launch app
}

class App extends StatelessWidget {
  const App({super.key});

  // root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radha Swami',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/login': (context) =>
            WillPopScope(onWillPop: () async => false, child: const Login()),
        '/register': (context) =>
            WillPopScope(onWillPop: () async => false, child: const Register()),
        '/home': (context) => WillPopScope(
            onWillPop: () async => false, child: const Dashboard()),
      },
      theme: ThemeData(
        primaryColor: ACTION_COLOR,
        canvasColor: DASHBOARD_MENU_BACKGROUND_COLOR,
        scaffoldBackgroundColor: BACKGROUND_COLOR,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
