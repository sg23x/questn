import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';
import 'package:psych/UI/waitingToStart/structure.dart';
import 'dart:math';

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
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            elevation: 20,
            actions: <Widget>[
              FlatButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          CircularProgressIndicator(
                            backgroundColor: Colors.pink,
                            strokeWidth: 8,
                          ),
                        ],
                      );
                    },
                  );

                  final snap = await Firestore.instance
                      .collection('roomDetails')
                      .document(gameID)
                      .get();

                  if (snap.exists) {
                    if (snap.data['isGameStarted'] == false) {
                      Navigator.of(context).pop();

                      Firestore.instance
                          .collection('roomDetails')
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
                          'timestamp':
                              Timestamp.now().millisecondsSinceEpoch.toString(),
                          'isReady': false,
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
                          ),
                        ),
                      );
                    } else {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            contentTextStyle: TextStyle(
                              fontFamily: 'Indie-Flower',
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.025,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                    fontFamily: 'Indie-Flower',
                                    color: Colors.pink,
                                    fontWeight: FontWeight.w900,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                  ),
                                ),
                              )
                            ],
                            content: Text(
                              "Sorry, The game has started!",
                            ),
                          );
                        },
                      );
                    }
                  } else {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentTextStyle: TextStyle(
                            fontFamily: 'Indie-Flower',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.025,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "OK",
                                style: TextStyle(
                                  fontFamily: 'Indie-Flower',
                                  color: Colors.pink,
                                  fontWeight: FontWeight.w900,
                                  fontSize:
                                      MediaQuery.of(context).size.height * 0.03,
                                ),
                              ),
                            )
                          ],
                          content: Text(
                            "Sorry, No such game found!",
                          ),
                        );
                      },
                    );
                  }
                },
                child: Text(
                  "Go!",
                  style: TextStyle(
                    color: Colors.pink,
                    fontFamily: 'Indie-Flower',
                    fontSize: MediaQuery.of(context).size.height * 0.03,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              )
            ],
            content: Container(
              height: MediaQuery.of(context).size.height * 0.14,
              child: Column(
                children: <Widget>[
                  Text(
                    "Enter Game ID",
                    style: TextStyle(
                      fontFamily: 'Indie-Flower',
                      fontSize: MediaQuery.of(context).size.height * 0.03,
                      color: Colors.pink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Theme(
                    data: ThemeData(
                      primaryColor: Colors.pink,
                      cursorColor: Colors.pink,
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

    return AnimatedAlign(
      duration: Duration(
        milliseconds: 400,
      ),
      alignment: axis,
      child: RaisedButton(
        color: Colors.transparent,
        padding: EdgeInsets.all(
          0,
        ),
        elevation: 15,
        onPressed: () {
          joinGame();
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              10,
            ),
            color: Colors.pink,
            border: Border.all(
              width: 3,
              color: Colors.white,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Join Game',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Indie-Flower',
                  fontWeight: FontWeight.w900,
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
