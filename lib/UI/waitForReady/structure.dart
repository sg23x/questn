import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/structure.dart';

class WaitForReady extends StatelessWidget {
  WaitForReady({
    @required this.gameID,
    @required this.playerID,
  });
  final String gameID;
  final String playerID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            height: 50,
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
                  return ListView.builder(
                    itemBuilder: (context, ind) {
                      return PlayerScoreCard(
                        name: usersnap.data.documents[ind]['name'],
                        score: usersnap.data.documents[ind]['score'].toString(),
                        scoreAdded: selsnap.data.documents
                            .where(
                              (x) =>
                                  x['selection'] ==
                                  selsnap.data.documents[ind].documentID,
                            )
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
          Container(
            width: 50,
            margin: EdgeInsets.symmetric(
              horizontal: 100,
            ),
            child: StreamBuilder(
              builder: (context, snap) {
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
                return RaisedButton(
                  color: Colors.red,
                  onPressed: () {
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
                  .collection('roomDetails')
                  .document(gameID)
                  .collection('playerStatus')
                  .snapshots(),
            ),
          ),
        ],
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
  });
  final String name;
  final String score;
  final String scoreAdded;
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
              color: Colors.white,
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
