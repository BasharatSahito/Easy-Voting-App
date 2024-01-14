import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/neu_textfield.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/add_candidates.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UpdateCandidates extends StatefulWidget {
  final String partyName;
  final bool isAdmin;

  const UpdateCandidates({
    required this.partyName,
    required this.isAdmin,
    Key? key,
  }) : super(key: key);

  @override
  State<UpdateCandidates> createState() => _UpdateCandidatesState();
}

class _UpdateCandidatesState extends State<UpdateCandidates> {
  String searchText = "";
  TextEditingController searchController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  //To UPDATE Candidates
  Future<void> updateCandidate(
      String candidateId, String name, String party) async {
    await FirebaseFirestore.instance
        .collection('candidates')
        .doc(candidateId)
        .update({'fullName': name, 'politicalParty': party});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Candidates - ${widget.partyName}"),
          centerTitle: true,
          automaticallyImplyLeading: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: NeuTextfield(
                child: TextFormField(
                  controller: searchController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Search by Candidate Name",
                    prefixIcon: const Icon(Icons.search),
                    border: InputBorder.none,
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            searchController.text = "";
                          });
                        },
                        child: const Icon(Icons.close)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // searchText = value.toLowerCase();
                    });
                  },
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('politicalParties')
                    .doc(widget.partyName)
                    .collection('candidates')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final candidates = snapshot.data!.docs;
                  if (candidates.isEmpty) {
                    return const Center(child: Text("No Candidates Added"));
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      final candidateName = document['fullName'];
                      final candidateGender = document['gender'];
                      final candidateCity = document['city'];
                      final candidateCategory = document['category'];
                      final leaderPic = document['leaderPicUrl'];
                      // final partySymbol = document['partySymbolUrl'];

                      if (searchController.text.isNotEmpty &&
                          !candidateName
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase())) {
                        return Container();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              alignment: Alignment.topRight,
                                              onPressed: () {
                                                Navigator.pop(context);
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                              icon: const Icon(
                                                Icons.close,
                                                size: 30,
                                              ),
                                            ),
                                          ],
                                        ),
                                        CircleAvatar(
                                          radius: 90,
                                          backgroundImage:
                                              NetworkImage(leaderPic),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          candidateName,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: "Rubik Regular",
                                          ),
                                        ),
                                        const SizedBox(height: 30),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20, left: 25, right: 25),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Political Party:",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                              Text(
                                                widget.partyName,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20, left: 25, right: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Category",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                              Text(
                                                candidateCategory,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20, left: 25, right: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "City",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                              Text(candidateCity,
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: "Rubik Regular",
                                                  ))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20, left: 25, right: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Gender",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                              Text(
                                                candidateGender,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(leaderPic)),
                            title: Text(candidateName),
                            subtitle: Text(candidateCategory),
                            trailing: widget.isAdmin
                                ? PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert),
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text(
                                                  "Delete Candidate?"),
                                              content: const Text(
                                                  "Are you sure you want to delete this candidate?"),
                                              actions: [
                                                TextButton(
                                                  child: const Text("Cancel"),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text("Delete"),
                                                  onPressed: () async {
                                                    try {
                                                      // Delete candidate data from Firestore
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'politicalParties')
                                                          .doc(widget.partyName)
                                                          .collection(
                                                              'candidates')
                                                          .where('leaderPicUrl',
                                                              isEqualTo:
                                                                  leaderPic)
                                                          .get()
                                                          .then(
                                                              (querySnapshot) {
                                                        if (querySnapshot.size >
                                                            0) {
                                                          querySnapshot.docs
                                                              // ignore: avoid_function_literals_in_foreach_calls
                                                              .forEach(
                                                                  (doc) async {
                                                            await doc.reference
                                                                .delete();
                                                          });
                                                        }
                                                      });

                                                      // Delete candidate's profile picture from Firebase Storage
                                                      final ref =
                                                          FirebaseStorage
                                                              .instance
                                                              .refFromURL(
                                                                  leaderPic);
                                                      await ref.delete();

                                                      // ignore: use_build_context_synchronously
                                                      Navigator.pop(
                                                          context); // Close the dialog
                                                    } catch (e) {
                                                      debugPrint(
                                                          'Error deleting candidate: $e');
                                                      // Show an error dialog if deletion fails
                                                      // ignore: use_build_context_synchronously
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                "Error"),
                                                            content: const Text(
                                                                "Failed to delete the candidate. Please try again."),
                                                            actions: [
                                                              TextButton(
                                                                child:
                                                                    const Text(
                                                                        "OK"),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => [
                                      const PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: widget.isAdmin
            ? FloatingActionButton(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddCandidates(partyName: widget.partyName),
                      ));
                },
                child: const Icon(Icons.add),
              )
            : null);
  }
}
