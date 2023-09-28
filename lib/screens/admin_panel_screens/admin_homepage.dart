import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/admin_profile.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/admin_voting_panel.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/parties_list.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/voters_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;
  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
  }

  int selectedIndex = 0;

  List<Widget> pages = [
    const AdminVotingPanel(),
    const PartiesList(),
    const VotersList(),
    const AdminProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.grey[300]!,
        animationDuration: const Duration(milliseconds: 300),
        color: Colors.indigo[600]!,
        index: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          CurvedNavigationBarItem(
            labelStyle: TextStyle(color: Colors.white),
            child: Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
            label: 'Home',
          ),
          CurvedNavigationBarItem(
            labelStyle: TextStyle(
              color: Colors.white,
            ),
            child: Icon(
              Icons.group,
              color: Colors.white,
            ),
            label: 'Political Parties',
          ),
          CurvedNavigationBarItem(
            labelStyle: TextStyle(color: Colors.white),
            child: Icon(
              Icons.list_alt_outlined,
              color: Colors.white,
            ),
            label: 'Voters List',
          ),
          CurvedNavigationBarItem(
            labelStyle: TextStyle(color: Colors.white),
            child: Icon(
              Icons.group,
              color: Colors.white,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
