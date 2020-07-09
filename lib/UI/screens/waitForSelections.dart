import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psych/UI/constants.dart';
import 'package:psych/UI/services/backPressCall.dart';
import 'package:psych/UI/services/changeNavigationState.dart';
import 'package:psych/UI/services/checkForGameEnd.dart';
import 'package:psych/UI/screens/waitForReady.dart';
import 'package:psych/UI/services/listenForGameResult.dart';
import 'package:psych/UI/widgets/customAppBar.dart';
import 'package:psych/UI/widgets/playerCard.dart';

class WaitForSelectionsPage extends StatelessWidget {
  WaitForSelectionsPage({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
    @required this.isAdmin,
    @required this.quesCount,
    @required this.avatarList,
    @required this.round,
    @required this.playerName,
  });
  final String playerID;
  final String gameID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  final List avatarList;
  final int round;
  final String playerName;
  bool abc = true;

  @override
  Widget build(BuildContext context) {
    void navigatorAndScoreUpdator() async {
      DocumentSnapshot ds =
          await Firestore.instance.collection('rooms').document(gameID).get();

      ds.reference.snapshots().listen(
        (event) {
          if (event.data['isResponseSelected'] == true) {
            if (abc) {
              Firestore.instance
                  .collection('rooms')
                  .document(gameID)
                  .collection('users')
                  .getDocuments()
                  .then(
                (event) {
                  Firestore.instance
                      .collection('rooms')
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
                    avatarList: avatarList,
                    round: round,
                    playerName: playerName,
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
        listenForGameResult(
          gameID: gameID,
          context: context,
          name: playerName,
        );
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
        backgroundColor: primaryColor,
        appBar: customAppBar(
          context: context,
          gameID: gameID,
          isAdmin: isAdmin,
          playerID: playerID,
          title: 'Please wait...',
        ),
        body: StreamBuilder(
          builder: (context, usersnap) {
            if (!usersnap.hasData) {
              return SizedBox();
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1,
                crossAxisCount: 2,
              ),
              itemBuilder: (context, i) {
                return PlayerWaitingCard(
                  scale: 1,
                  avatarList: avatarList,
                  playersCount: usersnap.data.documents.length,
                  borderColor: usersnap.data.documents[i]['hasSelected']
                      ? Colors.green
                      : Colors.red,
                  cardIndex: i,
                  name: usersnap.data.documents[i]['name'],
                );
              },
              shrinkWrap: true,
              itemCount: usersnap.data.documents.length,
            );
          },
          stream: Firestore.instance
              .collection('rooms')
              .document(gameID)
              .collection('users')
              .orderBy('timestamp')
              .snapshots(),
        ),
      ),
    );
  }
}
