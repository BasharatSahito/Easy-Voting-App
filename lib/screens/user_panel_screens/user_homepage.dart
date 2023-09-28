import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:easy_voting_app/screens/admin_panel_screens/parties_list.dart';
import 'package:easy_voting_app/screens/user_panel_screens/user_profile.dart';
import 'package:easy_voting_app/screens/user_panel_screens/user_voting_panel.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
  }

  int selectedIndex = 0;

  List<Widget> pages = [
    const UserVotingPanel(),
    const PartiesList(),
    const UserProfile(),
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
            labelStyle: TextStyle(color: Colors.white),
            child: Icon(
              Icons.people_sharp,
              color: Colors.white,
            ),
            label: 'Parties List',
          ),
          CurvedNavigationBarItem(
            labelStyle: TextStyle(color: Colors.white),
            child: Icon(
              Icons.perm_identity,
              color: Colors.white,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
