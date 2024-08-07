import 'package:flutter/material.dart';
import 'package:to_do_list_app1/todopage.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InitState();
}

class InitState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() async {
    var duration = Duration(seconds: 5);
    return new Timer(duration, Route);
  }

  Route() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TodoListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return initWidget();
  }
}

Widget initWidget() {
  return Scaffold(
    body: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Image.asset('images/appicon.jpg'),
              ),
              SizedBox(height: 20), // Space between image and loading indicator
              CircularProgressIndicator(), // Loading circle
            ],
          ),
        ),
      ],
    ),
  );
}
