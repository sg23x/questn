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

    void changeReadyState() {
      Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .collection('playerStatus')
          .document(playerID)
          .updateData(
        {
          'isReady': false,
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
              response != null && response != ''
                  ? sendResponse(
                      response,
                    )
                  : noResponse(
                      context,
                    );
              response != null && response != '' ? changeReadyState() : null;
              response != null && response != ''
                  ? Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => WaitForSubmissions(
                          gameID: gameID,
                          playerID: playerID,
                        ),
                      ),
                    )
                  : null;
            },
            child: Text(
              "Submit",
            ),
          ),
        ],
      ),
    );
  }

  Widget noResponse(context) {
    //button can be disabled instead
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
            "Can't be empty!",
          ),
        );
      },
    );
  }
}
