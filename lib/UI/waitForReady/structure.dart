import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/structure.dart';
import 'dart:math';

import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/widgets/customAppBar.dart';

class WaitForReady extends StatelessWidget {
  WaitForReady({
    @required this.gameID,
    @required this.playerID,
  });
  final String gameID;
  final String playerID;
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
                                    usersnap.data.documents
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
                  itemCount: usersnap.data.documents
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
                  .collection('users')
                  .orderBy('timestamp')
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

                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return NumberOfSelectionsCard(
                      response: snap.data.documents[i]['response'],
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
                  .collection('users')
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

                return ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, ind) {
                    return PlayerScoreCard(
                      name: usersnap.data.documents[ind]['name'],
                      score: usersnap.data.documents[ind]['score'].toString(),
                      isReady: usersnap.data.documents
                          .where(
                            (x) =>
                                x.documentID ==
                                usersnap.data.documents[ind]['userID'],
                          )
                          .toList()[0]['isReady'],
                      scoreAdded: usersnap.data.documents
                          .where((x) =>
                              x['selection'] ==
                              usersnap.data.documents
                                  .where((y) =>
                                      y['userID'] ==
                                      usersnap.data.documents[ind]['userID'])
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
                  .collection(
                    'roomDetails',
                  )
                  .document(gameID)
                  .collection('users')
                  .orderBy(
                    'score',
                    descending: true,
                  )
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

                  List _users = [];
                  for (int index = 0;
                      index < snap.data.documents.length;
                      index++) {
                    _users.add(snap.data.documents[index].documentID);
                  }
                  if (snap.data.documents.every((x) => x['isReady'] == true) &&
                      _users.contains(
                        playerID,
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
                    builder: (context, roomsnap) {
                      if (!roomsnap.hasData) {
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
                              if (roomsnap.data['admin'] == playerID) {
                                DocumentSnapshot questionRaw =
                                    quessnap.data.documents[generateRandomIndex(
                                  quessnap.data.documents.length,
                                )];

                                List indexes = getIndexes(
                                  snap.data.documents.length,
                                  snap.data.documents.length == 1 ? 1 : 2,
                                );

                                String question = !questionRaw.data['question']
                                        .contains('abc')
                                    ? questionRaw.data['question'].replaceAll(
                                        'xyz',
                                        snap.data.documents[indexes[0]]['name'],
                                      )
                                    : questionRaw.data['question']
                                        .replaceAll(
                                            'xyz',
                                            snap.data.documents[indexes[0]]
                                                ['name'])
                                        .replaceAll(
                                          'abc',
                                          snap.data.documents[indexes[1]]
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
                                  .collection('users')
                                  .document(playerID)
                                  .updateData(
                                {
                                  'hasSelected': false,
                                },
                              );

                              Firestore.instance
                                  .collection('roomDetails')
                                  .document(gameID)
                                  .collection('users')
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
                        .snapshots(),
                  );
                },
                stream: Firestore.instance
                    .collection('roomDetails')
                    .document(gameID)
                    .collection('users')
                    .orderBy('timestamp')
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
        .collection('users')
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
