import 'package:flutter/material.dart';
import 'package:test1/HomePage.dart';
import 'package:test1/WelcomePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Agus Plastik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserratt'
      ),
      home: const WelcomePage(),
      routes: {
        '/home' : (context) => const Homepage()
      },
    );
  }
}