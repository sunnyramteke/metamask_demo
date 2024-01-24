import 'package:flutter/material.dart';
import 'package:metamask_demo/screens/landing_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
      ),
      darkTheme: ThemeData(colorScheme: const ColorScheme.dark()),
      themeMode: ThemeMode.system,
      home: const LandingScreen(),
    );
  }
}
