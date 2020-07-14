import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/constants.dart';
import 'package:psych/UI/services/backPressCall.dart';
import 'package:psych/UI/services/checkForGameEnd.dart';
import 'package:psych/UI/screens/waitForSelections.dart';
import 'package:psych/UI/services/listenForGameResult.dart';
import 'package:psych/UI/widgets/customAppBar.dart';
import 'package:psych/UI/widgets/errorAlertDialog.dart';
import 'package:psych/UI/widgets/questionCard.dart';
import 'package:psych/UI/widgets/responseCard.dart';

class ResponseSelectionPage extends StatefulWidget {
  ResponseSelectionPage({
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

  @override
  _ResponseSelectionPageState createState() => _ResponseSelectionPageState();
}

class _ResponseSelectionPageState extends State<ResponseSelectionPage> {
  bool abc = true;
  bool shuff = true;

  @override
  Widget build(BuildContext context) {
    List responses = [];
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        checkForGameEnd(
          context: context,
          gameID: widget.gameID,
          playerID: widget.playerID,
        );
        listenForGameResult(
          gameID: widget.gameID,
          context: context,
          name: widget.playerName,
        );
      },
    );

    return WillPopScope(
      onWillPop: () => onBackPressed(
        context: context,
        gameID: widget.gameID,
        isAdmin: widget.isAdmin,
        playerID: widget.playerID,
      ),
      child: Scaffold(
        appBar: customAppBar(
          context: context,
          gameID: widget.gameID,
          isAdmin: widget.isAdmin,
          playerID: widget.playerID,
          title: 'Pick the best one!',
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                secondaryColor,
                primaryColor,
              ],
              stops: [0.0, 0.8],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: StreamBuilder(
            builder: (context, snap) {
              if (!snap.hasData) {
                return SizedBox();
              }

              if (shuff) {
                responses.addAll(snap.data.documents);
                responses.shuffle();
                print(responses);
                shuff = false;
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
                        .collection('rooms')
                        .document(widget.gameID)
                        .snapshots(),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: responses.length,
                      itemBuilder: (context, i) {
                        return GestureDetector(
                          onTap: () {
                            if (widget.playerID != responses[i].documentID) {
                              Firestore.instance
                                  .collection('rooms')
                                  .document(widget.gameID)
                                  .collection('users')
                                  .document(widget.playerID)
                                  .updateData(
                                {
                                  'selection': responses[i].documentID,
                                  'hasSelected': true,
                                },
                              );

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      WaitForSelectionsPage(
                                    quesCount: widget.quesCount,
                                    gameID: widget.gameID,
                                    playerID: widget.playerID,
                                    gameMode: widget.gameMode,
                                    isAdmin: widget.isAdmin,
                                    avatarList: widget.avatarList,
                                    round: widget.round,
                                    playerName: widget.playerName,
                                  ),
                                ),
                              );
                            } else {
                              showErrorDialog(
                                  context: context,
                                  errorMessage:
                                      'You can\'t choose your own answer');
                            }
                          },
                          child: ResponseCard(
                            response: responses[i]['response'],
                            borderColor: Colors.white,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
            stream: Firestore.instance
                .collection('rooms')
                .document(widget.gameID)
                .collection('users')
                .snapshots(),
          ),
        ),
      ),
    );
  }
}
