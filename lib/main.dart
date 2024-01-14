import 'package:easy_voting_app/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Easy Voting App',
      theme: ThemeData(
        elevatedButtonTheme: const ElevatedButtonThemeData(
            style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Colors.indigo))),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          color: Colors.indigo,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        fontFamily: 'Rubik Regular',
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[300],
      ),
      home: const SplashScreen(),
    );
  }
}
