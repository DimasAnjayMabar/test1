import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:test1/home_page.dart';
import 'package:test1/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter(); // Inisialisasi Hive
  await Hive.openBox('database_identity'); // Membuka box untuk identitas database
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
      home: const LoginPage(),
      routes: {
        '/home' : (context) => const HomePage()
      },
    );
  }
}