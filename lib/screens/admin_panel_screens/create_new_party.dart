// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/components/main_logo.dart';
import 'package:easy_voting_app/components/neu_textfield.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class CreateNewParty extends StatefulWidget {
  const CreateNewParty({super.key});

  @override
  State<CreateNewParty> createState() => _CreateNewPartyState();
}

class _CreateNewPartyState extends State<CreateNewParty> {
  bool loading = false;
  final _firestore = FirebaseFirestore.instance;
  final partyController = TextEditingController();

  bool emptyPartyName = false;
  File? partySymbol;

  @override
  void dispose() {
    partyController.dispose();
    super.dispose();
  }

  Future<void> _selectPartySymbol() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        partySymbol = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadPartySymbol() async {
    if (partySymbol == null) {
      return null;
    }
    try {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final firebaseStorageRef = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('partySymbol')
          .child(fileName);
      final uploadTask = firebaseStorageRef.putFile(partySymbol!);
      final snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == firebase_storage.TaskState.success) {
        final downloadUrl = await firebaseStorageRef.getDownloadURL();
        return downloadUrl;
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      Alert().dialog(
        // ignore: use_build_context_synchronously
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
        title: const Text("Create New Party"),
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
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _selectPartySymbol,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[200],
                        ),
                        child: partySymbol != null
                            ? ClipOval(
                                child: Image.file(
                                  partySymbol!,
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
                    "Upload Political Party Symbol Image",
                    style: TextStyle(fontSize: 15),
                  )),
                  const SizedBox(
                    height: 36,
                  ),
                  NeuTextfield(
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          emptyPartyName = false;
                        });
                      },
                      controller: partyController,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: "Political Party Name",
                        prefixIcon: Icon(
                          Icons.flag,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: emptyPartyName
                        ? const Text(
                            "Enter Political Party Name",
                            style: TextStyle(color: Colors.red),
                          )
                        : null,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  RoundButton(
                    loader: loading,
                    btnTitle: "Create Political Party",
                    onTap: () async {
                      if (partySymbol == null) {
                        Alert().dialog(
                            context,
                            DialogType.error,
                            'Please Select a Party Symbol First',
                            "Ok",
                            () {},
                            "Cancel",
                            null);
                        return;
                      }

                      if (partyController.text.isEmpty) {
                        setState(() {
                          emptyPartyName = true;
                        });
                      } else {
                        setState(() {
                          emptyPartyName = false;
                        });
                      }

                      if (!RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(partyController.text) &&
                          partyController.text.isNotEmpty) {
                        Alert().dialog(
                            context,
                            DialogType.error,
                            'Political Party Name can only contain letters',
                            "Ok",
                            () {},
                            "Cancel",
                            null);
                        return;
                      }

                      if (partyController.text.isNotEmpty) {
                        try {
                          setState(() {
                            loading = true;
                          });

                          final party = partyController.text
                              .toUpperCase(); // Convert party name to uppercase

                          final partySymbolUrl = await _uploadPartySymbol();

                          await _firestore
                              .collection("politicalParties")
                              .doc(party)
                              .set({
                            'partyName': party,
                            'totalVotes': 0,
                            'partySymbolUrl': partySymbolUrl,
                          });
                          setState(() {
                            loading = false;
                          });

                          Alert().dialog(
                            context,
                            DialogType.success,
                            'Political Party Successfully Created',
                            "Ok",
                            () {
                              Navigator.pop(context);
                            },
                            "Cancel",
                            null,
                          );
                        } catch (e) {
                          Alert().dialog(
                            context,
                            DialogType.success,
                            'Error Creating Political Party: $e',
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
