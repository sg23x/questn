import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:questn/UI/constants.dart';
import 'package:questn/UI/screens/responseSelection.dart';
import 'package:questn/UI/services/backPressCall.dart';
import 'package:questn/UI/services/changeNavigationState.dart';
import 'package:questn/UI/services/checkForGameEnd.dart';
import 'package:questn/UI/services/listenForGameResult.dart';
import 'package:questn/UI/widgets/customAppBar.dart';
import 'package:questn/UI/widgets/playerCard.dart';

class WaitForSubmissions extends StatelessWidget {
  WaitForSubmissions({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
    @required this.isAdmin,
    @required this.quesCount,
    @required this.avatarList,
    @required this.round,
    @required this.playerName,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  final List avatarList;
  final int round;
  final String playerName;
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

        isAdmin
            ? changeNavigationStateToTrue(
                playerField: 'hasSubmitted',
                gameID: gameID,
                field: 'isResponseSubmitted',
              )
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
      child: StreamBuilder(
        builder: (context, snap) {
          if (!snap.hasData) {
            return Scaffold();
          }

          return StreamBuilder(
            builder: (context, roomsnap) {
              if (!roomsnap.hasData) {
                return Scaffold();
              }
              WidgetsBinding.instance.addPostFrameCallback(
                (_) async {
                  if (roomsnap.data['isResponseSubmitted'] == true) {
                    HapticFeedback.vibrate();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext newcontext) =>
                            ResponseSelectionPage(
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
                  }
                },
              );
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
                      scale: 1,
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
                .snapshots(),
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
