import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref('users');

  void registerVoter(BuildContext context) async {
    String name = nameController.text.trim();
    String userId = idController.text.trim();

    if (userId.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both name and user ID')),
      );
      return;
    }

    try {
      int id = int.parse(userId); // Ensure ID is a number
      DataSnapshot snapshot = await dbRef.child(userId).get();

      if (snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User ID already exists! Choose another.')),
        );
      } else {
        // Set up the registration request in Firebase
        await FirebaseDatabase.instance.ref('users').child('next_user_id').set(userId);
        await FirebaseDatabase.instance.ref('users').child('next_user_name').set(name);
        await FirebaseDatabase.instance.ref('users').child('register').set("true");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration request sent!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid number for User ID.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Voter'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Enter Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: idController,
                decoration: InputDecoration(labelText: 'Enter User ID'),
                keyboardType: TextInputType.number, // Make keyboard numeric
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => registerVoter(context),
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
