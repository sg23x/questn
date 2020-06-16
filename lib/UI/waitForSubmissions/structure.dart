import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psych/UI/functionCalls/backPressCall.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/responseSelection/structure.dart';
import 'package:psych/UI/waitForSubmissions/waitingForSubmissionPlayerCard.dart';
import 'package:psych/UI/widgets/customAppBar.dart';
import 'package:psych/UI/widgets/gameEndedAlert.dart';

class WaitForSubmissions extends StatelessWidget {
  WaitForSubmissions({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
    @required this.isAdmin,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;
  bool abc = true;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
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
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => NameInputPage(),
                  ),
                  (route) => false);
              abc = !abc;
              gameEndedAlert(context: context);
            }
          },
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

          List _users = [];
          for (int index = 0; index < snap.data.documents.length; index++) {
            _users.add(
              snap.data.documents[index]['userID'],
            );
          }
          if (snap.data.documents
                      .where((x) => x['hasSubmitted'] == true)
                      .toList()
                      .length ==
                  snap.data.documents.length &&
              _users.contains(
                playerID,
              )) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) async {
                HapticFeedback.vibrate();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => ResponseSelectionPage(
                      playerID: playerID,
                      gameID: gameID,
                      gameMode: gameMode,
                      isAdmin: isAdmin,
                    ),
                  ),
                );
              },
            );
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
                        hasSubmitted: snap.data.documents
                                    .where(
                                      (no) =>
                                          no.documentID ==
                                          snap.data.documents[i]['userID'],
                                    )
                                    .toList()
                                    .length !=
                                0
                            ? snap.data.documents
                                .where(
                                  (no) =>
                                      no.documentID ==
                                      snap.data.documents[i]['userID'],
                                )
                                .toList()[0]
                                .data['hasSubmitted']
                            : false,
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
