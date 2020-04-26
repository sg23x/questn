import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class StartTheGameButton extends StatelessWidget {
  StartTheGameButton({
    @required this.gameID,
    @required this.playerID,
  });
  final String gameID;
  final String playerID;

  List playerNames = [];

  @override
  Widget build(BuildContext context) {
    generateRandomIndex(int len) {
      Random rnd;
      int min = 0;
      int max = len;
      rnd = new Random();
      var r = min + rnd.nextInt(max - min);
      return r;
    }

    void startGame() async {
      Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .collection('playerStatus')
          .getDocuments()
          .then(
        (snapshot) {
          for (DocumentSnapshot ds in snapshot.documents) {
            ds.reference.setData(
              {
                'isReady': true,
              },
            );
          }
        },
      );
    }

    return StreamBuilder(
      builder: (context, snap) {
        return StreamBuilder(
          builder: (context, snapshot) {
            return RaisedButton(
              child: Text(
                "Start Game",
              ),
              onPressed: () {
                startGame();

                String question = snap
                    .data
                    .documents[generateRandomIndex(
                  snap.data.documents.length,
                )]
                    .data['question']
                    .replaceAll(
                  'xyz',
                  snapshot.data.documents[generateRandomIndex(
                    snapshot.data.documents.length,
                  )]['name'],
                );

                Firestore.instance
                    .collection('roomDetails')
                    .document(gameID)
                    .updateData(
                  {
                    'currentQuestion': question,
                  },
                );
              },
            );
          },
          stream: Firestore.instance
              .collection('roomDetails')
              .document(gameID)
              .collection('users')
              .snapshots(),
        );
      },
      stream: Firestore.instance.collection('questions').snapshots(),
    );
  }
}
