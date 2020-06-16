import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psych/UI/functionCalls/backPressCall.dart';
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
  });
  final String playerID;
  final String gameID;
  final String gameMode;
  final bool isAdmin;
  bool abc = true;
  bool xyz = true;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        checkForGameEnd(
          context: context,
          gameID: gameID,
          playerID: playerID,
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
            List _users = [];
            for (int index = 0;
                index < usersnap.data.documents.length;
                index++) {
              _users.add(
                usersnap.data.documents[index]['userID'],
              );
            }

            if (usersnap.data.documents
                        .where((x) => x['hasSelected'] == true)
                        .toList()
                        .length ==
                    usersnap.data.documents.length &&
                _users.contains(
                  playerID,
                )) {
              if (abc) {
                Firestore.instance
                    .collection('roomDetails')
                    .document(gameID)
                    .collection('users')
                    .document(playerID)
                    .updateData(
                  {
                    'score': FieldValue.increment(
                      usersnap.data.documents
                          .where((g) => g['selection'] == playerID)
                          .toList()
                          .length,
                    ),
                  },
                );
                abc = !abc;
              }

              WidgetsBinding.instance.addPostFrameCallback(
                (_) {
                  HapticFeedback.vibrate();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => WaitForReady(
                        gameID: gameID,
                        playerID: playerID,
                        gameMode: gameMode,
                        isAdmin: isAdmin,
                      ),
                    ),
                  );
                },
              );
            }

            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: usersnap.data.documents.length,
                    itemBuilder: (context, i) {
                      return WaitingForSubmissionPlayerCard(
                          animationIndex: i,
                          name: usersnap.data.documents.length != 0
                              ? usersnap.data.documents
                                  .where((n) =>
                                      n['userID'] ==
                                      usersnap.data.documents[i].documentID)
                                  .toList()[0]['name']
                              : '',
                          hasSubmitted: usersnap.data.documents
                                      .where((no) =>
                                          no.documentID ==
                                          usersnap.data.documents[i]['userID'])
                                      .toList()
                                      .length !=
                                  0
                              ? usersnap.data.documents
                                  .where((no) =>
                                      no.documentID ==
                                      usersnap.data.documents[i]['userID'])
                                  .toList()[0]
                                  .data['hasSelected']
                              : false);
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
