// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/check_results.dart';
import 'package:easy_voting_app/components/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OldUserVotingPanel extends StatefulWidget {
  const OldUserVotingPanel({super.key});

  @override
  State<OldUserVotingPanel> createState() => _OldUserVotingPanelState();
}

class _OldUserVotingPanelState extends State<OldUserVotingPanel> {
  late Stream<bool> _votingEnabledStream;
  String? selectedCandidateId;
  final auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String v = "";
  TextEditingController otpVerifyController = TextEditingController();

  bool authenty = true;
  bool isVotingEnabled = false;

  @override
  void initState() {
    super.initState();
    // Fetch the voting enabled stream only once in the initState
    _votingEnabledStream = checkAdminVoting();
  }

  Stream<bool> checkAdminVoting() {
    return _firestore.collection('admins').snapshots().map((querySnapshot) {
      bool isEnabled = false;
      for (var doc in querySnapshot.docs) {
        isEnabled = doc.get("voting");
      }
      return isEnabled;
    });
  }

  // VERIFY OTP METHOD

  Future<bool> login() async {
    final credential = PhoneAuthProvider.credential(
      verificationId: v,
      smsCode: otpVerifyController.text,
    );
    try {
      final userCredential = await auth.signInWithCredential(credential);
      return userCredential.user != null;
    } catch (e) {
      Utils().toastMessage(e.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final userDoc = snapshot.data!;
        final userCity = userDoc.get('city');
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Voting Panel"),
            automaticallyImplyLeading: false,
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckResults(),
                    ),
                  );
                },
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all(0),
                ),
                child: const Text(
                  "Check Results",
                  style: TextStyle(color: Colors.white, fontSize: 19),
                ),
              )
            ],
          ),
          body: StreamBuilder<bool>(
            stream: _votingEnabledStream,
            builder: (context, AsyncSnapshot<bool> votingEnabledSnapshot) {
              if (votingEnabledSnapshot.connectionState ==
                  ConnectionState.waiting) {
                // show a circular progress indicator while the data is being fetched
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (votingEnabledSnapshot.hasError) {
                // show an error message if there was an error fetching the data
                return const Center(
                  child: Text('Error fetching data'),
                );
              } else {
                isVotingEnabled = votingEnabledSnapshot.data ?? false;
                return isVotingEnabled
                    ? StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collectionGroup('candidates')
                            .where('city', isEqualTo: userCity)
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final candidates = snapshot.data!.docs;
                          if (candidates.isEmpty) {
                            return Center(
                              child:
                                  Text("No Candidate Elected from $userCity"),
                            );
                          }

                          return Padding(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 1.15,
                                mainAxisSpacing: 8,
                                // crossAxisSpacing: 10,
                              ),
                              itemCount: candidates.length,
                              itemBuilder: (BuildContext context, int index) {
                                final candidate = candidates[index];
                                final candidateId = candidate.id;
                                final candidateData =
                                    candidate.data() as Map<String, dynamic>;
                                final candidateName = candidateData['fullName'];
                                // final candidateVotes = candidateData['votes'];

                                final hasVoted = userDoc.get('voted');
                                final selectedCandidateId =
                                    userDoc.get('selectedCandidateId');
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: screenHeight * 0.02),
                                      CircleAvatar(
                                        radius: screenWidth * 0.17,
                                        backgroundImage: const NetworkImage(
                                          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80",
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.02),
                                      Text(
                                        candidateName,
                                        style: TextStyle(
                                          color: Colors.indigo,
                                          fontWeight: FontWeight.w700,
                                          fontSize: screenWidth * 0.06,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.004),
                                      SizedBox(height: screenHeight * 0.03),
                                      ElevatedButton(
                                        onPressed: !hasVoted
                                            ? () async {
                                                final dobTimestamp = userDoc
                                                    .get('dob') as Timestamp;
                                                final dob = dobTimestamp
                                                    .toDate(); // Convert Timestamp to DateTime
                                                final currentDate =
                                                    DateTime.now();
                                                final age =
                                                    currentDate.year - dob.year;

                                                if (age >= 18) {
                                                  // Rest of the code for voting process remains the same...
                                                } else {
                                                  Alert().dialog(
                                                    context,
                                                    DialogType.error,
                                                    "Sorry! You Can't Vote, You are less than 18",
                                                    "Ok",
                                                    () {},
                                                    "Cancel",
                                                    null,
                                                  );
                                                }
                                              }
                                            : null,
                                        style: ButtonStyle(
                                          minimumSize: WidgetStateProperty.all(
                                            Size(screenWidth * 0.5,
                                                screenHeight * 0.06),
                                          ),
                                          shape: WidgetStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                          ),
                                          backgroundColor:
                                              selectedCandidateId ==
                                                          candidateId &&
                                                      hasVoted == true
                                                  ? WidgetStateProperty.all<
                                                      Color>(Colors.green)
                                                  : null,
                                        ),
                                        child: selectedCandidateId ==
                                                    candidateId &&
                                                hasVoted == true
                                            ? Text(
                                                'Voted',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.05,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                'Vote',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.05,
                                                  color: null,
                                                ),
                                              ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                    : const Center(child: Text("VOTING NOT STARTED YET"));
              }
            },
          ),
        );
      },
    );
  }
}
