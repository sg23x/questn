import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/structure.dart';
import 'package:psych/UI/waitingToStart/playerCard.dart';
import 'package:psych/UI/waitingToStart/startTheGameButton.dart';

class WaitingToStart extends StatefulWidget {
  WaitingToStart({
    @required this.gameID,
    @required this.playerID,
  });
  final String gameID;
  final String playerID;

  @override
  _WaitingToStartState createState() => _WaitingToStartState();
}

class _WaitingToStartState extends State<WaitingToStart> {
  @override
  Widget build(BuildContext context) {
    Future<bool> _onBackPressed() {
      return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      "NO",
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text(
                      "YES",
                    ),
                  ),
                ],
                content: Text(
                  "You sure you wanna leave the game?",
                ),
              );
            },
          ) ??
          false;
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: StreamBuilder(
        builder: (context, snap) {
          if (!snap.hasData) {
            return Scaffold();
          }

          if (snap.data.documents.every(
            (x) => x['isReady'] == true,
          )) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => QuestionsPage(
                      playerID: widget.playerID,
                      gameID: widget.gameID,
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
                    'Game id: ${widget.gameID}',
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
                    widget.playerID == snapshot.data.documents[0]['userID']
                        ? StartTheGameButton(
                            gameID: widget.gameID,
                            playerID: widget.playerID,
                            isPlayerPlural:
                                snap.data.documents.length > 1 ? true : false,
                          )
                        : SizedBox(),
                  ],
                ),
              );
            },
            stream: Firestore.instance
                .collection('roomDetails')
                .document(widget.gameID)
                .collection('users')
                .orderBy(
                  'timestamp',
                )
                .snapshots(),
          );
        },
        stream: Firestore.instance
            .collection('roomDetails')
            .document(widget.gameID)
            .collection('playerStatus')
            .snapshots(),
      ),
    );
  }
}
