import 'dart:async';

import 'package:easy_voting_app/components/main_logo.dart';
import 'package:easy_voting_app/screens/getting_started.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

final auth = FirebaseAuth.instance;
final user = auth.currentUser;

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();

    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const GettingStarted(),
          ));
    });

    // if (user != null) {
    //   Timer(const Duration(seconds: 5), () {
    //     Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => const UserHomePage(),
    //         ));
    //   });
    // } else {
    //   Timer(const Duration(seconds: 5), () {
    //     Navigator.pushReplacement(
    //         context,
    //         MaterialPageRoute(
    //           builder: (context) => const LoginScreen(),
    //         ));
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
            child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 65),
      child: MainLogo(whiteLogo: false),
    )));
  }
}
