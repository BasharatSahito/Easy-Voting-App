import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/screens/authentication_screens/login_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_voting_app/components/neu_textfield.dart';
import 'package:easy_voting_app/components/icon_button.dart';
import 'package:easy_voting_app/components/main_logo.dart';
import 'package:flutter/material.dart';
import '../../components/alert_box.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  final auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool emptyEmail = false;
  bool emptyPassword = false;
  bool secureText = true;

  Future<String> getRole(String uid) async {
    String role = "";
    await _firestore.collection('admins').doc(uid).get().then((doc) {
      if (doc.exists) {
        role = doc.data()!['role'];
      }
    });
    return role;
  }

  void adminLogin() async {
    try {
      setState(() {
        loading = true;
      });
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passwordController.text.toString());

      String role = await getRole(userCredential.user!.uid);
      if (role == "admin") {
        // ignore: use_build_context_synchronously
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginOtp(),
            ));
        setState(() {
          loading = false;
        });
      } else {
        // ignore: use_build_context_synchronously
        Alert().dialog(context, DialogType.error,
            "You are not Authorized as Admin", "Ok", () {}, "Cancel", null);

        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Alert().dialog(
          context, DialogType.error, e.toString(), "Ok", () {}, "Cancel", null);
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: screenHeight * 0.04,
                  left: screenWidth * 0.1,
                  right: screenWidth * 0.1,
                ),
                child: const MainLogo(whiteLogo: false),
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Text(
                "ADMIN LOGIN",
                style: TextStyle(
                  fontSize: screenWidth * 0.08,
                  fontFamily: "rubik regular",
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: screenHeight * 0.1,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.07),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NeuTextfield(
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              emptyEmail = false;
                            });
                          },
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: "Email",
                            prefixIcon: Icon(Icons.alternate_email),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                        child: emptyEmail
                            ? const Text(
                                "Enter Email",
                                style: TextStyle(color: Colors.red),
                              )
                            : null,
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      NeuTextfield(
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              emptyPassword = false;
                            });
                          },
                          controller: passwordController,
                          obscureText: secureText,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: InputBorder.none,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  secureText = !secureText;
                                });
                              },
                              child: secureText
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                        child: emptyPassword
                            ? const Text(
                                "Enter Password",
                                style: TextStyle(color: Colors.red),
                              )
                            : null,
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Sign In",
                              style: TextStyle(
                                fontSize: screenWidth * 0.07,
                                fontFamily: "rubik regular",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            loading
                                ? Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: CircularProgressIndicator(
                                      color: Colors.grey[850]!,
                                    ),
                                  )
                                : NeuIconButton(
                                    color: Colors.grey[850]!,
                                    btnIcon: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                    onTap: () {
                                      if (emailController.text.isEmpty) {
                                        setState(() {
                                          emptyEmail = true;
                                        });
                                      } else {
                                        setState(() {
                                          emptyEmail = false;
                                        });
                                      }
                                      if (passwordController.text.isEmpty) {
                                        setState(() {
                                          emptyPassword = true;
                                        });
                                      } else {
                                        setState(() {
                                          emptyPassword = false;
                                        });
                                      }

                                      if (emailController.text.isNotEmpty &&
                                          passwordController.text.isNotEmpty) {
                                        adminLogin();
                                      }
                                    },
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Forgot Password",
                              style: TextStyle(
                                color: Colors.grey[850],
                                fontSize: 17,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
