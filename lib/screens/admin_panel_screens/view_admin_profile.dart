import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ViewAdminProfile extends StatefulWidget {
  String adminName;
  String adminEmail;
  int adminAge;
  int adminPhNo;

  ViewAdminProfile(
      {super.key,
      required this.adminName,
      required this.adminEmail,
      required this.adminAge,
      required this.adminPhNo});

  @override
  State<ViewAdminProfile> createState() => _ViewAdminProfileState();
}

class _ViewAdminProfileState extends State<ViewAdminProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Pofile"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80"),
              ),
              const SizedBox(height: 15),
              Text(
                widget.adminName,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(
                widget.adminEmail,
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
                        widget.adminAge.toString(),
                        style: const TextStyle(fontSize: 17),
                      ),
                      title: const Text(
                        "Date of Birth",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    ListTile(
                      trailing: Text(
                        "+${widget.adminPhNo}",
                        style: const TextStyle(fontSize: 17),
                      ),
                      title: const Text(
                        "Phone Number",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    const ListTile(
                      title: Text(
                        "Gender",
                        style: TextStyle(fontSize: 17),
                      ),
                      trailing: Text(
                        "Male",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    const ListTile(
                      trailing: Text(
                        "Islam",
                        style: TextStyle(fontSize: 17),
                      ),
                      title: Text(
                        "Religion",
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                    const ListTile(
                      title: Text(
                        "City",
                        style: TextStyle(fontSize: 17),
                      ),
                      trailing: Text(
                        "Islamabad",
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
                          padding: WidgetStateProperty.all(EdgeInsets.zero),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Dialog(
                                  child: Padding(
                                    padding: EdgeInsets.all(15),
                                    child: Text(
                                        "House NO 2031, Sector: I-10/1- Islamabad",
                                        style: TextStyle(fontSize: 17)),
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
