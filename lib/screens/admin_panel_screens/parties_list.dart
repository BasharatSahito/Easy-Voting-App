import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/neu_textfield.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/create_new_party.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/view_candidates.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class PartiesList extends StatefulWidget {
  const PartiesList({super.key});

  @override
  State<PartiesList> createState() => _PartiesListState();
}

class _PartiesListState extends State<PartiesList> {
  String searchText = "";
  TextEditingController searchController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getRole(_fireauth.currentUser!.uid);
  }

  final _firestore = FirebaseFirestore.instance;
  final _fireauth = FirebaseAuth.instance;

  bool _isAdmin = false; // A flag to determine if the user is an admin

  Future<void> getRole(String uid) async {
    String role = "";
    await _firestore.collection('admins').doc(uid).get().then((doc) {
      if (doc.exists) {
        role = doc.data()!['role'];
      }
    });
    if (role == "admin") {
      setState(() {
        _isAdmin = true;
      });
    } else {
      setState(() {
        _isAdmin = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Political Parties"),
          centerTitle: true,
          automaticallyImplyLeading: false,
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
                    hintText: "Search by Party Name",
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
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final partyDocs = snapshot.data!.docs;

                  if (partyDocs.isEmpty) {
                    // If there are no parties in the collection, show the "No parties found" message
                    return const Center(child: Text('No parties found'));
                  }
                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      final partyName = document['partyName'];
                      final partySymbolUrl = document['partySymbolUrl'];

                      if (searchController.text.isNotEmpty &&
                          !partyName
                              .toLowerCase()
                              .contains(searchController.text.toLowerCase())) {
                        return Container();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateCandidates(
                                  partyName: partyName,
                                  isAdmin: _isAdmin,
                                ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(partySymbolUrl),
                            ),
                            title: Text(partyName),
                            subtitle: const Text("Political Party"),
                            trailing: _isAdmin
                                ? PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text("Delete Party?"),
                                              content: const Text(
                                                  "Are you sure you want to delete this party?"),
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
                                                      // Delete the entire party and its candidates
                                                      final partyRef =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'politicalParties')
                                                              .doc(partyName);

                                                      // Fetch all candidates under the party and delete them
                                                      final candidatesSnapshot =
                                                          await partyRef
                                                              .collection(
                                                                  'candidates')
                                                              .get();
                                                      for (final candidateDoc
                                                          in candidatesSnapshot
                                                              .docs) {
                                                        // Delete candidate documents
                                                        await candidateDoc
                                                            .reference
                                                            .delete();

                                                        // Delete candidate's profile picture from Firebase Storage
                                                        final leaderPicUrl =
                                                            candidateDoc[
                                                                'leaderPicUrl'];
                                                        final ref =
                                                            FirebaseStorage
                                                                .instance
                                                                .refFromURL(
                                                                    leaderPicUrl);
                                                        await ref.delete();
                                                      }

                                                      // Delete the party document
                                                      await partyRef.delete();

                                                      // Delete the partySymbolUrl from Firebase Storage
                                                      final ref = FirebaseStorage
                                                          .instance
                                                          .refFromURL(
                                                              partySymbolUrl);
                                                      await ref.delete();

                                                      // ignore: use_build_context_synchronously
                                                      Navigator.pop(
                                                          context); // Close the dialog
                                                    } catch (e) {
                                                      debugPrint(
                                                          'Error deleting party: $e');
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
                                                                "Failed to delete the party. Please try again."),
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
        floatingActionButton: _isAdmin
            ? FloatingActionButton(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                // Show FloatingActionButton if the user is an admin
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateNewParty(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              )
            : null // Set the FloatingActionButton to null if the user is not an admin
        );
  }
}
