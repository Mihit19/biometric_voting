import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MainPage extends StatelessWidget {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('votes');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voting Results'),
      ),
      body: Center(
        child: StreamBuilder(
          stream: _dbRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData && !snapshot.hasError && snapshot.data!.snapshot.value != null) {
              Map votes = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
              int candidateAVotes = votes['candidateA'] ?? 0;
              int candidateBVotes = votes['candidateB'] ?? 0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Voting Results:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text('Candidate A: $candidateAVotes votes'),
                  Text('Candidate B: $candidateBVotes votes'),
                ],
              );
            } else {
              return Center(child: Text("No voting data available."));
            }
          },
        ),
      ),
    );
  }
}
