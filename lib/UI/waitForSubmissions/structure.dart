import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/responseSelection/structure.dart';
import 'package:psych/UI/waitForSubmissions/waitingForSubmissionPlayerCard.dart';

class WaitForSubmissions extends StatelessWidget {
  WaitForSubmissions({@required this.gameID, @required this.playerID});
  final String gameID;
  final String playerID;
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => NameInputPage(),
                        ),
                      );
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
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Scaffold();
            }
            return StreamBuilder(
              builder: (context, snap) {
                if (!snap.hasData) {
                  return Scaffold();
                }

                if (snap.data.documents
                        .where((x) => x['hasSubmitted'] == true)
                        .toList()
                        .length ==
                    snapshot.data.documents.length) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) async {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ResponseSelectionPage(
                            playerID: playerID,
                            gameID: gameID,
                          ),
                        ),
                      );
                    },
                  );
                }

                return Scaffold(
                  appBar: AppBar(),
                  body: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemBuilder: (context, i) {
                            return WaitingForSubmissionPlayerCard(
                              name: snapshot.data.documents[i]['name'],

                              hasSubmitted: snap.data.documents
                                          .where(
                                            (no) =>
                                                no.documentID ==
                                                snapshot.data.documents[i]
                                                    ['userID'],
                                          )
                                          .toList()
                                          .length !=
                                      0
                                  ? snap.data.documents
                                      .where(
                                        (no) =>
                                            no.documentID ==
                                            snapshot.data.documents[i]
                                                ['userID'],
                                      )
                                      .toList()[0]
                                      .data['hasSubmitted']
                                  : false,
                              // hasSubmitted: true,
                            );
                          },
                          shrinkWrap: true,
                          itemCount: snapshot.data.documents.length,
                        ),
                      ),
                    ],
                  ),
                );
              },
              stream: Firestore.instance
                  .collection('roomDetails')
                  .document(gameID)
                  .collection('responses')
                  .snapshots(),
            );
          },
          stream: Firestore.instance
              .collection('roomDetails')
              .document(gameID)
              .collection('users')
              .snapshots()),
    );
  }
}
