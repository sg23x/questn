import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/questionCard.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/responseSelection/responseCard.dart';
import 'package:psych/UI/waitForSelections/structure.dart';
import 'package:psych/UI/widgets/customAppBar.dart';

class ResponseSelectionPage extends StatelessWidget {
  ResponseSelectionPage({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
    @required this.isAdmin,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;
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
                      isAdmin
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
            if ((event.documents
                            .where((element) => element.documentID == playerID)
                            .toList()
                            .length !=
                        1 ||
                    event.documents.length < 2) &&
                abc) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => NameInputPage(),
                  ),
                  (route) => false);
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
      child: Scaffold(
        appBar: customAppBar(
          context: context,
          gameID: gameID,
          isAdmin: isAdmin,
          playerID: playerID,
          title: 'GAME ID: $gameID',
        ),
        body: StreamBuilder(
          builder: (context, snap) {
            if (!snap.hasData) {
              return SizedBox();
            }
            return Column(
              children: <Widget>[
                StreamBuilder(
                  builder: (context, quessnap) {
                    return QuestionCard(
                      question: quessnap.data != null
                          ? quessnap.data['currentQuestion']
                          : '',
                    );
                  },
                  stream: Firestore.instance
                      .collection('roomDetails')
                      .document(gameID)
                      .snapshots(),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snap.data.documents.length,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          if (playerID != snap.data.documents[i].documentID) {
                            Firestore.instance
                                .collection('roomDetails')
                                .document(gameID)
                                .collection('users')
                                .document(playerID)
                                .updateData(
                              {
                                'selection': snap.data.documents[i].documentID,
                                'hasSelected': true,
                              },
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    WaitForSelectionsPage(
                                  gameID: gameID,
                                  playerID: playerID,
                                  gameMode: gameMode,
                                  isAdmin: isAdmin,
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
                                    "You can't choose your own answer!",
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: ResponseCard(
                          response: snap.data.documents[i]['response'],
                        ),
                      );
                    },
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
        ),
      ),
    );
  }
}
