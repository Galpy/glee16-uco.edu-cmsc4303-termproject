import 'package:flutter/material.dart';
import 'package:lesson3/viewscreen/start_screen.dart';

void main() {
  runApp(const Lesson3App());
}

class Lesson3App extends StatelessWidget {
  const Lesson3App({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: StartScreen.routeName,
      routes: {
        StartScreen.routeName: (context) => const StartScreen(),
      },
    );
  }
}
