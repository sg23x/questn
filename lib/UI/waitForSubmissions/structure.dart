import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/functionCalls/backPressCall.dart';
import 'package:psych/UI/functionCalls/changeNavigationState.dart';
import 'package:psych/UI/functionCalls/checkForGameEnd.dart';
import 'package:psych/UI/functionCalls/checkForNavigation.dart';
import 'package:psych/UI/waitForSubmissions/waitingForSubmissionPlayerCard.dart';
import 'package:psych/UI/widgets/customAppBar.dart';

class WaitForSubmissions extends StatelessWidget {
  WaitForSubmissions({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
    @required this.isAdmin,
    @required this.quesCount,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  bool abc = true;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        checkForGameEnd(
          context: context,
          gameID: gameID,
          playerID: playerID,
        );
        checkForNavigation(
            quesCount: quesCount,
            context: context,
            gameID: gameID,
            playerID: playerID,
            gameMode: gameMode,
            isAdmin: isAdmin,
            currentPage: 'WaitForSubmissions');
        isAdmin
            ? changeNavigationStateToTrue(
                playerField: 'hasSubmitted',
                gameID: gameID,
                field: 'isResponseSubmitted',
              )
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
      child: StreamBuilder(
        builder: (context, snap) {
          if (!snap.hasData) {
            return Scaffold();
          }

          return Scaffold(
            appBar: customAppBar(
              context: context,
              gameID: gameID,
              isAdmin: isAdmin,
              playerID: playerID,
              title: 'GAME ID: $gameID',
            ),
            body: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.width * 0.0075,
                ),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, i) {
                      return WaitingForSubmissionPlayerCard(
                        animationIndex: i,
                        name: snap.data.documents[i]['name'],
                        hasSubmitted: snap.data.documents[i]['hasSubmitted'],
                      );
                    },
                    shrinkWrap: true,
                    itemCount: snap.data.documents.length,
                  ),
                ),
              ],
            ),
          );
        },
        stream: Firestore.instance
            .collection('roomDetails')
            .document(gameID)
            .collection('users')
            .snapshots(),
      ),
    );
  }
}
