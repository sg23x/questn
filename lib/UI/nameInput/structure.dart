import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/gameSelection/structure.dart';

class NameInputPage extends StatefulWidget {
  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  String playerName;
  bool isButtonEnabled;
  Alignment align;
  String gameID;
  FocusNode focus;

  @override
  void initState() {
    isButtonEnabled = false;
    align = Alignment.center;
    focus = new FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void submitName() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => GameSelection(
            playerName: playerName,
            gameID: gameID,
          ),
        ),
      );
    }

    void createRoomID() async {
      await Firestore.instance
          .collection(
            'roomDetails',
          )
          .getDocuments()
          .then(
        (onValue) {
          setState(
            () {
              gameID = onValue.documents.length != 0
                  ? ((int.parse(onValue.documents[onValue.documents.length - 1]
                                  .documentID) %
                              9) +
                          1)
                      .toString()
                  : '0';
            },
          );
        },
      );
    }

    createRoomID();

    void del() async {
      Future<DocumentSnapshot> query =
          Firestore.instance.collection('roomDetails').document(gameID).get();
      await query.then(
        (onValue) {
          if (!onValue.exists) {
            onValue.reference.collection('users').getDocuments().then(
              (userval) {
                for (DocumentSnapshot ds in userval.documents) {
                  ds.reference.delete();
                }
              },
            );
            onValue.reference.collection('playerStatus').getDocuments().then(
              (userval) {
                for (DocumentSnapshot ds in userval.documents) {
                  ds.reference.delete();
                }
              },
            );
            onValue.reference.collection('responses').getDocuments().then(
              (userval) {
                for (DocumentSnapshot ds in userval.documents) {
                  ds.reference.delete();
                }
              },
            );
            onValue.reference.collection('selections').getDocuments().then(
              (userval) {
                for (DocumentSnapshot ds in userval.documents) {
                  ds.reference.delete();
                }
              },
            );
            onValue.reference.delete();
          }
        },
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue,
              Colors.cyan,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SizedBox(),
            Text(
              'Welcome!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: MediaQuery.of(context).size.height * 0.1,
                color: focus.hasFocus ? Colors.yellow : Colors.black,
                fontFamily: 'Indie-Flower',
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Theme(
                          data: ThemeData(
                            primaryColor: Colors.yellow,
                            cursorColor: Colors.yellow,
                          ),
                          child: TextField(
                            focusNode: focus,
                            maxLength: 15,
                            textCapitalization: TextCapitalization.words,
                            style: TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Indie-Flower',
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.04,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.tag_faces,
                              ),
                              counterText: '',
                              labelText: 'Who are you?',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.027,
                                fontFamily: 'Indie-Flower',
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              playerName = val;
                              if (!(playerName == null ||
                                  playerName.length == 0)) {
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
                  isButtonEnabled
                      ? AnimatedAlign(
                          onEnd: submitName,
                          curve: Curves.fastOutSlowIn,
                          alignment: align,
                          duration: Duration(seconds: 1),
                          child: FlatButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              // del();
                              setState(
                                () {
                                  align = Alignment.bottomRight;
                                },
                              );
                            },
                            child: Icon(
                              Icons.arrow_forward,
                              size: MediaQuery.of(context).size.height * 0.14,
                              color: Colors.yellow,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.14,
                        ),
                ],
              ),
            ),
            SizedBox(),
            SizedBox(),
            SizedBox(),
          ],
        ),
      ),
    );
  }
}
