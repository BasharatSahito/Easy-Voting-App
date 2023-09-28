import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditUserProfile extends StatefulWidget {
  final String editFullName;

  const EditUserProfile({
    super.key,
    required this.editFullName,
  });

  @override
  State<EditUserProfile> createState() => _EditUserProfileState();
}

class _EditUserProfileState extends State<EditUserProfile> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;

  //To UPDATE Candidates
  Future<void> updateUser(String name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'name': name});
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController fullNameController =
        TextEditingController(text: widget.editFullName);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit User Profile"),
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
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: fullNameController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          hintText: "Enter Full Name",
                          labelText: "Full Name",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_2_outlined),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Fullname";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                RoundButton(
                  btnTitle: "Update",
                  onTap: () async {
                    if (formKey.currentState!.validate()) {
                      final name = fullNameController.text.trim();

                      Alert().dialog(
                        context,
                        DialogType.warning,
                        'Are You Sure',
                        "Yes",
                        () async {
                          try {
                            await updateUser(name).then(
                              (value) {
                                Alert().dialog(
                                  context,
                                  DialogType.success,
                                  'Updated Successfully',
                                  "Ok",
                                  () {
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  "Cancel",
                                  null,
                                );
                              },
                            );
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            Alert().dialog(
                              context,
                              DialogType.error,
                              'Error Updating',
                              "Ok",
                              () {},
                              "Cancel",
                              null,
                            );
                          }
                        },
                        "No",
                        () {},
                      );
                    }
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
