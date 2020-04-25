import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/questionCard.dart';
import 'dart:math';

class QuestionsPage extends StatelessWidget {
  QuestionsPage({
    @required this.playerID,
    @required this.gameID,
  });
  final String playerID;
  final String gameID;

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

    Future<String> fetchQuestion() async {
      QuerySnapshot quesSnap =
          await Firestore.instance.collection('questions').getDocuments();
      String question = quesSnap
          .documents[generateRandomIndex(quesSnap.documents.length)]
          .data['question'];
      return question;
    }

    Future<String> fetchRandomPlayerName() async {
      DocumentSnapshot qs = await Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .get();
      String x = qs.data['playerNames'][generateRandomIndex(
        qs.data['playerNames'].length,
      )];
      return x;
    }

    fetchRandomPlayerName().then(
      (onValue) {
        fetchQuestion().then((qval) {
          print(
            qval.replaceAll(
              'xyz',
              onValue,
            ),
          );
        });
      },
    );

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          QuestionCard(
            question:
                'wfblwf wifjw pifjwpi fipwfp widufpiw duipd uvpiupvi ufpivu pefv',
          ),
        ],
      ),
    );
  }
}
