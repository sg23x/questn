import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/questionCard.dart';
import 'package:psych/UI/responseSelection/responseCard.dart';
import 'package:psych/UI/waitForSelections/structure.dart';

class ResponseSelectionPage extends StatelessWidget {
  ResponseSelectionPage({
    @required this.gameID,
    @required this.playerID,
  });
  final String gameID;
  final String playerID;
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
                    return StreamBuilder(
                      builder: (context, innersnap) {
                        return GestureDetector(
                          onTap: () {
                            if (playerID != snap.data.documents[i].documentID) {
                              Firestore.instance
                                  .collection('roomDetails')
                                  .document(gameID)
                                  .collection('selections')
                                  .document(playerID)
                                  .updateData(
                                {
                                  'selection':
                                      snap.data.documents[i].documentID,
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
                      stream: Firestore.instance
                          .collection('roomDetails')
                          .document(gameID)
                          .collection('users')
                          .snapshots(),
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
            .collection('responses')
            .snapshots(),
      ),
    );
  }
}
