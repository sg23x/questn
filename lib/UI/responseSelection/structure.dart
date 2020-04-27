import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/questionCard.dart';
import 'package:psych/UI/responseSelection/responseCard.dart';

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
                    question: quessnap.data['currentQuestion'],
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
                    return ResponseCard(
                      response: snap.data.documents[i]['response'],
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
