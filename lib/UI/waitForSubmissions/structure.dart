import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/responseSelection/structure.dart';
import 'package:psych/UI/waitForSubmissions/waitingForSubmissionPlayerCard.dart';
import 'package:psych/UI/widgets/customAppBar.dart';

class WaitForSubmissions extends StatelessWidget {
  WaitForSubmissions({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  bool abc = true;
  @override
  Widget build(BuildContext context) {
    void deletePlayer(String id) async {
      await Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .collection('users')
          .document(id)
          .delete();
    }

    Future<bool> _onBackPressed() {
      return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      "NO",
                      style: TextStyle(
                        fontFamily: 'Indie-Flower',
                        fontWeight: FontWeight.w900,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Firestore.instance
                          .collection('roomDetails')
                          .document(gameID)
                          .snapshots()
                          .listen(
                        (event) {
                          event.data['admin'] == playerID
                              ? Firestore.instance
                                  .collection('roomDetails')
                                  .document(gameID)
                                  .collection('users')
                                  .getDocuments()
                                  .then(
                                  (snapshot) {
                                    for (DocumentSnapshot ds
                                        in snapshot.documents) {
                                      ds.reference.delete();
                                    }
                                  },
                                )
                              : deletePlayer(playerID);
                        },
                      );
                      deletePlayer(playerID);
                    },
                    child: Text(
                      "YES",
                      style: TextStyle(
                        fontFamily: 'Indie-Flower',
                        fontWeight: FontWeight.w900,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ],
                content: Text(
                  "You sure you wanna leave the game?",
                  style: TextStyle(
                    fontFamily: 'Indie-Flower',
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
              );
            },
          ) ??
          false;
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        Firestore.instance
            .collection('roomDetails')
            .document(gameID)
            .collection('users')
            .reference()
            .snapshots()
            .listen(
          (event) {
            if ((event.documents
                            .where((element) => element.documentID == playerID)
                            .toList()
                            .length !=
                        1 ||
                    event.documents.length < 2) &&
                abc) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => NameInputPage(),
                ),
              );
              abc = !abc;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    contentTextStyle: TextStyle(
                      fontFamily: 'Indie-Flower',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height * 0.025,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        12,
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(
                            fontFamily: 'Indie-Flower',
                            color: Colors.pink,
                            fontWeight: FontWeight.w900,
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                          ),
                        ),
                      )
                    ],
                    content: Text(
                      "The game has ended!",
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: StreamBuilder(
        builder: (context, snap) {
          if (!snap.hasData) {
            return Scaffold();
          }

          List _users = [];
          for (int index = 0; index < snap.data.documents.length; index++) {
            _users.add(
              snap.data.documents[index]['userID'],
            );
          }
          if (snap.data.documents
                      .where((x) => x['hasSubmitted'] == true)
                      .toList()
                      .length ==
                  snap.data.documents.length &&
              _users.contains(
                playerID,
              )) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ResponseSelectionPage(
                      playerID: playerID,
                      gameID: gameID,
                      gameMode: gameMode,
                    ),
                  ),
                );
              },
            );
          }

          return Scaffold(
            appBar: customAppBar(
              gameID,
              playerID,
              context,
              '',
            ),
            body: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.0075,
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, i) {
                      return WaitingForSubmissionPlayerCard(
                        animationIndex: i,
                        name: snap.data.documents[i]['name'],
                        hasSubmitted: snap.data.documents
                                    .where(
                                      (no) =>
                                          no.documentID ==
                                          snap.data.documents[i]['userID'],
                                    )
                                    .toList()
                                    .length !=
                                0
                            ? snap.data.documents
                                .where(
                                  (no) =>
                                      no.documentID ==
                                      snap.data.documents[i]['userID'],
                                )
                                .toList()[0]
                                .data['hasSubmitted']
                            : false,
                      );
                    },
                    shrinkWrap: true,
                    itemCount: snap.data.documents.length,
                  ),
                ),
              ],
            ),
          );
        },
        stream: Firestore.instance
            .collection('roomDetails')
            .document(gameID)
            .collection('users')
            .snapshots(),
      ),
    );
  }
}
