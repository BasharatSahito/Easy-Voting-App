import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditAdminProfile extends StatefulWidget {
  final String editFullName;
  final int editAge;
  const EditAdminProfile({
    super.key,
    required this.editFullName,
    required this.editAge,
  });

  @override
  State<EditAdminProfile> createState() => _EditAdminProfileState();
}

class _EditAdminProfileState extends State<EditAdminProfile> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final auth = FirebaseAuth.instance;

  //To UPDATE Candidates
  Future<void> updateAdmin(String name, int age) async {
    await FirebaseFirestore.instance
        .collection('admins')
        .doc(auth.currentUser!.uid)
        .update({'name': name, 'age': age});
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController fullNameController =
        TextEditingController(text: widget.editFullName);
    TextEditingController ageController =
        TextEditingController(text: widget.editAge.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Admin Profile"),
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
                          hintText: "Full Name",
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
                      TextFormField(
                        controller: ageController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: "Age",
                          prefixIcon: Icon(Icons.man_2_outlined),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter Age";
                          }
                          return null;
                        },
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
                      final age = int.tryParse(ageController.text.trim()) ?? 0;
                      Alert().dialog(
                        context,
                        DialogType.warning,
                        'Are You Sure',
                        "Yes",
                        () async {
                          try {
                            await updateAdmin(name, age).then(
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
