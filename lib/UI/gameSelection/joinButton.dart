import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitingToStart/structure.dart';

class JoinGameButton extends StatelessWidget {
  JoinGameButton({
    @required this.playerName,
  });
  final String playerName;
  Widget build(BuildContext context) {
    void joinGame() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String gameID;
          return AlertDialog(
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  final snap = await Firestore.instance
                      .collection('test')
                      .document(gameID)
                      .get();
                  if (snap.exists) {
                    Firestore.instance
                        .collection('test')
                        .document(gameID)
                        .updateData(
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
                },
                child: Text(
                  "Go!",
                ),
              )
            ],
            content: Container(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Column(
                children: <Widget>[
                  Text(
                    "Enter Game ID",
                  ),
                  TextField(
                    keyboardType: TextInputType.numberWithOptions(),
                    onChanged: (val) {
                      gameID = val;
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return RaisedButton(
      child: Text(
        "Join Game",
      ),
      onPressed: () {
        joinGame();
      },
    );
  }
}
