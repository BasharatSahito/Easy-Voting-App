import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/components/neu_textfield.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:easy_voting_app/components/utils.dart';
import 'package:easy_voting_app/screens/authentication_screens/signup_fingerprint.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SignUpOtp extends StatefulWidget {
  final String cnic;
  final String fullName;
  final String gender;
  final DateTime? dob;
  final String country;
  final String state;
  final String city;
  final String address;
  final String email;
  final String password;
  // ignore: prefer_typing_uninitialized_variables
  final profilePicture;

  const SignUpOtp({
    super.key,
    required this.cnic,
    required this.fullName,
    required this.gender,
    required this.dob,
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    required this.email,
    required this.password,
    required this.profilePicture,
  });

  @override
  State<SignUpOtp> createState() => _SignUpOtpState();
}

class _SignUpOtpState extends State<SignUpOtp> {
  final phoneNumberController = TextEditingController();
  String verifyCodeController = "";
  final formKey = GlobalKey<FormState>();
  String v = "";
  bool loading = false;
  bool loading2 = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool emptyPhNo = false;

  Future<void> signUp() async {
    setState(() {
      loading2 = true;
    });
    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: v, smsCode: verifyCodeController);

      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        Utils().toastMessage("An unexpected error occurred");
        setState(() {
          loading2 = false;
        });
        return;
      }

      // Link phone credential with email
      final UserCredential authResult = await user.linkWithCredential(
        EmailAuthProvider.credential(
            email: widget.email, password: widget.password),
      );

      final User? linkedUser = authResult.user;

      if (linkedUser == null) {
        Utils().toastMessage("An unexpected error occurred");
        setState(() {
          loading2 = false;
        });
        return;
      }

      final profilePictureUrl = await _uploadProfilePicture();
      //  STORING USER DATA IN FIRESTORE DATABASE

      await _firestore.collection('users').doc(user.uid).set({
        'cnic': widget.cnic,
        'name': widget.fullName,
        'gender': widget.gender,
        'dob': widget.dob,
        'country': widget.country,
        'state': widget.state,
        'city': widget.city,
        'address': widget.address,
        'email': widget.email,
        'phoneNumber': int.parse(phoneNumberController.text),
        'role': "user",
        'selectedCandidateId': null,
        'profilePictureUrl': profilePictureUrl,
        'voted': false
      });

      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const SignupFingerprint(),
        ),
        (route) => false,
      );
      setState(() {
        loading2 = false;
      });
    } catch (error) {
      // ignore: use_build_context_synchronously
      Alert().dialog(context, DialogType.error,
          'Unexpected error occured $error', "Ok", () {}, "Cancel", null);
      setState(() {
        loading2 = false;
      });
    }
  }

  Future<String?> _uploadProfilePicture() async {
    if (widget.profilePicture == null) {
      return null;
    }
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('userdp')
          .child(
              fileName); // Set the folder path as 'userdp' and include the fileName
      final uploadTask = firebaseStorageRef.putFile(widget.profilePicture!);
      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == firebase_storage.TaskState.success) {
        final downloadUrl = await firebaseStorageRef.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Alert().dialog(
        context,
        DialogType.error,
        'Error uploading profile picture: $e',
        "Ok",
        () {},
        "Cancel",
        null,
      );
    }
    return null;
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: const Text(
          "Phone SignUp",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                NeuTextfield(
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        emptyPhNo = false;
                      });
                    },
                    keyboardType: TextInputType.number,
                    controller: phoneNumberController,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(
                          11), // Limit input to 13 characters
                      FilteringTextInputFormatter
                          .digitsOnly, // Accept only digits
                    ],
                    decoration: InputDecoration(
                      hintText: "Enter Your Phone Number",
                      contentPadding: const EdgeInsets.symmetric(vertical: 19),
                      prefixIcon: Padding(
                        padding:
                            const EdgeInsets.only(top: 14, left: 10, right: 11),
                        child: Text(
                          "(+92)",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800]),
                        ),
                      ),
                      suffixIcon: TextButton(
                        onPressed: () {
                          if (phoneNumberController.text.isNotEmpty) {
                            setState(() {
                              loading = true;
                            });
                            auth.verifyPhoneNumber(
                              phoneNumber: "+92${phoneNumberController.text}",
                              verificationCompleted: (_) {
                                Alert().dialog(
                                    context,
                                    DialogType.error,
                                    'Verification Complete',
                                    "Ok",
                                    () {},
                                    "Cancel",
                                    null);
                                setState(() {
                                  loading = false;
                                });
                              },
                              verificationFailed: (e) {
                                Alert().dialog(
                                    context,
                                    DialogType.error,
                                    'Verification Failed $e',
                                    "Ok",
                                    () {},
                                    "Cancel",
                                    null);

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
                                Alert().dialog(
                                    context,
                                    DialogType.info,
                                    "Code Retreival TimeOut $e",
                                    "Ok",
                                    () {},
                                    "Cancel",
                                    null);
                                setState(() {
                                  loading = false;
                                });
                              },
                            );
                          } else {
                            Alert().dialog(
                                context,
                                DialogType.error,
                                'Please Enter Phone Number First',
                                "Ok",
                                () {},
                                "Cancel",
                                null);
                          }
                        },
                        child: loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(),
                              )
                            : const Padding(
                                padding: EdgeInsets.only(right: 11.0),
                                child: Text(
                                  "Send",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
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
                            fontSize: 17,
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
                const SizedBox(
                  height: 25,
                ),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.teal,
                  enabled: true,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 50,
                    fieldWidth: 50,
                    inactiveColor: Colors.grey,
                  ),
                  onChanged: (value) {},
                  onCompleted: (value) {
                    verifyCodeController = value;
                  },
                ),
                const SizedBox(
                  height: 70,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: RoundButton(
                    btnTitle: "Verify Code",
                    loader: loading2,
                    onTap: () {
                      if (phoneNumberController.text.isNotEmpty) {
                        signUp();
                      } else {
                        Alert().dialog(
                            context,
                            DialogType.error,
                            'Please Enter Phone Number First',
                            "Ok",
                            () {},
                            "Cancel",
                            null);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
