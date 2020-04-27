import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/questionsPage/structure.dart';
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
      builder: (context, snap) {
        if (!snap.hasData) {
          return Scaffold();
        }
        List playerStatusList = [];
        for (int j = 0; j < snap.data.documents.length; j++) {
          playerStatusList.add(
            snap.data.documents[j].data['isReady'],
          );
        }
        if (playerStatusList.every((test) => test == true)) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) async {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => QuestionsPage(
                    playerID: playerID,
                    gameID: gameID,
                  ),
                ),
              );
            },
          );
        }
        return StreamBuilder(
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Scaffold();
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'Game id: $gameID',
                ),
                centerTitle: true,
              ),
              body: Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, i) {
                        return PlayerWaitingCard(
                          name: snapshot.data.documents[i]['name'],
                        );
                      },
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                    ),
                  ),
                  playerID == snapshot.data.documents[0]['userID']
                      ? StartTheGameButton(
                          gameID: gameID,
                          playerID: playerID,
                        )
                      : SizedBox(),
                ],
              ),
            );
          },
          stream: Firestore.instance
              .collection('roomDetails')
              .document(gameID)
              .collection('users')
              .snapshots(),
        );
      },
      stream: Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .collection('playerStatus')
          .snapshots(),
    );
  }
}
