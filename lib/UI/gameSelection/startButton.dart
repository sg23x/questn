import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/waitingToStart/structure.dart';
import 'dart:math';

class StartAGameButton extends StatefulWidget {
  StartAGameButton({@required this.playerName, @required this.gameID});
  final String playerName;
  final String gameID;

  @override
  _StartAGameButtonState createState() => _StartAGameButtonState();
}

class _StartAGameButtonState extends State<StartAGameButton> {
  Widget build(BuildContext context) {
    String generateUserCode() {
      Random rnd;
      int min = 100000000;
      int max = 999999999;
      rnd = new Random();
      var r = min + rnd.nextInt(max - min);
      return r.toString();
    }

    final String playerID = generateUserCode();

    void startGame() async {
      await Firestore.instance
          .collection('roomDetails')
          .document(widget.gameID)
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
          .document(widget.gameID)
          .setData(
        {
          'currentQuestion': '',
        },
      );

      await Firestore.instance
          .collection('roomDetails')
          .document(widget.gameID)
          .collection('responses')
          .document(playerID)
          .setData(
        {
          'hasSubmitted': false,
          'response': '',
        },
      );

      await Firestore.instance
          .collection('roomDetails')
          .document(widget.gameID)
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
          .document(widget.gameID)
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
            gameID: widget.gameID,
            playerID: playerID,
          ),
        ),
      );
    }

    return RaisedButton(
      child: Text(
        "Start a Game",
      ),
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
        // del();
        startGame();
      },
    );
  }
}
