import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ViewUserProfile extends StatefulWidget {
  String cnic;
  String userName;
  String userEmail;
  int userPhNo;
  String userPic;
  String userGender;
  String userCity;
  String userState;
  String userAddress;
  String dob;
  ViewUserProfile({
    super.key,
    required this.cnic,
    required this.userName,
    required this.userEmail,
    required this.userPhNo,
    required this.userPic,
    required this.userGender,
    required this.userCity,
    required this.userState,
    required this.userAddress,
    required this.dob,
  });

  @override
  State<ViewUserProfile> createState() => _ViewUserProfileState();
}

class _ViewUserProfileState extends State<ViewUserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Pofile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.userPic),
              ),
              const SizedBox(height: 15),
              Text(
                widget.userName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(
                widget.userEmail,
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 40),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Column(
                  children: [
                    ListTile(
                      trailing: Text(
                        widget.cnic,
                        style: const TextStyle(fontSize: 17),
                      ),
                      title: const Text(
                        "CINC",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    ListTile(
                      trailing: Text(
                        "+92${widget.userPhNo}",
                        style: const TextStyle(fontSize: 17),
                      ),
                      title: const Text(
                        "Phone Number",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "Gender",
                        style: TextStyle(fontSize: 17),
                      ),
                      trailing: Text(
                        widget.userGender,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    ListTile(
                      trailing: Text(
                        widget.dob,
                        style: const TextStyle(fontSize: 17),
                      ),
                      title: const Text(
                        "Date of Birth",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "City",
                        style: TextStyle(fontSize: 17),
                      ),
                      trailing: Text(
                        widget.userCity,
                        style: const TextStyle(fontSize: 17),
                      ),
                    ),
                    ListTile(
                      trailing: Text(
                        widget.userState,
                        style: const TextStyle(fontSize: 17),
                      ),
                      title: const Text(
                        "State",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        "Address",
                        style: TextStyle(fontSize: 17),
                      ),
                      trailing: TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Text(widget.userAddress,
                                        style: const TextStyle(fontSize: 17)),
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
            ],
          ),
        ),
      ),
    );
  }
}
