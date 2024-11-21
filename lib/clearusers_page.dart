import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ClearUsersPage extends StatelessWidget {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref(); // Firebase reference

  void clearAllUsers(BuildContext context) async {
    try {
      // Clear all users from Firebase
      await _dbRef.child("users").remove();
      await _dbRef.child("current_user").remove();

      // Notify the Arduino to clear its database (via Firebase or serial communication)
      await _dbRef.child("arduino_command").set("clear_all_users");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All users cleared successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear users: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clear All Users'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => clearAllUsers(context),
          child: Text('Clear All Users'),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            textStyle: TextStyle(fontSize: 18),
            backgroundColor: Colors.red,
          ),
        ),
      ),
    );
  }
}
