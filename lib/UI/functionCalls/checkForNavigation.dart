import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psych/UI/QuestionsPage/structure.dart';
import 'package:psych/UI/responseSelection/structure.dart';

void checkForNavigation({
  @required context,
  @required gameID,
  @required playerID,
  @required gameMode,
  @required isAdmin,
  @required currentPage,
  @required quesCount,
}) async {
  DocumentSnapshot ds =
      await Firestore.instance.collection('roomDetails').document(gameID).get();

  ds.reference.snapshots().listen(
    (event) {
      if (currentPage == 'WaitingToStart') {
        if (event.data['isGameStarted'] == true) {
          HapticFeedback.vibrate();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => QuestionsPage(
                quesCount: quesCount,
                playerID: playerID,
                gameID: gameID,
                gameMode: gameMode,
                isAdmin: isAdmin,
              ),
            ),
          );
        }
      }
      if (currentPage == 'WaitForSubmissions') {
        if (event.data['isResponseSubmitted'] == true) {
          HapticFeedback.vibrate();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ResponseSelectionPage(
                quesCount: quesCount,
                playerID: playerID,
                gameID: gameID,
                gameMode: gameMode,
                isAdmin: isAdmin,
              ),
            ),
          );
        }
      }
      if (currentPage == 'WaitForReady') {
        if (event.data['isReady'] == true) {
          HapticFeedback.vibrate();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => QuestionsPage(
                quesCount: quesCount,
                playerID: playerID,
                gameID: gameID,
                gameMode: gameMode,
                isAdmin: isAdmin,
              ),
            ),
          );
        }
      }
    },
  );
}
