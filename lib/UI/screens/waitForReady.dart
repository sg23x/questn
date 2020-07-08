import 'dart:async';

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

class WaitForReady extends StatefulWidget {
  WaitForReady({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
    @required this.isAdmin,
    @required this.quesCount,
    @required this.avatarList,
    @required this.round,
    @required this.playerName,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  final List avatarList;
  final int round;
  final String playerName;

  @override
  _WaitForReadyState createState() => _WaitForReadyState();
}

class _WaitForReadyState extends State<WaitForReady> {
  generateRandomIndex(int len) {
    Random rnd;
    int min = 0;
    int max = len;
    rnd = new Random();
    var r = min + rnd.nextInt(max - min);
    return r;
  }

  String quesIndex() {
    return (generateRandomIndex(widget.quesCount) + 1).toString();
  }

  void checkForRoundsComplete() {
    if (widget.isAdmin) {
      if (widget.round == 0) {
        Firestore.instance
            .collection('rooms')
            .document(widget.gameID)
            .updateData(
          {'isGameEnded': true},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        checkForGameEnd(
          context: context,
          gameID: widget.gameID,
          playerID: widget.playerID,
        );
        checkForNavigation(
          quesCount: widget.quesCount,
          context: context,
          gameID: widget.gameID,
          playerID: widget.playerID,
          gameMode: widget.gameMode,
          isAdmin: widget.isAdmin,
          currentPage: 'WaitForReady',
          avatarList: widget.avatarList,
          round: widget.round,
          playerName: widget.playerName,
        );
        changeNavigationStateToTrue(
            gameID: widget.gameID, field: 'isReady', playerField: 'isReady');

        checkForRoundsComplete();
        Timer(
          Duration(milliseconds: 3500),
          () {
            listenForGameResult(
              gameID: widget.gameID,
              context: context,
              name: widget.playerName,
            );
          },
        );
      },
    );

    return WillPopScope(
      onWillPop: () => onBackPressed(
        context: context,
        gameID: widget.gameID,
        isAdmin: widget.isAdmin,
        playerID: widget.playerID,
      ),
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('rooms')
            .document(widget.gameID)
            .collection('users')
            .snapshots(),
        builder: (context, snappp) {
          if (!snappp.hasData) {
            return SizedBox();
          }
          return AbsorbPointer(
            absorbing: widget.round == 0 ? true : false,
            child: Scaffold(
              appBar: customAppBar(
                context: context,
                gameID: widget.gameID,
                isAdmin: widget.isAdmin,
                playerID: widget.playerID,
                title: 'Rounds left: ' + widget.round.toString(),
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
                                .where((x) => x['selection'] == widget.playerID)
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
                          (x) => x['selection'] == widget.playerID,
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
                            widget.isAdmin ? fetchQues(snappp) : null;

                            Firestore.instance
                                .collection('rooms')
                                .document(widget.gameID)
                                .collection('users')
                                .document(widget.playerID)
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
                        widget.isAdmin
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
                                                  .document(widget.gameID)
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
            ),
          );
        },
      ),
    );
  }

  void changeReadyStateToTrue() {
    Firestore.instance
        .collection('rooms')
        .document(widget.gameID)
        .collection('users')
        .document(widget.playerID)
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
      gameID: widget.gameID,
      field: 'isResponseSubmitted',
    );
    changeNavigationStateToFalse(
      gameID: widget.gameID,
      field: 'isResponseSelected',
    );

    Firestore.instance
        .collection('questions')
        .document('modes')
        .collection(widget.gameMode)
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
            .document(widget.gameID)
            .updateData(
          {
            'currentQuestion': question,
          },
        );
      },
    );
  }
}
