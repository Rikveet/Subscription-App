import 'package:flutter/material.dart';
import 'package:radha_swami_management_system/constants.dart';
import 'package:radha_swami_management_system/screens/home.dart';
import 'package:radha_swami_management_system/widgets/nav_bar.dart';
import 'package:sidebarx/sidebarx.dart';

// import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // await Supabase.initialize( // initialize supabase
  //   url: Constants.SUPABASE_URL,
  //   anonKey: Constants.SUPABASE_KEY,
  // );

  runApp(MyApp()); // launch app
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  // root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radha Swami',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Constants.primaryColor,
        canvasColor: Constants.canvasColor,
        scaffoldBackgroundColor: Constants.scaffoldBackgroundColor,
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            color: Colors.white,
            fontSize: 46,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      home: Builder(builder: (context) {
        final isSmallScreen = MediaQuery.of(context).size.width < 600;
        return Scaffold(
          key: _key,
          appBar: isSmallScreen
              ? AppBar(
                  backgroundColor: Constants.canvasColor,
                  title: Text(Constants.getTitleByIndex(_controller.selectedIndex)),
                  leading: IconButton(
                    onPressed: () {
                      _key.currentState?.openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  ),
                )
              : null,
          drawer: NavBar(controller: _controller),
          body: Row(children: [
            if (!isSmallScreen) NavBar(controller: _controller),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // final theme = Theme.of(context);
                    switch (_controller.selectedIndex) {
                      case 0:
                        return const Home();
                      case 1:
                        return Container(); // Reminders
                      case 2:
                        return Container(); // Settings
                      case 3:
                        return Container(); // Authorize Accounts
                      case 4:
                        return Container(); //Settings
                      default:
                        return Container(); // How did you end up here?
                    }
                  },
                ),
              ),
            ),
          ]),
        );
      }),
    );
  }
}
