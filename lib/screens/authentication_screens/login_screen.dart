import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/components/icon_button.dart';
import 'package:easy_voting_app/components/neu_textfield.dart';
import 'package:easy_voting_app/components/main_logo.dart';
import 'package:easy_voting_app/screens/authentication_screens/login_otp.dart';
import 'package:easy_voting_app/screens/authentication_screens/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  final auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool emptyEmail = false;
  bool emptyPassword = false;
  bool secureText = true;

  @override
  void dispose() {
    // ignore: todo
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<String> getRole(String uid) async {
    String role = "";
    await _firestore.collection('users').doc(uid).get().then((doc) {
      if (doc.exists) {
        role = doc.data()!['role'];
      }
    });
    return role;
  }

  void login() async {
    try {
      setState(() {
        loading = true;
      });
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passwordController.text.toString());

      String role = await getRole(userCredential.user!.uid);
      if (role == "user") {
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
            "You are not Authorized as User", "Ok", () {}, "Cancel", null);
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, left: 75, right: 75),
                child: MainLogo(whiteLogo: false),
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                "L O G I N",
                style: TextStyle(
                    fontSize: 35,
                    fontFamily: "rubik regular",
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 80,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
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
                            prefixIcon: Icon(
                              Icons.alternate_email,
                            ),
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
                      const SizedBox(
                        height: 15,
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
                      const SizedBox(
                        height: 35,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Sign In",
                              style: TextStyle(
                                  fontSize: 30,
                                  fontFamily: "rubik regular",
                                  fontWeight: FontWeight.w700),
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
                                    btnIcon: const Icon(Icons.arrow_forward,
                                        color: Colors.white),
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
                                        login();
                                      }
                                    },
                                  ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                color: Colors.grey[850],
                                fontSize: 17,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupScreen(),
                                ),
                              );
                            },
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
