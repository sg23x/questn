import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitingToStart/playerCard.dart';
import 'package:psych/UI/waitingToStart/startTheGameButton.dart';

class WaitingToStart extends StatelessWidget {
  WaitingToStart({
    @required this.gameID,
    @required this.playerID,
  });

  final String gameID;
  final String playerID;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold();
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Game ID: $gameID",
            ),
            centerTitle: true,
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemBuilder: (context, i) {
                    return PlayerWaitingCard(
                      name: snapshot.data['players'][i]['name'],
                    );
                  },
                  shrinkWrap: true,
                  itemCount: snapshot.data['players'].length,
                ),
              ),
              playerID == snapshot.data['players'][0]['userID']
                  ? StartTheGameButton(
                      gameID: gameID,
                      playerID: playerID,
                    )
                  : SizedBox(),
            ],
          ),
        );
      },
      stream:
          Firestore.instance.collection('roomDetails').document(gameID).snapshots(),
    );
  }
}
