import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
          Container(
            width: 50,
            margin: EdgeInsets.symmetric(
              horizontal: 100,
            ),
            child: RaisedButton(
              color: Colors.black,
              onPressed: () {},
              child: Text(
                'ready',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
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
  });
  final String name;
  final String score;
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
              fontSize: 18,
            ),
          ),
          Text(
            '$score',
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
