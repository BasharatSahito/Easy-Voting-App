import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_voting_app/components/neu_textfield.dart';
import 'package:flutter/material.dart';

class VotersList extends StatefulWidget {
  const VotersList({super.key});

  @override
  State<VotersList> createState() => _VotersListState();
}

class _VotersListState extends State<VotersList> {
  String searchText = "";
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Voting List"),
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
                  decoration: InputDecoration(
                    hintText: "Search",
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
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      final userProfiePic = document['profilePictureUrl'];
                      final userCnic = document['cnic'];
                      final userName = document['name'];
                      final userEmail = document['email'];
                      final userPhNo = document['phoneNumber'];
                      final userAge = document['dob'];
                      final userCity = document['city'];
                      final userGender = document['gender'];
                      final userAddress = document['address'];

                      //  Convert Timestamp to DateTime
                      final dobDateTime = userAge.toDate();
                      // Format the DateTime to display only day, month, and year
                      final formattedDob =
                          '${dobDateTime.day}/${dobDateTime.month}/${dobDateTime.year}';

                      if (searchController.text.isNotEmpty &&
                          !userName
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
                                              NetworkImage(userProfiePic),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          userName,
                                          style: const TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: "Rubik Regular",
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 20, left: 25, right: 25),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Cnic",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                              Text(
                                                userCnic,
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
                                                "Email",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                              Text(
                                                userEmail,
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
                                              Text(userCity,
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
                                                "Phone Number",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                              Text("+92$userPhNo",
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
                                                userGender,
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
                                              left: 25, right: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Age",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                              Text(
                                                formattedDob,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Rubik Regular",
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListTile(
                                          title: const Padding(
                                            padding: EdgeInsets.only(left: 08),
                                            child: Text(
                                              "Address",
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ),
                                          trailing: TextButton(
                                            style: ButtonStyle(
                                              padding: WidgetStateProperty.all(
                                                  EdgeInsets.zero),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Dialog(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(15),
                                                        child: Text(userAddress,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        17)),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text(
                                              "View Address",
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Card(
                            elevation: 5,
                            color: Colors.grey[300],
                            child: SizedBox(
                              height: 120,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, left: 8, bottom: 8),
                                    child: CircleAvatar(
                                      radius: 35,
                                      backgroundImage:
                                          NetworkImage(userProfiePic),
                                    ),
                                  ),
                                  VerticalDivider(
                                    thickness: 3,
                                    width: 30,
                                    color: Colors.grey[700],
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Name: $userName",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[900],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          "Cnic: $userCnic",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[900],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ));
  }
}
