import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/questionCard.dart';

import 'package:psych/UI/waitForSubmissions/structure.dart';

class QuestionsPage extends StatelessWidget {
  QuestionsPage({
    @required this.playerID,
    @required this.gameID,
  });
  final String playerID;
  final String gameID;

  @override
  Widget build(BuildContext context) {
    void sendResponse(String response) {
      Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .collection('responses')
          .document(playerID)
          .updateData(
        {
          'response': response,
          'hasSubmitted': true,
        },
      );
    }

    String response;

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          StreamBuilder(
            builder: (context, snap) {
              if (!snap.hasData) {
                return SizedBox();
              }
              return QuestionCard(
                question: snap.data['currentQuestion'],
              );
            },
            stream: Firestore.instance
                .collection('roomDetails')
                .document(gameID)
                .snapshots(),
          ),
          TextField(
            onChanged: (val) {
              response = val;
            },
          ),
          RaisedButton(
            onPressed: () {
              sendResponse(
                response,
              );
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => WaitForSubmissions(
                    gameID: gameID,
                    playerID: playerID,
                  ),
                ),
              );
            },
            child: Text(
              "Submit",
            ),
          ),
        ],
      ),
    );
  }
}
