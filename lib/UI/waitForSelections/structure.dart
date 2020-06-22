import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psych/UI/functionCalls/backPressCall.dart';
import 'package:psych/UI/functionCalls/changeNavigationState.dart';
import 'package:psych/UI/functionCalls/checkForGameEnd.dart';
import 'package:psych/UI/waitForReady/structure.dart';
import 'package:psych/UI/waitForSubmissions/waitingForSubmissionPlayerCard.dart';
import 'package:psych/UI/widgets/customAppBar.dart';

class WaitForSelectionsPage extends StatelessWidget {
  WaitForSelectionsPage({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
    @required this.isAdmin,
    @required this.quesCount,
  });
  final String playerID;
  final String gameID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  bool abc = true;

  @override
  Widget build(BuildContext context) {
    void navigatorAndScoreUpdator() async {
      DocumentSnapshot ds = await Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .get();

      ds.reference.snapshots().listen(
        (event) {
          if (event.data['isResponseSelected'] == true) {
            if (abc) {
              Firestore.instance
                  .collection('roomDetails')
                  .document(gameID)
                  .collection('users')
                  .getDocuments()
                  .then(
                (event) {
                  Firestore.instance
                      .collection('roomDetails')
                      .document(gameID)
                      .collection('users')
                      .document(playerID)
                      .updateData(
                    {
                      'score': FieldValue.increment(event.documents
                          .where((element) => element['selection'] == playerID)
                          .toList()
                          .length),
                    },
                  );
                },
              );

              HapticFeedback.vibrate();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => WaitForReady(
                    quesCount: quesCount,
                    playerID: playerID,
                    gameID: gameID,
                    gameMode: gameMode,
                    isAdmin: isAdmin,
                  ),
                ),
              );
              abc = !abc;
            }
          }
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        checkForGameEnd(
          context: context,
          gameID: gameID,
          playerID: playerID,
        );
        navigatorAndScoreUpdator();
        isAdmin
            ? changeNavigationStateToTrue(
                playerField: 'hasSelected',
                gameID: gameID,
                field: 'isResponseSelected')
            : null;
      },
    );

    return WillPopScope(
      onWillPop: () => onBackPressed(
        context: context,
        gameID: gameID,
        isAdmin: isAdmin,
        playerID: playerID,
      ),
      child: Scaffold(
        appBar: customAppBar(
          context: context,
          gameID: gameID,
          isAdmin: isAdmin,
          playerID: playerID,
          title: 'GAME ID: $gameID',
        ),
        body: StreamBuilder(
          builder: (context, usersnap) {
            if (!usersnap.hasData) {
              return SizedBox();
            }

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: usersnap.data.documents.length,
                    itemBuilder: (context, i) {
                      return WaitingForSubmissionPlayerCard(
                        animationIndex: i,
                        name: usersnap.data.documents[i]['name'],
                        hasSubmitted: usersnap.data.documents[i]['hasSelected'],
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
              .collection('users')
              .snapshots(),
        ),
      ),
    );
  }
}
