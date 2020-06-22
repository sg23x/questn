import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psych/UI/screens/nameInput.dart';
import 'package:psych/UI/widgets/gameEndedAlert.dart';

checkForGameEnd({
  gameID,
  playerID,
  context,
  bool isInLobby = false,
}) {
  Firestore.instance
      .collection('roomDetails')
      .document(gameID)
      .collection('users')
      .reference()
      .snapshots()
      .listen(
    (event) {
      if (isInLobby) {
        if (event.documents
                .where((element) => element.documentID == playerID)
                .toList()
                .length !=
            1) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => NameInputPage(),
              ),
              (route) => false);

          gameEndedAlert(context: context);
        }
      }
      if (!isInLobby) {
        if (event.documents
                    .where((element) => element.documentID == playerID)
                    .toList()
                    .length !=
                1 ||
            event.documents.length < 2) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => NameInputPage(),
              ),
              (route) => false);

          gameEndedAlert(context: context);
        }
      }
    },
  );
}
