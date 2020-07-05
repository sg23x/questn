import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  });
  final String playerID;
  final String gameID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  final List avatarList;
  final int round;
  final String playerName;

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  Alignment align;
  bool isButtonEnabled;
  String response = '';

  @override
  void initState() {
    align = Alignment.lerp(
      Alignment.center,
      Alignment.centerLeft,
      1.7,
    );
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

    int getMaxLine(context, bool isKeyboardOpen) {
      if (isKeyboardOpen == true) {
        double x = (MediaQuery.of(context).size.height * 0.024) -
            MediaQuery.of(context).viewInsets.bottom * 0.048;
        return x.floor();
      } else {
        double x = MediaQuery.of(context).size.height * 0.018;
        return x.floor();
      }
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
        body: Column(
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
              stream: Firestore.instance
                  .collection('rooms')
                  .document(widget.gameID)
                  .snapshots(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.94,
                  child: Theme(
                    data: ThemeData(
                      primaryColor: Colors.cyan,
                      cursorColor: Colors.cyan,
                    ),
                    child: TextField(
                      scrollPhysics: NeverScrollableScrollPhysics(),
                      textAlign:
                          !isButtonEnabled ? TextAlign.center : TextAlign.start,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        fontFamily: 'Indie-Flower',
                        fontWeight: FontWeight.w900,
                        fontSize: MediaQuery.of(context).size.height * 0.023,
                      ),
                      maxLength: 120,
                      maxLines: getMaxLine(
                        context,
                        MediaQuery.of(context).viewInsets.bottom != 0,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Answer here!',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.065,
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
                              align = Alignment.center;
                            },
                          );
                        } else {
                          setState(
                            () {
                              isButtonEnabled = false;
                              align = Alignment.lerp(
                                Alignment.center,
                                Alignment.centerLeft,
                                1.7,
                              );
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
                child: AnimatedAlign(
                  curve: Curves.fastOutSlowIn,
                  onEnd: align ==
                          Alignment.lerp(
                            Alignment.center,
                            Alignment.centerRight,
                            1.7,
                          )
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
                              ),
                            ),
                          );
                        }
                      : null,
                  duration: Duration(
                    milliseconds: 300,
                  ),
                  alignment: align,
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: MediaQuery.of(context).size.height * 0.07,
                  ),
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 5,
                    color: Colors.cyan.withOpacity(
                      !isButtonEnabled ? 0.5 : 1,
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
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height * 0.01,
                  top: MediaQuery.of(context).size.height * 0.01,
                ),
                width: MediaQuery.of(context).size.width * 0.94,
              ),
              onPressed: isButtonEnabled
                  ? () {
                      setState(
                        () {
                          align = Alignment.lerp(
                            Alignment.center,
                            Alignment.centerRight,
                            1.7,
                          );
                        },
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
