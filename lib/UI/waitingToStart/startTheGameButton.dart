import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/gameStarted/structure.dart';

class StartTheGameButton extends StatelessWidget {
  StartTheGameButton({
    @required this.gameID,
  });
  final String gameID;
  List playerNames = [];
  @override
  Widget build(BuildContext context) {
    void fetchPlayerNames() async {
      await Firestore.instance.collection('roomDetails').document(gameID).get().then(
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
    }

    return RaisedButton(
      child: Text(
        "Start Game",
      ),
      onPressed: () {
        fetchPlayerNames();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => GameStart(),
          ),
        );
      },
    );
  }
}
