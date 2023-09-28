import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/components/main_logo.dart';
import 'package:easy_voting_app/components/round_button.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/check_results.dart';
import 'package:flutter/material.dart';

class AdminVotingPanel extends StatefulWidget {
  const AdminVotingPanel({super.key});

  @override
  State<AdminVotingPanel> createState() => _AdminVotingPanelState();
}

class _AdminVotingPanelState extends State<AdminVotingPanel> {
  late Stream<bool> _votingEnabledStream;
  late Stream<bool>
      _resultsEnabledStream; // Added stream for "Allow Users To See Result"
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _votingEnabledStream = checkAdminVoting();
    _resultsEnabledStream =
        checkAdminResults(); // Initialize the stream for "Allow Users To See Result"
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

  Stream<bool> checkAdminResults() {
    return _firestore.collection('admins').snapshots().map((querySnapshot) {
      bool areResultsEnabled = false;
      for (var doc in querySnapshot.docs) {
        areResultsEnabled = doc.get("results");
      }
      return areResultsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Voting Panel"),
        automaticallyImplyLeading: false,
        actions: [
          ElevatedButton(
            onPressed: () {
              Alert().dialog(context, DialogType.warning,
                  'Are u Sure you want to All the Voting Data', "Ok", () async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .get()
                    .then((querySnapshot) {
                  // Update each user document with voted set to false and selectedCandidateId set to null
                  // ignore: avoid_function_literals_in_foreach_calls
                  querySnapshot.docs.forEach((doc) async {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(doc.id)
                        .update({
                      'voted': false,
                      'selectedCandidateId': null,
                    });
                  });
                });

                // Reset votes count for all candidates in the candidates subcollection of each political party
                await FirebaseFirestore.instance
                    .collection('politicalParties')
                    .get()
                    .then((querySnapshot) {
                  // ignore: avoid_function_literals_in_foreach_calls
                  querySnapshot.docs.forEach((partyDoc) async {
                    await partyDoc.reference
                        .collection('candidates')
                        .get()
                        .then((candidatesSnapshot) {
                      // ignore: avoid_function_literals_in_foreach_calls
                      candidatesSnapshot.docs.forEach((candidateDoc) async {
                        // Update the votes count to 0 for each candidate
                        await candidateDoc.reference.update({
                          'votes': 0,
                        });
                      });
                    });
                  });
                });

                // ignore: use_build_context_synchronously
                Alert().dialog(
                    context,
                    DialogType.success,
                    'Voting Data Reseted Successfully ',
                    "Ok",
                    () {},
                    "Cancel",
                    null);
              }, "Cancel", () {});
              // Reset voting status for all users
            },
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(0),
            ),
            child: const Text(
              "Reset Voting",
              style: TextStyle(color: Colors.white, fontSize: 19),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<bool>(
          stream: _votingEnabledStream,
          builder: (context, AsyncSnapshot<bool> votingSnapshot) {
            if (votingSnapshot.connectionState == ConnectionState.waiting) {
              // show a circular progress indicator while the data is being fetched
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (votingSnapshot.hasError) {
              // show an error message if there was an error fetching the data
              return const Center(
                child: Text('Error fetching voting data'),
              );
            } else {
              bool isVotingEnabled = votingSnapshot.data ?? false;
              return StreamBuilder<bool>(
                stream: _resultsEnabledStream,
                builder: (context, AsyncSnapshot<bool> resultsSnapshot) {
                  if (resultsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    // show a circular progress indicator while the data is being fetched
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (resultsSnapshot.hasError) {
                    // show an error message if there was an error fetching the data
                    return const Center(
                      child: Text('Error fetching results data'),
                    );
                  } else {
                    bool areResultsEnabled = resultsSnapshot.data ?? false;
                    return Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 100, vertical: 50),
                          child: MainLogo(whiteLogo: false),
                        ),
                        const SizedBox(height: 81),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Enable/Disable Voting",
                              style: TextStyle(fontSize: 21),
                            ),
                            Center(
                              child: Switch(
                                value: isVotingEnabled,
                                onChanged: (bool value) async {
                                  await FirebaseFirestore.instance
                                      .collection("admins")
                                      .get()
                                      .then((querySnapshot) {
                                    // ignore: avoid_function_literals_in_foreach_calls
                                    querySnapshot.docs.forEach((doc) async {
                                      value
                                          ? await FirebaseFirestore.instance
                                              .collection('admins')
                                              .doc(doc.id)
                                              .update({
                                              'voting': true,
                                            })
                                          : await FirebaseFirestore.instance
                                              .collection('admins')
                                              .doc(doc.id)
                                              .update({
                                              'voting': false,
                                            });
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Allow Users To See Result", // Text for the second switch
                              style: TextStyle(fontSize: 21),
                            ),
                            Center(
                              child: Switch(
                                value: areResultsEnabled,
                                onChanged: (bool value) async {
                                  await FirebaseFirestore.instance
                                      .collection("admins")
                                      .get()
                                      .then((querySnapshot) {
                                    // ignore: avoid_function_literals_in_foreach_calls
                                    querySnapshot.docs.forEach((doc) async {
                                      value
                                          ? await FirebaseFirestore.instance
                                              .collection('admins')
                                              .doc(doc.id)
                                              .update({
                                              'results': true,
                                            })
                                          : await FirebaseFirestore.instance
                                              .collection('admins')
                                              .doc(doc.id)
                                              .update({
                                              'results': false,
                                            });
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          child: RoundButton(
                              btnTitle: "Voting Results",
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const CheckResults(),
                                  ),
                                );
                              }),
                        ),
                      ],
                    );
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
