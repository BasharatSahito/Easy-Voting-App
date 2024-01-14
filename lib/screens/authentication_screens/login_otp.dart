import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:easy_voting_app/components/utils.dart';
import 'package:easy_voting_app/screens/authentication_screens/signup_fingerprint.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginOtp extends StatefulWidget {
  const LoginOtp({super.key});

  @override
  State<LoginOtp> createState() => _LoginOtpState();
}

class _LoginOtpState extends State<LoginOtp> {
  String phNoController = "";
  String otpVerifyController = "";
  bool loading = false;
  bool loading2 = false;
  String v = "";
  bool emptyPhNo = false;
  final auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    phNoController = user != null ? user!.phoneNumber.toString() : "";
  }

  void login() async {
    setState(() {
      loading2 = true;
    });
    final credential = PhoneAuthProvider.credential(
        verificationId: v, smsCode: otpVerifyController);
    try {
      await auth.signInWithCredential(credential);
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SignupFingerprint(),
        ),
      );
      setState(() {
        loading2 = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      Alert().dialog(
          context, DialogType.error, e.toString(), "Ok", () {}, "Cancel", null);

      setState(() {
        loading2 = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text(
          "Phone Login",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Your Registered Number is: $phNoController",
                  style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600),
                ),
                SizedBox(height: screenHeight * 0.05),
                RoundButton(
                  btnTitle: "Get Code",
                  loader: loading,
                  onTap: () {
                    setState(() {
                      loading = true;
                    });
                    auth.verifyPhoneNumber(
                      phoneNumber: phNoController,
                      verificationCompleted: (_) {
                        setState(() {
                          loading = false;
                        });
                      },
                      verificationFailed: (e) {
                        Utils().toastMessage(e.toString());
                        setState(() {
                          loading = false;
                        });
                      },
                      codeSent: (String verificationId, int? token) {
                        v = verificationId;
                        setState(() {
                          loading = false;
                        });
                      },
                      codeAutoRetrievalTimeout: (e) {
                        Utils().toastMessage(e.toString());
                        setState(() {
                          loading = false;
                        });
                      },
                    );
                  },
                ),
                SizedBox(height: screenHeight * 0.05),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 30,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      Text(
                        "Enter 6 digit OTP",
                        style: TextStyle(
                            fontSize: screenWidth * 0.044,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.teal,
                  enabled: true,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    // borderWidth: 2,
                    borderRadius: BorderRadius.circular(screenWidth * 0.10),
                    fieldHeight: screenHeight * 0.06,
                    fieldWidth: screenWidth * 0.13,
                    inactiveColor: Colors.grey,
                  ),
                  onChanged: (value) {},
                  onCompleted: (value) {
                    otpVerifyController = value;
                  },
                ),
                SizedBox(height: screenHeight * 0.11),
                RoundButton(
                  btnTitle: "Verify Code",
                  loader: loading2,
                  onTap: () {
                    login();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
