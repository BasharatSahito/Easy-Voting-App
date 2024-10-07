import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:easy_voting_app/screens/getting_started.dart';
import 'package:easy_voting_app/screens/user_panel_screens/view_user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Stream<DocumentSnapshot> _userDataStream;
  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    final userId = auth.currentUser!.uid;
    _userDataStream =
        FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
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
                  "User Profile",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: StreamBuilder<DocumentSnapshot>(
                stream: _userDataStream,
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final userData =
                      snapshot.data!.data()! as Map<String, dynamic>;
                  final cnic = userData['cnic'] as String;
                  final userName = userData['name'] as String;
                  final userEmail = userData['email'] as String;
                  final userPhNo = userData['phoneNumber'] as int;
                  final userPic = userData['profilePictureUrl'] as String;
                  final userGender = userData['gender'] as String;
                  final userCity = userData['city'] as String;
                  final userState = userData['state'] as String;
                  final userAddress = userData['address'] as String;
                  final dob = userData['dob'] as Timestamp;
                  //  Convert Timestamp to DateTime
                  final dobDateTime = dob.toDate();
                  // Format the DateTime to display only day, month, and year
                  final formattedDob =
                      '${dobDateTime.day}/${dobDateTime.month}/${dobDateTime.year}';

                  return Stack(
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
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: screenHeight * 0.1),
                                  child: Text(
                                    userName,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.06,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  userEmail,
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
                                          builder: (context) => ViewUserProfile(
                                            cnic: cnic,
                                            userName: userName,
                                            userEmail: userEmail,
                                            userPhNo: userPhNo,
                                            userPic: userPic,
                                            userGender: userGender,
                                            dob: formattedDob,
                                            userCity: userCity,
                                            userState: userState,
                                            userAddress: userAddress,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
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
                                            backgroundColor: Colors.indigo,
                                            foregroundColor: Colors.white,
                                            child: Icon(Icons.settings),
                                          ),
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
                                            backgroundColor: Colors.indigo,
                                            foregroundColor: Colors.white,
                                            child: Icon(Icons.history),
                                          ),
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
                                            backgroundColor: Colors.indigo,
                                            foregroundColor: Colors.white,
                                            child: Center(
                                                child: Icon(Icons.logout)),
                                          ),
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
                                                (route) => false,
                                              );
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: screenWidth * 0.18,
                        backgroundImage: NetworkImage(userPic),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
