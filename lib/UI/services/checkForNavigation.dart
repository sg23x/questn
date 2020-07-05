import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psych/UI/screens/questionsPage.dart';
import 'package:psych/UI/screens/responseSelection.dart';

void checkForNavigation({
  @required context,
  @required gameID,
  @required playerID,
  @required gameMode,
  @required isAdmin,
  @required currentPage,
  @required quesCount,
  @required avatarList,
  @required round,
}) async {
  bool xyz = true;
  DocumentSnapshot ds =
      await Firestore.instance.collection('rooms').document(gameID).get();

  ds.reference.snapshots().listen(
    (event) {
      if (currentPage == 'WaitingToStart') {
        if (event.data['isGameStarted'] == true) {
          HapticFeedback.vibrate();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext newcontext) => QuestionsPage(
                quesCount: quesCount,
                playerID: playerID,
                gameID: gameID,
                gameMode: gameMode,
                isAdmin: isAdmin,
                avatarList: avatarList,
                round: round,
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
              builder: (BuildContext newcontext) => ResponseSelectionPage(
                quesCount: quesCount,
                playerID: playerID,
                gameID: gameID,
                gameMode: gameMode,
                isAdmin: isAdmin,
                avatarList: avatarList,
                round: round,
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
              builder: (BuildContext newcontext) => QuestionsPage(
                quesCount: quesCount,
                playerID: playerID,
                gameID: gameID,
                gameMode: gameMode,
                isAdmin: isAdmin,
                avatarList: avatarList,
                round: round - 1,
              ),
            ),
          );
        }
      }
    },
  );
}
