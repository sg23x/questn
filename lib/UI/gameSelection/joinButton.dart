import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitingToStart/structure.dart';
import 'dart:math';

class JoinGameButton extends StatelessWidget {
  JoinGameButton({
    @required this.playerName,
  });
  final String playerName;
  Widget build(BuildContext context) {
    String generateUserCode() {
      Random rnd;
      int min = 100000;
      int max = 999999;
      rnd = new Random();
      var r = min + rnd.nextInt(max - min);
      return r.toString();
    }

    final String playerID = generateUserCode();

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
                      .collection('roomDetails')
                      .document(gameID)
                      .get();

                  if (snap.exists) {
                    Firestore.instance
                        .collection('roomDetails')
                        .document(gameID)
                        .updateData(
                      {
                        'players': FieldValue.arrayUnion(
                          [
                            {
                              'userID': playerID,
                              'name': playerName,
                            },
                          ],
                        ),
                        'playerNames': FieldValue.arrayUnion(
                          [playerName],
                        ),
                      },
                    );
                    Firestore.instance
                        .collection('roomDetails')
                        .document(gameID)
                        .collection('playerStatus')
                        .document(playerID)
                        .setData(
                      {
                        'isReady': false,
                      },
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => WaitingToStart(
                          gameID: gameID,
                          playerID: playerID,
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
              height: MediaQuery.of(context).size.height * 0.12,
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
