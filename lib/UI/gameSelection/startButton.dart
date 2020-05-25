import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitingToStart/structure.dart';
import 'dart:math';

class StartAGameButton extends StatefulWidget {
  StartAGameButton({
    @required this.playerName,
  });
  final String playerName;

  @override
  _StartAGameButtonState createState() => _StartAGameButtonState();
}

class _StartAGameButtonState extends State<StartAGameButton> {
  String gameID;
  Alignment axis;
  @override
  void initState() {
    gameID = '';
    axis = Alignment.lerp(
      Alignment.bottomCenter,
      Alignment.bottomLeft,
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
              Alignment.bottomRight,
              0.5,
            );
          },
        );
      },
    );

    final String playerID = generateUserCode();

    void startGame() async {
      await Firestore.instance
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
          'timestamp': Timestamp.now().millisecondsSinceEpoch.toString(),
        },
      );

      await Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .setData(
        {
          'currentQuestion': '',
          'timestamp': Timestamp.now().millisecondsSinceEpoch,
          'isGameStarted': false,
        },
      );

      Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .collection('responses')
          .document(playerID)
          .setData(
        {
          'hasSubmitted': false,
          'response': '',
        },
      );

      Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .collection('selections')
          .document(playerID)
          .setData(
        {
          'hasSelected': false,
          'selection': '',
        },
      );

      await Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .collection('playerStatus')
          .document(playerID)
          .setData(
        {
          'isReady': false,
        },
      );

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => WaitingToStart(
            gameID: gameID,
            playerID: playerID,
          ),
        ),
      );
    }

    void del() async {
      DocumentSnapshot query = await Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .get();

      if (query.exists) {
        await query.reference.collection('users').getDocuments().then(
          (onValue) {
            for (DocumentSnapshot ds in onValue.documents) {
              ds.reference.delete();
            }
          },
        );
        await query.reference.collection('playerStatus').getDocuments().then(
          (onValue) {
            for (DocumentSnapshot ds in onValue.documents) {
              ds.reference.delete();
            }
          },
        );
        await query.reference.collection('responses').getDocuments().then(
          (onValue) {
            for (DocumentSnapshot ds in onValue.documents) {
              ds.reference.delete();
            }
          },
        );
        await query.reference.collection('selections').getDocuments().then(
          (onValue) {
            for (DocumentSnapshot ds in onValue.documents) {
              ds.reference.delete();
            }
          },
        );
        await query.reference.delete();
      }
      startGame();
    }

    void createRoomID() async {
      QuerySnapshot query = await Firestore.instance
          .collection('roomDetails')
          .orderBy('timestamp')
          .getDocuments();

      setState(
        () {
          gameID = query.documents.length != 0
              ? query.documents.length.toString() ==
                      (int.parse(query.documents[query.documents.length - 1]
                                  .documentID) -
                              1000)
                          .toString()
                  ? ((int.parse(query.documents[query.documents.length - 1]
                                  .documentID) %
                              9999) +
                          1)
                      .toString()
                  : query.documents[0].documentID
              : '1001';
        },
      );

      del();
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
          createRoomID();
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
                'Start Game',
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
