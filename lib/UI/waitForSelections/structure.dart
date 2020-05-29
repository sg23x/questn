import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/waitForReady/structure.dart';
import 'package:psych/UI/waitForSubmissions/waitingForSubmissionPlayerCard.dart';
import 'package:psych/UI/widgets/customAppBar.dart';

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
            if (event.documents
                        .where((element) => element.documentID == playerID)
                        .toList()
                        .length !=
                    1 ||
                event.documents.length < 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => NameInputPage(),
                ),
              );
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
      child: Scaffold(
        appBar: customAppBar(
          gameID,
          playerID,
          context,
          '',
        ),
        body: StreamBuilder(
          builder: (context, snap) {
            if (!snap.hasData) {
              return SizedBox();
            }

            return StreamBuilder(
              builder: (context, usersnap) {
                if (!usersnap.hasData) {
                  return SizedBox();
                }
                List _users = [];
                for (int index = 0;
                    index < usersnap.data.documents.length;
                    index++) {
                  _users.add(
                    usersnap.data.documents[index]['userID'],
                  );
                }

                if (snap.data.documents
                            .where((x) => x['hasSelected'] == true)
                            .toList()
                            .length ==
                        usersnap.data.documents.length &&
                    _users.contains(
                      playerID,
                    )) {
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
                              .where((g) => g['selection'] == playerID)
                              .toList()
                              .length,
                        ),
                      },
                    );
                    abc = !abc;
                  }

                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => WaitForReady(
                            gameID: gameID,
                            playerID: playerID,
                          ),
                        ),
                      );
                    },
                  );
                }

                return Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount: snap.data.documents.length,
                        itemBuilder: (context, i) {
                          return WaitingForSubmissionPlayerCard(
                              //TODO: causing error when other player leaves
                              animationIndex: i,
                              name: snap.data.documents.length != 0
                                  ? usersnap.data.documents
                                      .where((n) =>
                                          n['userID'] ==
                                          snap.data.documents[i].documentID)
                                      .toList()[0]['name']
                                  : '',
                              // name: 'Soumya',
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
                                  : false

                              // hasSubmitted: false,
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
                  .collection('users')
                  .snapshots(),
            );
          },
          stream: Firestore.instance
              .collection('roomDetails')
              .document(gameID)
              .collection('users')
              .snapshots(),
        ),
      ),
    );
  }
}
