import 'package:easy_voting_app/components/drawer_tiles.dart';
import 'package:easy_voting_app/components/icon_button.dart';
import 'package:easy_voting_app/components/main_logo.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:easy_voting_app/screens/authentication_screens/admin_login.dart';
import 'package:easy_voting_app/screens/authentication_screens/login_screen.dart';
import 'package:easy_voting_app/screens/authentication_screens/signup_screen.dart';
import 'package:flutter/material.dart';

class GettingStarted extends StatefulWidget {
  const GettingStarted({super.key});

  @override
  State<GettingStarted> createState() => _GettingStartedState();
}

class _GettingStartedState extends State<GettingStarted> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _globalKey,
      drawer: Drawer(
        child: Container(
          color: Colors.grey[300],
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Colors.indigo),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: MainLogo(whiteLogo: true),
                      ),
                    ),
                    Wrap(
                      runSpacing: 9,
                      children: [
                        DrawerTiles(
                          btnTitle: "ABOUT",
                          onTap: () {},
                          btnIcon: const Icon(
                            Icons.info_outline,
                            size: 25,
                          ),
                        ),
                        DrawerTiles(
                          btnTitle: "HELP & SUPPORT",
                          onTap: () {},
                          btnIcon: const Icon(
                            Icons.alternate_email_outlined,
                            size: 25,
                          ),
                        ),
                        DrawerTiles(
                          btnTitle: "ADMIN LOGIN",
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminLogin(),
                                ));
                          },
                          btnIcon: const Icon(
                            Icons.account_circle_outlined,
                            size: 25,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: screenHeight *
                      0.03, // set the height of the logo based on screen height
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight *
                          0.01), // set the horizontal padding based on screen width
                  child: const MainLogo(
                    whiteLogo: false,
                  ),
                ),
                SizedBox(
                  height: screenHeight *
                      0.1, // set the height of the welcome text based on screen height
                ),
                Text(
                  "WELCOME",
                  style: TextStyle(
                    fontSize: screenHeight *
                        0.05, // set the font size based on screen height

                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: screenHeight *
                      0.2, // set the height of the space between the buttons based on screen height
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth *
                          0.15), // set the horizontal padding based on screen width
                  child: RoundButton(
                    btnTitle: "SIGN IN",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ));
                    },
                  ),
                ),
                SizedBox(
                  height: screenHeight *
                      0.03, // set the height of the space between the buttons based on screen height
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth *
                          0.15), // set the horizontal padding based on screen width
                  child: RoundButton(
                    btnTitle: "SIGN UP",
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ));
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              left: 10,
              top: 1,
              child: NeuIconButton(
                color: Colors.grey[300]!,
                btnIcon: const Icon(Icons.menu),
                onTap: () {
                  _globalKey.currentState!.openDrawer();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
