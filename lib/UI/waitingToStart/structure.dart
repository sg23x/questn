import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitingToStart/playerCard.dart';

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
                      name: snapshot.data['players'][i],
                    );
                  },
                  shrinkWrap: true,
                  itemCount: snapshot.data['players'].length,
                ),
              ),
              RaisedButton(
                child: Text(
                  "Start Game",
                ),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
      stream:
          Firestore.instance.collection('test').document(gameID).snapshots(),
    );
  }
}
