import 'package:flutter/material.dart';
import 'package:to_do_list_app1/notification_helper.dart';
import 'package:to_do_list_app1/splash_screen.dart';


Future main() async {
WidgetsFlutterBinding.ensureInitialized();
NotificationHelper.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
   debugShowCheckedModeBanner: false,

      home: SplashScreen(),
    );
  }
}

