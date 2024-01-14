import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:easy_voting_app/components/alert_box.dart';
import 'package:easy_voting_app/components/utils.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/check_results.dart';
import 'package:easy_voting_app/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:rxdart/rxdart.dart';

class UserVotingPanel extends StatefulWidget {
  const UserVotingPanel({Key? key}) : super(key: key);

  @override
  State<UserVotingPanel> createState() => _UserVotingPanelState();
}

class _UserVotingPanelState extends State<UserVotingPanel> {
  String? userCity;
  List<Map<String, dynamic>> candidateList = [];
  String v = "";
  TextEditingController otpVerifyController = TextEditingController();
  final LocalAuthentication _localAuthentication = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _fetchUserCity();
  }

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

  Future<void> _fetchUserCity() async {
    try {
      // Get the current user from Firebase Authentication
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the user's data from Firestore
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        // Get the user's city from the userSnapshot
        String? city = userSnapshot.get('city');
        setState(() {
          userCity = city;
        });

        // Fetch candidates with matching city
        if (userCity != null) {
          QuerySnapshot partySnapshot = await FirebaseFirestore.instance
              .collection('politicalParties')
              .get();

          List<Stream<QuerySnapshot>> streams = [];

          for (var partyDoc in partySnapshot.docs) {
            Stream<QuerySnapshot> candidatesStream = partyDoc.reference
                .collection('candidates')
                .where('city', isEqualTo: userCity)
                .snapshots();

            streams.add(candidatesStream);
          }

          // Combine multiple streams into one
          Stream<List<QuerySnapshot>> combinedStream =
              Rx.combineLatest<QuerySnapshot, List<QuerySnapshot>>(
            streams,
            (snapshots) => snapshots.toList(),
          );

          // Listen to the combined stream and update the candidateList accordingly
          combinedStream.listen((snapshots) {
            List<Map<String, dynamic>> candidates = [];
            for (var snapshot in snapshots) {
              candidates.addAll(snapshot.docs.map((candidate) {
                // Get the candidate's data as a Map<String, dynamic>
                Map<String, dynamic> candidateData =
                    candidate.data() as Map<String, dynamic>;
                // Add the document reference to the candidate's data
                candidateData['ref'] = candidate.reference;
                return candidateData;
              }).toList());
            }

            // Add candidates to the candidateList
            setState(() {
              candidateList = candidates;
            });
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching user city and candidates: $e');
    }
  }

  Stream<bool> _checkVotingStatus() {
    // Replace 'adminDocumentId' with the actual document ID for the admins collection
    return FirebaseFirestore.instance
        .collection('admins')
        .doc('xEsE3RjrOmPuaPJnW7Q2lCkbg4f2')
        .snapshots()
        .map((snapshot) => snapshot.get('voting') == true);
  }

  // Function to show the phone verification dialog
  Future<void> _showPhoneVerificationDialog(
    BuildContext context,
    DocumentReference candidateRef,
    String fullName,
  ) async {
    try {
      // Fetch the user's document from Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .get();

      // Get the user's date of birth (dob) from the userSnapshot
      Timestamp dobTimestamp = userSnapshot.get('dob') as Timestamp;

      // Convert the Timestamp to a DateTime object
      DateTime dobDate = dobTimestamp.toDate();

      // Calculate the user's age based on the date of birth (dob)
      DateTime currentDate = DateTime.now();
      int age = currentDate.year - dobDate.year;
      if (currentDate.month < dobDate.month ||
          (currentDate.month == dobDate.month &&
              currentDate.day < dobDate.day)) {
        age--;
      }

      // Check if the user is 18 years or older
      if (age >= 18) {
        final phNoController = user != null ? user?.phoneNumber.toString() : "";

        // ignore: use_build_context_synchronously
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Center(child: Text('Phone Verification')),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      "Your Registered Number is: $phNoController",
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white),
                      child: const Text("Send OTP"),
                      onPressed: () async {
                        await auth.verifyPhoneNumber(
                          phoneNumber: phNoController,
                          verificationCompleted: (_) {},
                          verificationFailed: (e) {
                            Utils().toastMessage(e.toString());
                          },
                          codeSent: (String verificationId, int? token) {
                            setState(() {
                              v = verificationId;
                            });
                          },
                          codeAutoRetrievalTimeout: (e) {
                            Utils().toastMessage(e.toString());
                          },
                        );
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: otpVerifyController,
                      decoration: const InputDecoration(
                        labelText: 'Enter 6 Digit Code',
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white),
                      child: const Text("Verify OTP"),
                      onPressed: () async {
                        bool otpVerified = await login();

                        if (otpVerified) {
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop(); // Close the OTP dialog
                          otpVerifyController.clear();

                          bool isBiometricSupported =
                              await _localAuthentication.canCheckBiometrics;
                          if (isBiometricSupported) {
                            bool isVerified =
                                await _localAuthentication.authenticate(
                              localizedReason: 'Verify using biometrics',
                            );

                            if (isVerified) {
                              // Call the vote function when verified
                              _castVote(candidateRef, fullName);
                            } else {
                              Utils().toastMessage('Biometric Not Verified');
                            }
                          } else {
                            Utils().toastMessage(
                                'Biometric authentication is not available');
                          }
                        } else {
                          Utils().toastMessage('OTP verification failed');
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    otpVerifyController.clear();
                  },
                ),
              ],
            );
          },
        );
      } else {
        // The user is less than 18, show an alert dialog informing the user that they can't vote
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Can't Vote"),
              content: const Text(
                  "You can't vote as you are less than 18 years old."),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      debugPrint('Error in phone verification: $e');
    }
  }

  // Function to handle vote casting
  Future<void> _castVote(
      DocumentReference candidateRef, String fullName) async {
    try {
      final currentUser = user;

      if (currentUser != null) {
        await candidateRef.update({
          'votes': FieldValue.increment(1),
        });

        // Get the candidate's reference and save it in the user's document
        DocumentSnapshot candidateSnapshot = await candidateRef.get();
        String candidateId = candidateSnapshot.id;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'voted': true,
          'selectedCandidateId': candidateId,
        });

        _showVoteSuccessDialog(fullName);
      }
    } catch (e) {
      _showVoteFailureDialog();
    }
  }

  // Function to show the vote success dialog
  Future<void> _showVoteSuccessDialog(String fullName) async {
    Alert().dialog(context, DialogType.success,
        'Vote successfully casted for $fullName', "Ok", () {}, "Cancel", null);
    // await showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: const Center(child: Text('Vote Casted Successfully')),
    //       content: Text('Vote successfully casted for $fullName'),
    //       actions: [
    //         ElevatedButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: const Text('Ok'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  // Function to show the vote failure dialog
  Future<void> _showVoteFailureDialog() async {
    Alert().dialog(context, DialogType.error,
        'Failed to cast vote. Please try again.', "Ok", () {}, "Cancel", null);
    // await showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       title: const Center(child: Text('Vote Casting Failed')),
    //       content: const Text('Failed to cast vote. Please try again.'),
    //       actions: [
    //         ElevatedButton(
    //           onPressed: () => Navigator.of(context).pop(),
    //           child: const Text('Ok'),
    //         ),
    //       ],
    //     );
    //   },
    // );
  }

  Stream<bool> _checkResultsStatus() {
    // Replace 'adminDocumentId' with the actual document ID for the admins collection
    return FirebaseFirestore.instance
        .collection('admins')
        .doc(
            'xEsE3RjrOmPuaPJnW7Q2lCkbg4f2') // Replace with your admin document ID
        .snapshots()
        .map((snapshot) => snapshot.get('results') == true);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting Panel'),
        automaticallyImplyLeading: false,
        actions: [
          StreamBuilder<bool>(
            stream: _checkResultsStatus(),
            builder: (context, snapshot) {
              bool areResultsEnabled = snapshot.data ?? false;
              return ElevatedButton(
                onPressed: areResultsEnabled
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckResults(),
                          ),
                        );
                      }
                    : null, // Disable the button if results are not enabled
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0),
                ),
                child: const Text(
                  "Check Results",
                  style: TextStyle(color: Colors.white, fontSize: 19),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<bool>(
        stream: _checkVotingStatus(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            // Show the loading indicator while fetching voting status
            return const Center(child: CircularProgressIndicator());
          }

          // Get the voting status from the snapshot
          bool isVotingOpen = snapshot.data!;

          if (!isVotingOpen) {
            // Show the "Voting Closed" message when voting is closed
            return const Center(
              child: Text('Voting Closed'),
            );
          }

          // Show the list of candidates when voting is open
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: Stream.value(
                candidateList), // Use Stream.value to provide the initial data
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                // If userCity is null, it means the user's city hasn't been fetched yet
                // or there's some other issue, so show the loading indicator
                return const Center(child: CircularProgressIndicator());
              }

              // Filter out candidates list to get only those from the user's city
              List<Map<String, dynamic>> candidatesFromUserCity = snapshot.data!
                  .where((candidate) => candidate['city'] == userCity)
                  .toList();

              if (candidatesFromUserCity.isEmpty) {
                // Check if the userCity is not null and show the message accordingly
                if (userCity != null) {
                  return Center(
                    child: Text('No candidates from $userCity'),
                  );
                } else {
                  // If userCity is null, it means the user's city hasn't been fetched yet
                  // or there's some other issue, so show the loading indicator
                  return const Center(child: CircularProgressIndicator());
                }
              }

              return ListView.builder(
                itemCount: candidatesFromUserCity.length,
                itemBuilder: (context, index) {
                  final candidateData = candidatesFromUserCity[index];
                  final leaderDp = candidateData['leaderPicUrl'] as String;
                  final fullName = candidateData['fullName'] as String;
                  final category = candidateData['category'] as String;
                  final city = candidateData['city'] as String;
                  final party = candidateData['politicalParty'] as String;
                  final candidateRef =
                      candidateData['ref'] as DocumentReference;

                  return StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user?.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show a loading indicator while fetching the user's document
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.indigo,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            width: double.infinity,
                            height: 250,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        );
                      }

                      // Get the value of the "voted" field from the user document
                      bool hasVoted = snapshot.data?.get('voted') ?? false;
                      final selectedCandidateId =
                          snapshot.data?.get('selectedCandidateId');
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          width: double.infinity,
                          height: 400,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 65,
                                backgroundImage: NetworkImage(leaderDp),
                              ),
                              const SizedBox(height: 11),
                              Text(
                                fullName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Political Party",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          party,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Area",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          category,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "City",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          city,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 25),
                              ElevatedButton(
                                onPressed: hasVoted
                                    ? null
                                    : () {
                                        Alert().dialog(
                                            context,
                                            DialogType.warning,
                                            'Are You Sure',
                                            "Yes", () {
                                          _showPhoneVerificationDialog(
                                              context, candidateRef, fullName);
                                        }, "No", () {});
                                      },
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(
                                    Size(
                                        screenWidth * 0.4, screenHeight * 0.06),
                                  ),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  backgroundColor:
                                      selectedCandidateId == candidateRef.id &&
                                              hasVoted == true
                                          ? MaterialStateProperty.all<Color>(
                                              Colors.green)
                                          : MaterialStateProperty.all<Color>(
                                              Colors.grey),
                                ),
                                child: selectedCandidateId == candidateRef.id &&
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
                                          color: Colors.white,
                                        ),
                                      ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
