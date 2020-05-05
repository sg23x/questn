import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/structure.dart';
import 'dart:math';

class WaitForReady extends StatelessWidget {
  WaitForReady({
    @required this.gameID,
    @required this.playerID,
  });
  final String gameID;
  final String playerID;
  @override
  Widget build(BuildContext context) {
    generateRandomIndex(int len) {
      Random rnd;
      int min = 0;
      int max = len;
      rnd = new Random();
      var r = min + rnd.nextInt(max - min);
      return r;
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
            StreamBuilder(
              builder: (context, usersnap) {
                if (!usersnap.hasData) {
                  return SizedBox();
                }
                return StreamBuilder(
                  builder: (context, selsnap) {
                    if (!selsnap.hasData) {
                      return SizedBox();
                    }

                    return ListView.builder(
                      itemBuilder: (context, i) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              usersnap.data.documents
                                  .where(
                                    (c) =>
                                        c.documentID ==
                                        selsnap.data.documents
                                            .where(
                                              (x) => x['selection'] == playerID,
                                            )
                                            .toList()[i]
                                            .documentID,
                                  )
                                  .toList()[0]['name'],
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        );
                      },
                      itemCount: selsnap.data.documents
                          .where(
                            (x) => x['selection'] == playerID,
                          )
                          .toList()
                          .length,
                      shrinkWrap: true,
                    );
                  },
                  stream: Firestore.instance
                      .collection('roomDetails')
                      .document(gameID)
                      .collection('selections')
                      .snapshots(),
                );
              },
              stream: Firestore.instance
                  .collection('roomDetails')
                  .document(gameID)
                  .collection('users')
                  .snapshots(),
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
            StreamBuilder(
              builder: (context, snap) {
                if (!snap.hasData) {
                  return SizedBox();
                }
                return StreamBuilder(
                  builder: (context, respsnap) {
                    if (!respsnap.hasData) {
                      return SizedBox();
                    }

                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, i) {
                        return NumberOfSelectionsCard(
                          response: respsnap.data.documents[i]['response'],
                          timesSelected: snap.data.documents
                              .where(
                                (x) =>
                                    x['selection'] ==
                                    snap.data.documents[i].documentID,
                              )
                              .toList()
                              .length
                              .toString(),
                        );
                      },
                      shrinkWrap: true,
                      itemCount: snap.data.documents.length,
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
                  .collection('selections')
                  .snapshots(),
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
            StreamBuilder(
              builder: (context, usersnap) {
                if (!usersnap.hasData) {
                  return SizedBox();
                }
                return StreamBuilder(
                  builder: (context, selsnap) {
                    if (!selsnap.hasData) {
                      return SizedBox();
                    }
                    return StreamBuilder(
                      builder: (context, readysnap) {
                        if (!readysnap.hasData) {
                          return SizedBox();
                        }

                        return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, ind) {
                            return PlayerScoreCard(
                              name: usersnap.data.documents[ind]['name'],
                              score: usersnap.data.documents[ind]['score']
                                  .toString(),
                              isReady: readysnap.data.documents
                                  .where(
                                    (x) =>
                                        x.documentID ==
                                        usersnap.data.documents[ind]['userID'],
                                  )
                                  .toList()[0]['isReady'],
                              scoreAdded: selsnap.data.documents
                                  .where((x) =>
                                      x['selection'] ==
                                      usersnap.data.documents
                                          .where((y) =>
                                              y['userID'] ==
                                              usersnap.data.documents[ind]
                                                  ['userID'])
                                          .toList()[0]
                                          .documentID)
                                  .toList()
                                  .length
                                  .toString(),
                            );
                          },
                          itemCount: usersnap.data.documents.length,
                          shrinkWrap: true,
                        );
                      },
                      stream: Firestore.instance
                          .collection('roomDetails')
                          .document(gameID)
                          .collection('playerStatus')
                          .snapshots(),
                    );
                  },
                  stream: Firestore.instance
                      .collection('roomDetails')
                      .document(gameID)
                      .collection('selections')
                      .snapshots(),
                );
              },
              stream: Firestore.instance
                  .collection(
                    'roomDetails',
                  )
                  .document(gameID)
                  .collection('users')
                  .orderBy('score', descending: true)
                  .snapshots(),
            ),
            Container(
              width: 50,
              margin: EdgeInsets.symmetric(
                horizontal: 100,
              ),
              child: StreamBuilder(
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return SizedBox();
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
                              playerID: playerID,
                              gameID: gameID,
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return StreamBuilder(
                    builder: (context, usersnap) {
                      if (!usersnap.hasData) {
                        return SizedBox();
                      }
                      return StreamBuilder(
                        builder: (context, quessnap) {
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

                          if (!quessnap.hasData) {
                            return SizedBox();
                          }
                          return RaisedButton(
                            color: Colors.red,
                            onPressed: () async {
                              if (usersnap.data.documents[0].documentID ==
                                  playerID) {
                                DocumentSnapshot questionRaw =
                                    quessnap.data.documents[generateRandomIndex(
                                  quessnap.data.documents.length,
                                )];

                                List indexes = getIndexes(
                                    usersnap.data.documents.length, 2);

                                String question = !questionRaw.data['question']
                                        .contains('abc')
                                    ? questionRaw.data['question'].replaceAll(
                                        'xyz',
                                        usersnap.data.documents[indexes[0]]
                                            ['name'],
                                      )
                                    : questionRaw.data['question']
                                        .replaceAll(
                                            'xyz',
                                            usersnap.data.documents[indexes[0]]
                                                ['name'])
                                        .replaceAll(
                                          'abc',
                                          usersnap.data.documents[indexes[1]]
                                              ['name'],
                                        );

                                await Firestore.instance
                                    .collection('roomDetails')
                                    .document(gameID)
                                    .updateData(
                                  {
                                    'currentQuestion': question,
                                  },
                                );
                              }

                              Firestore.instance
                                  .collection('roomDetails')
                                  .document(gameID)
                                  .collection('selections')
                                  .document(playerID)
                                  .updateData(
                                {
                                  'hasSelected': false,
                                },
                              );

                              Firestore.instance
                                  .collection('roomDetails')
                                  .document(gameID)
                                  .collection('responses')
                                  .document(playerID)
                                  .updateData(
                                {
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
                          );
                        },
                        stream: Firestore.instance
                            .collection('questions')
                            .snapshots(),
                      );
                    },
                    stream: Firestore.instance
                        .collection('roomDetails')
                        .document(gameID)
                        .collection('users')
                        .orderBy('timestamp')
                        .snapshots(),
                  );
                },
                stream: Firestore.instance
                    .collection('roomDetails')
                    .document(gameID)
                    .collection('playerStatus')
                    .snapshots(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void changeReadyStateToTrue() {
    Firestore.instance
        .collection('roomDetails')
        .document(gameID)
        .collection('playerStatus')
        .document(playerID)
        .updateData(
      {
        'isReady': true,
      },
    );
  }
}

class NumberOfSelectionsCard extends StatelessWidget {
  NumberOfSelectionsCard({
    @required this.response,
    @required this.timesSelected,
  });
  final String response;
  final String timesSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(
        5,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      color: Colors.pink,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '$response',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            '$timesSelected',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerScoreCard extends StatelessWidget {
  PlayerScoreCard({
    @required this.name,
    @required this.score,
    @required this.scoreAdded,
    @required this.isReady,
  });
  final String name;
  final String score;
  final String scoreAdded;
  final bool isReady;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(
        5,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '$name :',
            style: TextStyle(
              color: isReady ? Colors.green : Colors.red,
              fontSize: 25,
            ),
          ),
          Text(
            '$score (+$scoreAdded)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }
}
