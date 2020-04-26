import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitForSubmissions/waitingForSubmissionPlayerCard.dart';

class WaitForSubmissions extends StatelessWidget {
  WaitForSubmissions({@required this.gameID, @required this.playerID});
  final String gameID;
  final String playerID;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold();
          }
          return StreamBuilder(
            builder: (context, snap) {
              if (!snap.hasData) {
                return Scaffold();
              }

              List l1 = [];
              for (int k = 0; k < snap.data.documents.length; k++) {
                l1.add(snap.data.documents[k].documentID);
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
                            hasSubmitted: l1.contains(
                              snapshot.data.documents[i]['userID'],
                            ),
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
            .snapshots());
  }
}
