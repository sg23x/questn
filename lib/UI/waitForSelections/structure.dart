import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitForReady/structure.dart';
import 'package:psych/UI/waitForSubmissions/waitingForSubmissionPlayerCard.dart';

class WaitForSelectionsPage extends StatelessWidget {
  WaitForSelectionsPage({
    @required this.gameID,
    @required this.playerID,
  });
  final String playerID;
  final String gameID;
  bool abc = true;
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
      child: Scaffold(
        appBar: AppBar(),
        body: StreamBuilder(
          builder: (context, snap) {
            if (!snap.hasData) {
              return SizedBox();
            }

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: snap.data.documents.length,
                    itemBuilder: (context, i) {
                      return StreamBuilder(
                        builder: (context, usersnap) {
                          if (!usersnap.hasData) {
                            return SizedBox();
                          }
                          if (snap.data.documents
                                  .where((x) => x['hasSelected'] == true)
                                  .toList()
                                  .length ==
                              usersnap.data.documents.length) {
                            if (abc) {
                              Firestore.instance
                                  .collection('roomDetails')
                                  .document(gameID)
                                  .collection('users')
                                  .document(playerID)
                                  .updateData(
                                {
                                  'score': FieldValue.increment(
                                    snap.data.documents
                                        .where(
                                            (g) => g['selection'] == playerID)
                                        .toList()
                                        .length,
                                  ),
                                },
                              );
                              abc = !abc;
                            }

                            WidgetsBinding.instance.addPostFrameCallback(
                              (_) {
                                Firestore.instance
                                    .collection('roomDetails')
                                    .document(gameID)
                                    .collection('users')
                                    .orderBy('timestamp')
                                    .getDocuments()
                                    .then(
                                  (onValue) {
                                    if (onValue.documents[0].documentID ==
                                        playerID) {
                                      Firestore.instance
                                          .collection('roomDetails')
                                          .document(gameID)
                                          .updateData(
                                        {'currentQuestion': ''},
                                      );
                                    }
                                  },
                                );

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        WaitForReady(
                                      gameID: gameID,
                                      playerID: playerID,
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          return WaitingForSubmissionPlayerCard(
                            name: usersnap.data.documents
                                .where((n) =>
                                    n['userID'] ==
                                    snap.data.documents[i].documentID)
                                .toList()[0]['name'],
                            hasSubmitted: snap.data.documents
                                        .where((no) =>
                                            no.documentID ==
                                            usersnap.data.documents[i]
                                                ['userID'])
                                        .toList()
                                        .length !=
                                    0
                                ? snap.data.documents
                                    .where((no) =>
                                        no.documentID ==
                                        usersnap.data.documents[i]['userID'])
                                    .toList()[0]
                                    .data['hasSelected']
                                : false,
                          );
                        },
                        stream: Firestore.instance
                            .collection('roomDetails')
                            .document(gameID)
                            .collection('users')
                            .snapshots(),
                      );
                    },
                    shrinkWrap: true,
                  ),
                ),
              ],
            );
          },
          stream: Firestore.instance
              .collection('roomDetails')
              .document(gameID)
              .collection('selections')
              .snapshots(),
        ),
      ),
    );
  }
}
