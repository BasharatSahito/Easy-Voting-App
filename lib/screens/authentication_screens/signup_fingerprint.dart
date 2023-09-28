import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:easy_voting_app/components/utils.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/admin_homepage.dart';
import 'package:easy_voting_app/screens/user_panel_screens/user_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class SignupFingerprint extends StatefulWidget {
  const SignupFingerprint({super.key});

  @override
  State<SignupFingerprint> createState() => _SignupFingerprintState();
}

class _SignupFingerprintState extends State<SignupFingerprint> {
  final LocalAuthentication _localauth = LocalAuthentication();
  bool auth = true;
  final _firestore = FirebaseFirestore.instance;
  final _fireauth = FirebaseAuth.instance;

  Future<String> getRole(String uid) async {
    String role = "";
    await _firestore.collection('users').doc(uid).get().then((doc) {
      if (doc.exists) {
        role = doc.data()!['role'];
      }
    });
    return role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Biometric Verification"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RoundButton(
                  btnTitle: "Authenticate",
                  onTap: () async {
                    try {
                      bool checkingBiometric =
                          await _localauth.canCheckBiometrics;

                      if (checkingBiometric) {
                        bool authenticated = await _localauth.authenticate(
                            localizedReason: "Use Fingerprint to Login");
                        if (authenticated) {
                          String role =
                              await getRole(_fireauth.currentUser!.uid);
                          if (role == "user") {
                            // ignore: use_build_context_synchronously
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserHomePage(),
                                ),
                                (route) => false);
                          } else {
                            // ignore: use_build_context_synchronously
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminHomePage(),
                                ),
                                (route) => false);
                          }
                        }
                      } else {
                        // Device does not support biometrics, prompt user for lock screen password
                        bool authenticated = await _localauth.authenticate(
                            localizedReason: "Enter your lock screen password");
                        if (authenticated) {
                          String role =
                              await getRole(_fireauth.currentUser!.uid);
                          if (role == "user") {
                            // ignore: use_build_context_synchronously
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserHomePage(),
                                ),
                                (route) => false);
                          } else {
                            // ignore: use_build_context_synchronously
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AdminHomePage(),
                                ),
                                (route) => false);
                          }
                        } else {
                          Utils().toastMessage("Authentication failed");
                        }
                      }
                    } catch (e) {
                      setState(() {
                        auth = false;
                      });
                    }
                  },
                ),
                const SizedBox(
                  height: 50,
                ),
                auth
                    ? const Text("")
                    : const Text(
                        "Please Add a LockScreen Security to this Device"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
