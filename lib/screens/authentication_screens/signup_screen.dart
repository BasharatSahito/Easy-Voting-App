import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/components/icon_button.dart';
import 'package:easy_voting_app/components/main_logo.dart';
import 'package:easy_voting_app/components/neu_textfield.dart';
import 'package:easy_voting_app/screens/authentication_screens/login_screen.dart';
import 'package:easy_voting_app/screens/authentication_screens/signup_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:image_picker/image_picker.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool loading = false;
  final formKey = GlobalKey<FormState>();
  final cnicController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fullNameController = TextEditingController();
  final addressController = TextEditingController();
  final otpController = TextEditingController();

  String? selectedGender;
  List<String> genderOptions = ['Male', 'Female', 'Other'];

  DateTime? selectedDate;
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;

  bool emptyCnic = false;
  bool emptyFullName = false;
  bool emptyAddress = false;
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
    fullNameController.dispose();
    addressController.dispose();
  }

  Future<bool> checkExistingCNIC(String cnic) async {
    setState(() {
      loading = true;
    });
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('cnic', isEqualTo: cnic)
        .limit(1)
        .get();
    setState(() {
      loading = false;
    });
    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> checkExistingEmail(String email) async {
    setState(() {
      loading = true;
    });
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    setState(() {
      loading = false;
    });
    return querySnapshot.docs.isNotEmpty;
  }

  File? profilePicture;

  Future<void> _selectProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profilePicture = File(pickedFile.path);
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
                padding: EdgeInsets.only(top: 20, left: 85, right: 85),
                child: MainLogo(whiteLogo: false),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "SIGN UP",
                style: TextStyle(
                    fontSize: 35,
                    fontFamily: "rubik regular",
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _selectProfilePicture,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: profilePicture != null
                                ? ClipOval(
                                    child: Image.file(
                                      profilePicture!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_a_photo,
                                    size: 70,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      const Center(
                        child: Text(
                          "Select a Profile Photo",
                          style: TextStyle(
                              fontSize: 16,
                              fontFamily: "rubik regular",
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      NeuTextfield(
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              emptyCnic = false;
                            });
                          },
                          controller: cnicController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                                13), // Limit input to 13 characters
                            FilteringTextInputFormatter
                                .digitsOnly, // Accept only digits
                          ],
                          decoration: const InputDecoration(
                            hintText: "CNIC No without dashes (-)",
                            prefixIcon: Icon(Icons.wallet),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                        child: emptyCnic
                            ? const Text(
                                "Enter Cnic No",
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
                              emptyFullName = false;
                            });
                          },
                          controller: fullNameController,
                          keyboardType: TextInputType.name,
                          decoration: const InputDecoration(
                            hintText: "Full Name",
                            prefixIcon: Icon(Icons.person_2_outlined),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                        child: emptyFullName
                            ? const Text(
                                "Enter Fullname",
                                style: TextStyle(color: Colors.red),
                              )
                            : null,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        hint: const Text("Choose Your Gender"),
                        onChanged: (newValue) {
                          setState(() {
                            selectedGender = newValue!;
                          });
                        },
                        items: genderOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      TextFormField(
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: "Date of Birth",
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : '',
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      CSCPicker(
                        onCountryChanged: (country) {
                          setState(() {
                            selectedCountry = country;
                          });
                        },
                        onStateChanged: (state) {
                          setState(() {
                            selectedState = state;
                          });
                        },
                        onCityChanged: (city) {
                          setState(() {
                            selectedCity = city;
                          });
                        },
                        countryFilter: const [CscCountry.Pakistan],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      NeuTextfield(
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              emptyAddress = false;
                            });
                          },
                          controller: addressController,
                          keyboardType: TextInputType.streetAddress,
                          decoration: const InputDecoration(
                            hintText: "Address",
                            prefixIcon: Icon(Icons.location_city_outlined),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                        child: emptyAddress
                            ? const Text(
                                "Enter Address",
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
                              "Next",
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
                                    onTap: () async {
                                      // CONDITIONS FOR EMPTY FIELDS & WRONG INFO

                                      if (profilePicture == null) {
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Please Select a Profile Pic First',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }
                                      String formattedCNIC = "";
                                      if (cnicController.text.length == 13) {
                                        final cnicNumber = cnicController.text
                                            .replaceAll('-',
                                                ''); // Remove existing hyphens
                                        formattedCNIC =
                                            '${cnicNumber.substring(0, 5)}-${cnicNumber.substring(5, 12)}-${cnicNumber.substring(12)}';
                                      } else if (cnicController
                                          .text.isNotEmpty) {
                                        // ignore: use_build_context_synchronously
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Cnic Field Must Contain 13 Digits',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }

                                      if (cnicController.text.isEmpty) {
                                        setState(() {
                                          emptyCnic = true;
                                        });
                                      } else {
                                        setState(() {
                                          emptyCnic = false;
                                        });
                                      }

                                      if (fullNameController.text.isEmpty) {
                                        setState(() {
                                          emptyFullName = true;
                                        });
                                      } else {
                                        setState(() {
                                          emptyFullName = false;
                                        });
                                      }
                                      if (addressController.text.isEmpty) {
                                        setState(() {
                                          emptyAddress = true;
                                        });
                                      } else {
                                        setState(() {
                                          emptyAddress = false;
                                        });
                                      }

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
                                      if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(
                                              fullNameController.text) &&
                                          fullNameController.text.isNotEmpty) {
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Full Name can only contain letters',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }
                                      if (selectedGender == null) {
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Choose a Gender',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }

                                      if (selectedDate == null) {
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Choose Date of Birth',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }

                                      if (selectedCountry == null) {
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Select a Country',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }

                                      if (selectedState == null) {
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Select a State',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }
                                      if (selectedCity == null) {
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Select a City',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }

                                      if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                                              .hasMatch(emailController.text) &&
                                          emailController.text.isNotEmpty) {
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Email Format is not Correct',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }

                                      if (passwordController.text.length < 6) {
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Password Length Should be 6 or more',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }

                                      final existingEmail =
                                          await checkExistingEmail(
                                              emailController.text);
                                      final existingCNIC =
                                          await checkExistingCNIC(
                                              formattedCNIC);

                                      if (existingCNIC) {
                                        // ignore: use_build_context_synchronously
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Cnic already exist',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }

                                      if (existingEmail) {
                                        // ignore: use_build_context_synchronously
                                        Alert().dialog(
                                            context,
                                            DialogType.error,
                                            'Email already exist',
                                            "Ok",
                                            () {},
                                            "Cancel",
                                            null);
                                        return;
                                      }

                                      if (cnicController.text.isNotEmpty &&
                                          fullNameController.text.isNotEmpty &&
                                          addressController.text.isNotEmpty &&
                                          emailController.text.isNotEmpty &&
                                          passwordController.text.isNotEmpty) {
                                        setState(() {
                                          loading = true;
                                        });
                                        // ignore: use_build_context_synchronously
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SignUpOtp(
                                              cnic: formattedCNIC,
                                              fullName: fullNameController.text,
                                              gender: selectedGender.toString(),
                                              dob: selectedDate,
                                              country:
                                                  selectedCountry.toString(),
                                              state: selectedState.toString(),
                                              city: selectedCity.toString(),
                                              address: addressController.text,
                                              email: emailController.text,
                                              password: passwordController.text,
                                              profilePicture: profilePicture,
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          loading = false;
                                        });
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account",
                            style: TextStyle(
                              color: Colors.grey[850],
                              fontSize: 17,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Login In",
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
