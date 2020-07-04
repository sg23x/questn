import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/constants.dart';
import 'package:psych/UI/services/backPressCall.dart';
import 'package:psych/UI/services/changeNavigationState.dart';
import 'package:psych/UI/services/checkForGameEnd.dart';
import 'package:psych/UI/services/checkForNavigation.dart';
import 'package:psych/UI/services/listenForGameResult.dart';
import 'dart:math';
import 'package:psych/UI/widgets/customAppBar.dart';
import 'package:psych/UI/widgets/playerScoreCard.dart';
import 'package:psych/UI/widgets/resultResponseCard.dart';

class WaitForReady extends StatelessWidget {
  WaitForReady({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
    @required this.isAdmin,
    @required this.quesCount,
    @required this.avatarList,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  final List avatarList;

  bool abc = true;

  generateRandomIndex(int len) {
    Random rnd;
    int min = 0;
    int max = len;
    rnd = new Random();
    var r = min + rnd.nextInt(max - min);
    return r;
  }

  String quesIndex() {
    return (generateRandomIndex(quesCount) + 1).toString();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        checkForGameEnd(
          context: context,
          gameID: gameID,
          playerID: playerID,
        );
        checkForNavigation(
          quesCount: quesCount,
          context: context,
          gameID: gameID,
          playerID: playerID,
          gameMode: gameMode,
          isAdmin: isAdmin,
          currentPage: 'WaitForReady',
          avatarList: avatarList,
        );
        changeNavigationStateToTrue(
            gameID: gameID, field: 'isReady', playerField: 'isReady');

        Firestore.instance
            .collection('rooms')
            .document(gameID)
            .collection('users')
            .document(playerID)
            .get()
            .then(
              (value) => listenForGameResult(
                context: context,
                gameID: gameID,
                name: value.data['name'],
              ),
            );
      },
    );

    return WillPopScope(
      onWillPop: () => onBackPressed(
        context: context,
        gameID: gameID,
        isAdmin: isAdmin,
        playerID: playerID,
      ),
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('rooms')
            .document(gameID)
            .collection('users')
            .snapshots(),
        builder: (context, snappp) {
          if (!snappp.hasData) {
            return SizedBox();
          }
          return Scaffold(
            appBar: customAppBar(
              context: context,
              gameID: gameID,
              isAdmin: isAdmin,
              playerID: playerID,
              title: 'GAME ID: $gameID',
            ),
            body: ListView(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Players who chose your answer:",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  itemBuilder: (context, i) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          snappp.data.documents
                              .where((x) => x['selection'] == playerID)
                              .toList()[i]['name'],
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    );
                  },
                  itemCount: snappp.data.documents
                      .where(
                        (x) => x['selection'] == playerID,
                      )
                      .toList()
                      .length,
                  shrinkWrap: true,
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "RESPONSES:",
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return ResultResponseCard(
                      response: snappp.data.documents[i]['response'],
                      timesSelected: snappp.data.documents
                          .where(
                            (x) =>
                                x['selection'] ==
                                snappp.data.documents[i].documentID,
                          )
                          .toList()
                          .length
                          .toString(),
                    );
                  },
                  shrinkWrap: true,
                  itemCount: snappp.data.documents.length,
                ),
                Row(
                  children: <Widget>[
                    Text(
                      "SCORE:",
                      style: TextStyle(
                        fontSize: 30,
                      ),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, ind) {
                    return PlayerScoreCard(
                      name: snappp.data.documents[ind]['name'],
                      score: snappp.data.documents[ind]['score'].toString(),
                      isReady: snappp.data.documents[ind]['isReady'],
                      scoreAdded: snappp.data.documents
                          .where(
                            (x) =>
                                x['selection'] ==
                                snappp.data.documents[ind].documentID,
                          )
                          .toList()
                          .length
                          .toString(),
                    );
                  },
                  itemCount: snappp.data.documents.length,
                  shrinkWrap: true,
                ),
                Container(
                  width: MediaQuery.of(context).size.height * 0.4,
                  margin: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Row(
                    children: [
                      RaisedButton(
                        color: Colors.red,
                        onPressed: () async {
                          isAdmin ? fetchQues(snappp) : null;

                          Firestore.instance
                              .collection('rooms')
                              .document(gameID)
                              .collection('users')
                              .document(playerID)
                              .updateData(
                            {
                              'hasSelected': false,
                              'hasSubmitted': false,
                            },
                          );

                          changeReadyStateToTrue();
                        },
                        child: Text(
                          'ready',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      isAdmin
                          ? RaisedButton(
                              onPressed: () {
                                showDialog(
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
                                              fontFamily: 'Gotham-Book',
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                        FlatButton(
                                          onPressed: () async {
                                            Firestore.instance
                                                .collection('rooms')
                                                .document(gameID)
                                                .updateData(
                                                    {'isGameEnded': true});
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text(
                                            "YES",
                                            style: TextStyle(
                                              fontFamily: 'Gotham-Book',
                                              fontWeight: FontWeight.w900,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              color: secondaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                      content: Text(
                                        "Are you sure you want to end the game?",
                                        style: TextStyle(
                                          fontFamily: 'Gotham-Book',
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              color: Colors.green,
                              child: Text('End game'),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void changeReadyStateToTrue() {
    Firestore.instance
        .collection('rooms')
        .document(gameID)
        .collection('users')
        .document(playerID)
        .updateData(
      {
        'isReady': true,
      },
    );
  }

  void fetchQues(snappp) {
    List getIndexes(int len, int n) {
      if (n == 1) {
        return [
          generateRandomIndex(
            len,
          ),
        ];
      } else if (n == 2) {
        List x = [];
        x.add(
          generateRandomIndex(
            len,
          ),
        );
        void test() {
          int newIndex = generateRandomIndex(
            len,
          );
          if (x.contains(newIndex)) {
            test();
          } else {
            x.add(newIndex);
          }
        }

        test();
        return x;
      }
    }

    changeNavigationStateToFalse(
      gameID: gameID,
      field: 'isResponseSubmitted',
    );
    changeNavigationStateToFalse(
      gameID: gameID,
      field: 'isResponseSelected',
    );

    Firestore.instance
        .collection('questions')
        .document('modes')
        .collection(gameMode)
        .document(quesIndex())
        .snapshots()
        .listen(
      (event) async {
        List indexes = getIndexes(
          snappp.data.documents.length,
          snappp.data.documents.length == 1 ? 1 : 2,
        );

        String question = !event.data['question'].contains('abc')
            ? event.data['question'].replaceAll(
                'xyz',
                snappp.data.documents[indexes[0]]['name'],
              )
            : event.data['question']
                .replaceAll('xyz', snappp.data.documents[indexes[0]]['name'])
                .replaceAll(
                  'abc',
                  snappp.data.documents[indexes[1]]['name'],
                );

        await Firestore.instance
            .collection('rooms')
            .document(gameID)
            .updateData(
          {
            'currentQuestion': question,
          },
        );
      },
    );
  }
}
