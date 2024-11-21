import 'package:biometric_voting_machine/voting_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'clearusers_page.dart';
import 'main_page.dart';
import 'register_page.dart';

class HomePage extends StatelessWidget {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(); // Firebase reference

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Biometric Voting System'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterPage()),
                );
              },
              child: Text('Register Voter'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Set voting_status to "verify" in Firebase
                await _dbRef.child("voting_status").set("true");

                // Navigate to the VotingPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VotingPage()),
                );
              },
              child: Text('Cast Vote'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              },
              child: Text('View Voting Results'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Navigate to the ClearUserPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClearUsersPage()),
                );
              },
              child: Text('Clear Users'),
            ),
          ],
        ),
      ),
    );
  }
}
