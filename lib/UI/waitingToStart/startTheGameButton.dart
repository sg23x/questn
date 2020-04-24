import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/gameStarted/structure.dart';

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
    void startGame() async {
      await Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .get()
          .then(
        (val) {
          for (int i = 0; i < val.data['players'].length; i++) {
            playerNames.add(
              val.data['players'][i]['name'],
            );
          }
        },
      );
      Firestore.instance.collection('roomDetails').document(gameID).updateData(
        {
          'playerNames': playerNames,
        },
      );
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

    return RaisedButton(
      child: Text(
        "Start Game",
      ),
      onPressed: () {
        startGame();

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (BuildContext context) => GameStart(),
        //   ),
        // );
      },
    );
  }
}
