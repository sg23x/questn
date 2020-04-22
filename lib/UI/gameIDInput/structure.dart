import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitingToStart/structure.dart';

class GameIDInput extends StatelessWidget {
  GameIDInput({
    @required this.playerName,
  });
  final String playerName;
  Widget build(BuildContext context) {
    String gameID;

    void searchForGameID() async {
      final snap =
          await Firestore.instance.collection('test').document(gameID).get();
      if (snap.exists) {
        Firestore.instance.collection('test').document(gameID).updateData(
          {
            'players': FieldValue.arrayUnion(
              [playerName],
            ),
          },
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => WaitingToStart(
              playerName: playerName,
              gameID: gameID,
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "OK",
                  ),
                )
              ],
              content: Text(
                "Sorry, No such game found",
              ),
            );
          },
        );
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Enter game ID",
          ),
          TextField(
            onChanged: (val) {
              gameID = val;
            },
          ),
          RaisedButton(
            child: Text(
              "Go!",
            ),
            onPressed: () {
              gameID != null ? searchForGameID() : null;
            },
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
