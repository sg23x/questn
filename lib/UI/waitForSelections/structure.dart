import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitForReady/structure.dart';
import 'package:psych/UI/waitForSubmissions/waitingForSubmissionPlayerCard.dart';

class WaitForSelectionsPage extends StatelessWidget {
  WaitForSelectionsPage({
    @required this.gameID,
    @required this.playerID,
  });
  final String playerID;
  final String gameID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder(
        builder: (context, snap) {
          if (!snap.hasData) {
            return SizedBox();
          }

          return Column(
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                  itemCount: snap.data.documents.length,
                  itemBuilder: (context, i) {
                    return StreamBuilder(
                      builder: (context, innersnap) {
                        // final int sc = innersnap.data.documents
                        //         .where((b) =>
                        //             b['userID'] ==
                        //             snap.data.documents[i].documentID)
                        //         .toList()[0]['score'] +
                        //     snap.data.documents
                        //         .where(
                        //           (x) =>
                        //               x['selection'] ==
                        //               snap.data.documents[i].documentID,
                        //         )
                        //         .toList()
                        //         .length;
                        if (snap.data.documents
                                .where((x) => x['hasSelected'] == true)
                                .toList()
                                .length ==
                            innersnap.data.documents.length) {
                          if (innersnap.data.documents
                                  .where((b) =>
                                      b['userID'] ==
                                      snap.data.documents[i].documentID)
                                  .toList()[0]['score'] !=
                              innersnap.data.documents
                                      .where((b) =>
                                          b['userID'] ==
                                          snap.data.documents[i].documentID)
                                      .toList()[0]['score'] +
                                  snap.data.documents
                                      .where(
                                        (x) =>
                                            x['selection'] ==
                                            snap.data.documents[i].documentID,
                                      )
                                      .toList()
                                      .length) {
                            Firestore.instance
                                .collection('roomDetails')
                                .document(gameID)
                                .collection('users')
                                .document(innersnap.data.documents
                                    .where((x) =>
                                        x['userID'] ==
                                        snap.data.documents[i].documentID)
                                    .toList()[0]
                                    .documentID)
                                .updateData(
                              {
                                'score': FieldValue.increment(
                                  snap.data.documents
                                      .where(
                                        (x) =>
                                            x['selection'] ==
                                            snap.data.documents[i].documentID,
                                      )
                                      .toList()
                                      .length,
                                ),
                              },
                            );
                          }

                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) {
                              // print(
                              //   innersnap.data.documents
                              //           .where((b) =>
                              //               b['userID'] ==
                              //               snap.data.documents[i].documentID)
                              //           .toList()[0]['score'] +
                              //       snap.data.documents
                              //           .where(
                              //             (x) =>
                              //                 x['selection'] ==
                              //                 snap.data.documents[i].documentID,
                              //           )
                              //           .toList()
                              //           .length
                              //           .toString(),
                              // );

                              // Navigator.pushReplacement(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (BuildContext context) =>
                              //         WaitForReady(
                              //       gameID: gameID,
                              //       playerID: playerID,
                              //     ),
                              //   ),
                              // );
                            },
                          );
                        }

                        return WaitingForSubmissionPlayerCard(
                          name: innersnap.data.documents
                              .where((n) =>
                                  n['userID'] ==
                                  snap.data.documents[i].documentID)
                              .toList()[0]['name'],
                          hasSubmitted: snap.data.documents
                              .where((no) =>
                                  no.documentID ==
                                  innersnap.data.documents[i]['userID'])
                              .toList()[0]
                              .data['hasSelected'],
                        );
                      },
                      stream: Firestore.instance
                          .collection('roomDetails')
                          .document(gameID)
                          .collection('users')
                          .snapshots(),
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
            .collection('selections')
            .snapshots(),
      ),
    );
  }
}
