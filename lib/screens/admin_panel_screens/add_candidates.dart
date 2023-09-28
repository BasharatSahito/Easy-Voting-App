import 'dart:io';
import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/components/main_logo.dart';
import 'package:easy_voting_app/components/neu_textfield.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class AddCandidates extends StatefulWidget {
  final String partyName;

  const AddCandidates({required this.partyName, Key? key}) : super(key: key);

  @override
  State<AddCandidates> createState() => _AddCandidatesState();
}

class _AddCandidatesState extends State<AddCandidates> {
  bool loading = false;
  final _firestore = FirebaseFirestore.instance;
  final fullNameController = TextEditingController();
  final ageController = TextEditingController();
  String? selectedGender;
  List<String> genderOptions = ['Male', 'Female', 'Other'];
  String? selectedCountry;
  String? selectedState;
  String? selectedCity;
  bool emptyPartyName = false;
  bool emptyFullName = false;

  File? profilePicture;

  @override
  void dispose() {
    fullNameController.dispose();

    super.dispose();
  }

  Future<String> generateCategoryNumber(String city, String party) async {
    final partyRef = _firestore.collection('politicalParties').doc(party);
    // ignore: unused_local_variable
    final candidatesCollection = partyRef.collection('candidates');

    // Check if the city exists in any party's candidates collection
    final otherPartiesSnapshot =
        await _firestore.collection('politicalParties').get();

    String? existingCategoryNumber;
    for (final otherParty in otherPartiesSnapshot.docs) {
      final partyName = otherParty.data()['partyName'];
      if (partyName != party) {
        final otherPartyCandidateSnapshot = await otherParty.reference
            .collection('candidates')
            .where('city', isEqualTo: city)
            .get();
        if (otherPartyCandidateSnapshot.docs.isNotEmpty) {
          existingCategoryNumber =
              otherPartyCandidateSnapshot.docs[0]['category'];
          break;
        }
      }
    }

    if (existingCategoryNumber != null) {
      // Use the existing category number found in another party's candidates collection
      return existingCategoryNumber;
    } else {
      // Generate a random category number
      final random = Random();
      final randomNumber = random.nextInt(200).toString();
      final categoryNumber = 'NA-$randomNumber';
      return categoryNumber;
    }
  }

  Future<bool> checkCityExistsInParty(String city, String party) async {
    final partyRef = _firestore.collection('politicalParties').doc(party);
    final matchingCandidates = await partyRef
        .collection('candidates')
        .where('city', isEqualTo: city)
        .limit(1)
        .get();

    return matchingCandidates.docs.isNotEmpty;
  }

  Future<void> _selectProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        profilePicture = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadProfilePicture() async {
    if (profilePicture == null) {
      return null;
    }
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('leaderdp')
          .child(fileName);
      final uploadTask = firebaseStorageRef.putFile(profilePicture!);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Candidates - ${widget.partyName}"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 10, left: 75, right: 75),
              child: MainLogo(whiteLogo: false),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
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
                                size: 50,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Center(
                      child: Text(
                    "Upload Leader Profile Image",
                    style: TextStyle(fontSize: 15),
                  )),
                  const SizedBox(
                    height: 40,
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
                        hintText: "Candidate's Name",
                        prefixIcon: Icon(
                          Icons.person,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: emptyFullName
                        ? const Text(
                            "Enter Candidate Name",
                            style: TextStyle(color: Colors.red),
                          )
                        : null,
                  ),
                  const SizedBox(
                    height: 25,
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
                    height: 25,
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
                    height: 50,
                  ),
                  RoundButton(
                    loader: loading,
                    btnTitle: "Allocate",
                    onTap: () async {
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

                      if (fullNameController.text.isEmpty) {
                        setState(() {
                          emptyFullName = true;
                        });
                      } else {
                        setState(() {
                          emptyFullName = false;
                        });
                      }

                      if (!RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(fullNameController.text) &&
                          fullNameController.text.isNotEmpty) {
                        Alert().dialog(
                            context,
                            DialogType.error,
                            'Candidate Name can only contain letters',
                            "Ok",
                            () {},
                            "Cancel",
                            null);
                        return;
                      }

                      if (selectedGender == null) {
                        Alert().dialog(context, DialogType.error,
                            'Choose a Gender', "Ok", () {}, "Cancel", null);
                        return;
                      }
                      if (selectedCountry == null) {
                        Alert().dialog(context, DialogType.error,
                            'Select a Country', "Ok", () {}, "Cancel", null);
                        return;
                      }

                      if (selectedState == null) {
                        Alert().dialog(context, DialogType.error,
                            'Select a State', "Ok", () {}, "Cancel", null);
                        return;
                      }
                      if (selectedCity == null) {
                        Alert().dialog(context, DialogType.error,
                            'Select a City', "Ok", () {}, "Cancel", null);
                        return;
                      }

                      if (fullNameController.text.isNotEmpty) {
                        try {
                          setState(() {
                            loading = true;
                          });

                          final city = selectedCity!;
                          final party = widget.partyName;

                          // Check if the party document exists and create it if it doesn't
                          final partyRef = _firestore
                              .collection('politicalParties')
                              .doc(party);
                          if (!(await partyRef.get()).exists) {
                            await partyRef.set({'partyName': widget.partyName});
                          }

                          // Check if the city already exists in the same party's candidates collection
                          final cityExistsInParty =
                              await checkCityExistsInParty(city, party);
                          if (cityExistsInParty) {
                            // If the city exists, show an error message
                            // ignore: use_build_context_synchronously
                            Alert().dialog(
                              context,
                              DialogType.error,
                              'City already exists in the party',
                              "Ok",
                              () {},
                              "Cancel",
                              null,
                            );
                            setState(() {
                              loading = false;
                            });
                            return;
                          }

                          // Generate or retrieve the category number
                          final categoryNumber =
                              await generateCategoryNumber(city, party);

                          final profilePictureUrl =
                              await _uploadProfilePicture();

                          // Add the candidate data to the subcollection 'candidates' inside the 'politicalParties' document
                          await partyRef.collection('candidates').add({
                            'fullName': fullNameController.text,
                            'politicalParty': widget.partyName,
                            'gender': selectedGender,
                            'country': selectedCountry,
                            'state': selectedState,
                            'city': city,
                            'votes': 0,
                            'category': categoryNumber,
                            'leaderPicUrl': profilePictureUrl,
                          });

                          setState(() {
                            loading = false;
                          });

                          // ignore: use_build_context_synchronously
                          Alert().dialog(
                            context,
                            DialogType.success,
                            'Candidate Successfully Added',
                            "Ok",
                            () {
                              Navigator.pop(context);
                            },
                            "Cancel",
                            null,
                          );
                        } catch (e) {
                          // ignore: use_build_context_synchronously
                          Alert().dialog(
                            context,
                            DialogType.success,
                            'Error Adding Candidates $e',
                            "Ok",
                            () {
                              Navigator.pop(context);
                            },
                            "Cancel",
                            null,
                          );
                          setState(() {
                            loading = false;
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
