import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/questionCard.dart';
import 'package:psych/UI/functionCalls/backPressCall.dart';
import 'package:psych/UI/functionCalls/checkForGameEnd.dart';
import 'package:psych/UI/responseSelection/responseCard.dart';
import 'package:psych/UI/waitForSelections/structure.dart';
import 'package:psych/UI/widgets/customAppBar.dart';

class ResponseSelectionPage extends StatelessWidget {
  ResponseSelectionPage({
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
          builder: (context, snap) {
            if (!snap.hasData) {
              return SizedBox();
            }
            return Column(
              children: <Widget>[
                StreamBuilder(
                  builder: (context, quessnap) {
                    return QuestionCard(
                      question: quessnap.data != null
                          ? quessnap.data['currentQuestion']
                          : '',
                    );
                  },
                  stream: Firestore.instance
                      .collection('roomDetails')
                      .document(gameID)
                      .snapshots(),
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snap.data.documents.length,
                    itemBuilder: (context, i) {
                      return GestureDetector(
                        onTap: () {
                          if (playerID != snap.data.documents[i].documentID) {
                            Firestore.instance
                                .collection('roomDetails')
                                .document(gameID)
                                .collection('users')
                                .document(playerID)
                                .updateData(
                              {
                                'selection': snap.data.documents[i].documentID,
                                'hasSelected': true,
                              },
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    WaitForSelectionsPage(
                                  quesCount: quesCount,
                                  gameID: gameID,
                                  playerID: playerID,
                                  gameMode: gameMode,
                                  isAdmin: isAdmin,
                                ),
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  actions: <Widget>[
                                    FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "OK",
                                      ),
                                    )
                                  ],
                                  content: Text(
                                    "You can't choose your own answer!",
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: ResponseCard(
                          response: snap.data.documents[i]['response'],
                        ),
                      );
                    },
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
