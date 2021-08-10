import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:questn/UI/constants.dart';
import 'package:questn/UI/screens/waitingToStart.dart';
import 'dart:math';

import 'package:questn/UI/widgets/customProgressIndicator.dart';
import 'package:questn/UI/widgets/errorAlertDialog.dart';

class JoinGameButton extends StatefulWidget {
  JoinGameButton({
    @required this.playerName,
  });
  final String playerName;

  @override
  _JoinGameButtonState createState() => _JoinGameButtonState();
}

class _JoinGameButtonState extends State<JoinGameButton> {
  String gameID;
  Alignment axis;

  @override
  void initState() {
    axis = Alignment.lerp(
      Alignment.bottomCenter,
      Alignment.bottomRight,
      1,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String generateUserCode() {
      Random rnd;
      int min = 100000000;
      int max = 999999999;
      rnd = new Random();
      var r = min + rnd.nextInt(max - min);
      return r.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        setState(
          () {
            axis = Alignment.lerp(
              Alignment.bottomCenter,
              Alignment.bottomLeft,
              0.5,
            );
          },
        );
      },
    );

    final String playerID = generateUserCode();

    void joinGame() {
      showDialog(
        barrierColor: Colors.black.withOpacity(0.7),
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            elevation: 20,
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  customProgressIndicator(context: context);
                  final snap = await Firestore.instance
                      .collection('rooms')
                      .document(gameID)
                      .get();
                  final usersnap = await Firestore.instance
                      .collection('rooms')
                      .document(gameID)
                      .collection('users')
                      .getDocuments();

                  if (snap.exists) {
                    if (snap.data['isGameStarted'] == false) {
                      if (usersnap.documents.length < 8) {
                        Navigator.of(context).pop();

                        Firestore.instance
                            .collection('rooms')
                            .document(gameID)
                            .collection('users')
                            .document(
                              playerID,
                            )
                            .setData(
                          {
                            'name': widget.playerName,
                            'userID': playerID,
                            'score': 0,
                            'timestamp': Timestamp.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            'isReady': true,
                            'hasSelected': false,
                            'selection': '',
                            'hasSubmitted': false,
                            'response': '',
                          },
                        );

                        Navigator.of(context).pop();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => WaitingToStart(
                              gameID: gameID,
                              playerID: playerID,
                              isAdmin: false,
                              playerName: widget.playerName,
                            ),
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        showErrorDialog(
                          context: context,
                          errorMessage: 'Sorry, the room is full!',
                        );
                      }
                    } else {
                      Navigator.of(context).pop();
                      showErrorDialog(
                        context: context,
                        errorMessage: 'Sorry, the game has started!',
                      );
                    }
                  } else {
                    Navigator.of(context).pop();

                    showErrorDialog(
                      context: context,
                      errorMessage: 'Sorry, no such game found!',
                    );
                  }
                },
                child: Text(
                  "Go",
                  style: TextStyle(
                    color: secondaryColor,
                    fontFamily: 'Gotham-Book',
                    fontSize: MediaQuery.of(context).size.height * 0.023,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            ],
            content: Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height * 0.14,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    "Enter Game ID",
                    style: TextStyle(
                      fontFamily: 'Gotham-Book',
                      fontSize: MediaQuery.of(context).size.height * 0.03,
                      color: primaryColor,
                    ),
                  ),
                  Theme(
                    data: ThemeData(
                      primaryColor: secondaryColor,
                      cursorColor: secondaryColor,
                    ),
                    child: PinEntryTextField(
                      fields: 4,
                      onSubmit: (String pin) {
                        setState(
                          () {
                            gameID = pin;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FlatButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          color: Colors.transparent,
          padding: EdgeInsets.all(
            0,
          ),
          onPressed: () {
            joinGame();
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.4,
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.23,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.04,
                      ),
                      Text(
                        'JOIN\nGAME',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.15,
                          fontFamily: 'Gotham-Book',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
