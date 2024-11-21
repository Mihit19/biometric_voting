import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class VotingPage extends StatelessWidget {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  void voteForCandidate(BuildContext context, String candidate) async {
    final votingStatusSnapshot = await _dbRef.child("voting_status").get();
    final currentUserSnapshot = await _dbRef.child("current_user").get();

    if (votingStatusSnapshot.value == "ready" && currentUserSnapshot.exists) {
      String userId = currentUserSnapshot.value as String;
      DatabaseReference voteRef = _dbRef.child("votes").child(candidate);

      final event = await voteRef.once();
      int currentVotes = (event.snapshot.value as int?) ?? 0;

      // Update the votes count
      await voteRef.set(currentVotes + 1);

      // Mark the user as having voted
      await _dbRef.child("users").child(userId).update({"voted": true});

      // Reset voting status
      await _dbRef.child("voting_status").set("false");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vote cast for $candidate by user $userId')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fingerprint verification required or already voted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cast Vote'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Candidate to Vote',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => voteForCandidate(context, 'candidateA'),
                child: Text('Vote for Candidate A'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => voteForCandidate(context, 'candidateB'),
                child: Text('Vote for Candidate B'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
