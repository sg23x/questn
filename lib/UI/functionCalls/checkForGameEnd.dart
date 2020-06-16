import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/widgets/gameEndedAlert.dart';

bool abc = true;

checkForGameEnd({
  gameID,
  playerID,
  context,
}) {
  Firestore.instance
      .collection('roomDetails')
      .document(gameID)
      .collection('users')
      .reference()
      .snapshots()
      .listen(
    (event) {
      if ((event.documents
                      .where((element) => element.documentID == playerID)
                      .toList()
                      .length !=
                  1 ||
              event.documents.length < 2) &&
          abc) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => NameInputPage(),
            ),
            (route) => false);

        gameEndedAlert(context: context);
        abc = !abc;
      }
    },
  );
}
