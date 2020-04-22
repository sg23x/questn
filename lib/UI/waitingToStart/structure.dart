import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WaitingToStart extends StatelessWidget {
  WaitingToStart({
    @required this.playerName,
    @required this.gameID,
  });
  final String playerName;
  final String gameID;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold();
        }
        return Scaffold(
            body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'game id : $gameID',
                ),
                Text(
                  'name : $playerName', // listview for player names to be added
                ),
              ],
            ),
          ],
        ));
      },
      stream:
          Firestore.instance.collection('test').document(gameID).snapshots(),
    );
  }
}
