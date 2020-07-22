import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/constants.dart';
import 'package:psych/UI/screens/waitForSubmissions.dart';
import 'package:psych/UI/services/backPressCall.dart';
import 'package:psych/UI/services/changeNavigationState.dart';
import 'package:psych/UI/services/checkForGameEnd.dart';
import 'package:psych/UI/services/listenForGameResult.dart';
import 'package:psych/UI/widgets/customAppBar.dart';
import 'package:psych/UI/widgets/questionCard.dart';

class QuestionsPage extends StatefulWidget {
  QuestionsPage({
    @required this.playerID,
    @required this.gameID,
    @required this.gameMode,
    @required this.isAdmin,
    @required this.quesCount,
    @required this.avatarList,
    @required this.round,
    @required this.playerName,
    @required this.roomStream,
    @required this.userStream,
  });
  final String playerID;
  final String gameID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  final List avatarList;
  final int round;
  final String playerName;
  final Stream roomStream;
  final Stream userStream;

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  bool isButtonEnabled;
  String response = '';

  @override
  void initState() {
    isButtonEnabled = false;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void sendResponse(String response) {
      Firestore.instance
          .collection('rooms')
          .document(widget.gameID)
          .collection('users')
          .document(widget.playerID)
          .updateData(
        {
          'response': response,
          'hasSubmitted': true,
          'isReady': false,
        },
      );
      widget.isAdmin
          ? changeNavigationStateToFalse(
              gameID: widget.gameID, field: 'isReady')
          : null;
    }

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
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        appBar: customAppBar(
          context: context,
          gameID: widget.gameID,
          isAdmin: widget.isAdmin,
          playerID: widget.playerID,
          title: 'Rounds left: ' + widget.round.toString(),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              end: Alignment.bottomCenter,
              begin: Alignment.topCenter,
              colors: [
                secondaryColor,
                primaryColor,
              ],
            ),
          ),
          child: Column(
            children: <Widget>[
              StreamBuilder(
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return SizedBox();
                  }
                  return QuestionCard(
                    question: snap.data['currentQuestion'],
                  );
                },
                stream: widget.roomStream,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(
                      MediaQuery.of(context).size.width * 0.03,
                    ),
                    width: MediaQuery.of(context).size.width * 0.94,
                    child: Theme(
                      data: ThemeData(
                        primaryColor: primaryColor,
                        cursorColor: primaryColor,
                      ),
                      child: TextField(
                        maxLines: 5,
                        scrollPhysics: NeverScrollableScrollPhysics(),
                        textInputAction: TextInputAction.go,
                        onSubmitted: (val) {
                          response = val.trim();
                          if (!(response == null || response.length == 0)) {
                            setState(
                              () {
                                isButtonEnabled = true;
                              },
                            );
                          } else {
                            setState(
                              () {
                                isButtonEnabled = false;
                              },
                            );
                          }
                          isButtonEnabled
                              ? sendResponse(
                                  response,
                                )
                              : null;

                          isButtonEnabled
                              ? Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        WaitForSubmissions(
                                      quesCount: widget.quesCount,
                                      gameID: widget.gameID,
                                      playerID: widget.playerID,
                                      gameMode: widget.gameMode,
                                      isAdmin: widget.isAdmin,
                                      avatarList: widget.avatarList,
                                      round: widget.round,
                                      playerName: widget.playerName,
                                      roomStream: widget.roomStream,
                                      userStream: widget.userStream,
                                    ),
                                  ),
                                )
                              : null;
                        },
                        textAlign: !isButtonEnabled
                            ? TextAlign.center
                            : TextAlign.start,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontFamily: 'Gotham-Book',
                          fontWeight: FontWeight.w900,
                          fontSize: MediaQuery.of(context).size.height * 0.023,
                        ),
                        maxLength: 90,
                        decoration: InputDecoration(
                          hintText: '\n\nAnswer here!',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.065,
                            vertical: MediaQuery.of(context).size.height * 0.03,
                          ),
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              15,
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          response = val.trim();
                          if (!(response == null || response.length == 0)) {
                            setState(
                              () {
                                isButtonEnabled = true;
                              },
                            );
                          } else {
                            setState(
                              () {
                                isButtonEnabled = false;
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              RaisedButton(
                highlightColor: Colors.transparent,
                disabledColor: Colors.transparent,
                elevation: 0,
                color: Colors.transparent,
                padding: EdgeInsets.all(
                  0,
                ),
                child: Container(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(isButtonEnabled ? 1 : 0.6),
                    size: MediaQuery.of(context).size.height * 0.04,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 5,
                      color: secondaryColor.withOpacity(
                        !isButtonEnabled ? 0.0 : 1,
                      ),
                    ),
                    color: Colors.black.withOpacity(
                      !isButtonEnabled ? 0.7 : 1,
                    ),
                    borderRadius: BorderRadius.circular(
                      15,
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.94,
                ),
                onPressed: isButtonEnabled
                    ? () {
                        sendResponse(
                          response,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                WaitForSubmissions(
                              quesCount: widget.quesCount,
                              gameID: widget.gameID,
                              playerID: widget.playerID,
                              gameMode: widget.gameMode,
                              isAdmin: widget.isAdmin,
                              avatarList: widget.avatarList,
                              round: widget.round,
                              playerName: widget.playerName,
                              roomStream: widget.roomStream,
                              userStream: widget.userStream,
                            ),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
