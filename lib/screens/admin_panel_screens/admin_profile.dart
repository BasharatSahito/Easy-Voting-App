import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/view_admin_profile.dart';
import 'package:easy_voting_app/screens/getting_started.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  late Stream<DocumentSnapshot> _adminDataStream;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final adminId = auth.currentUser!.uid;
    _adminDataStream = FirebaseFirestore.instance
        .collection('admins')
        .doc(adminId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  "Admin Profile",
                  style: TextStyle(
                      fontSize: screenWidth * 0.06, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.09),
                    child: Container(
                      height: screenHeight,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: _adminDataStream,
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final adminData =
                              snapshot.data!.data()! as Map<String, dynamic>;

                          final adminName = adminData['name'] as String;
                          final adminEmail = adminData['email'] as String;
                          final adminAge = adminData['age'] as int;
                          final adminPhNo = adminData['phoneNumber'] as int;

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: screenHeight * 0.1),
                                  child: Text(
                                    adminName,
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.06,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  adminEmail,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.05),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.09),
                                  child: RoundButton(
                                      btnTitle: "View Profile",
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ViewAdminProfile(
                                                      adminName: adminName,
                                                      adminAge: adminAge,
                                                      adminEmail: adminEmail,
                                                      adminPhNo: adminPhNo),
                                            ));
                                      }),
                                ),
                                SizedBox(height: screenHeight * 0.05),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.04),
                                  child: Card(
                                    elevation: 1,
                                    color: Colors.grey[300],
                                    child: Column(
                                      children: [
                                        ListTile(
                                          title: const Text("Settings"),
                                          leading: const CircleAvatar(
                                              child: Icon(Icons.settings)),
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.indigo,
                                          ),
                                          onTap: () {},
                                        ),
                                        const Divider(
                                          color: Colors.grey,
                                        ),
                                        ListTile(
                                          title: const Text("Voting History"),
                                          leading: const CircleAvatar(
                                              child: Icon(Icons.history)),
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.indigo,
                                          ),
                                          onTap: () {},
                                        ),
                                        const Divider(
                                          color: Colors.grey,
                                        ),
                                        ListTile(
                                          title: const Text("Sign Out"),
                                          leading: const CircleAvatar(
                                              child: Center(
                                                  child: Icon(Icons.logout))),
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.indigo,
                                          ),
                                          onTap: () async {
                                            auth.signOut().then((value) {
                                              Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const GettingStarted(),
                                                  ),
                                                  (route) => false);
                                            });
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: screenWidth * 0.18,
                    backgroundImage: const NetworkImage(
                        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80"),
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
