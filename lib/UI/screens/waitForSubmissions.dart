import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/constants.dart';
import 'package:psych/UI/services/backPressCall.dart';
import 'package:psych/UI/services/changeNavigationState.dart';
import 'package:psych/UI/services/checkForGameEnd.dart';
import 'package:psych/UI/services/checkForNavigation.dart';
import 'package:psych/UI/widgets/customAppBar.dart';
import 'package:psych/UI/widgets/playerCard.dart';

class WaitForSubmissions extends StatelessWidget {
  WaitForSubmissions({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
    @required this.isAdmin,
    @required this.quesCount,
    @required this.avatarList,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  final List avatarList;
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
          currentPage: 'WaitForSubmissions',
          avatarList: avatarList,
        );
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
            backgroundColor: primaryColor,
            appBar: customAppBar(
              context: context,
              gameID: gameID,
              isAdmin: isAdmin,
              playerID: playerID,
              title: 'Please wait...',
            ),
            body: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 1,
                crossAxisCount: 2,
              ),
              itemBuilder: (context, i) {
                return PlayerWaitingCard(
                  avatarList: avatarList,
                  playersCount: snap.data.documents.length,
                  borderColor: snap.data.documents[i]['hasSubmitted']
                      ? Colors.green
                      : Colors.red,
                  cardIndex: i,
                  name: snap.data.documents[i]['name'],
                );
              },
              shrinkWrap: true,
              itemCount: snap.data.documents.length,
            ),
          );
        },
        stream: Firestore.instance
            .collection('rooms')
            .document(gameID)
            .collection('users')
            .orderBy('timestamp')
            .snapshots(),
      ),
    );
  }
}
