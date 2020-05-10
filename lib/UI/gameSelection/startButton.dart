import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitingToStart/structure.dart';
import 'dart:math';

class StartAGameButton extends StatefulWidget {
  StartAGameButton({
    @required this.playerName,
    @required this.gameID,
  });
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
          'timestamp': Timestamp.now().millisecondsSinceEpoch,
        },
      );

      Firestore.instance
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

      Firestore.instance
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

    void del() async {
      DocumentSnapshot query = await Firestore.instance
          .collection('roomDetails')
          .document(widget.gameID)
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

    return Row(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.2,
        ),
        RaisedButton(
          elevation: 15,
          color: Colors.transparent,
          padding: EdgeInsets.all(
            0,
          ),
          onPressed: () {},
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
      ],
    );
  }
}

// showDialog(
//   context: context,
//   barrierDismissible: false,
//   builder: (BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         CircularProgressIndicator(
//           backgroundColor: Colors.pink,
//           strokeWidth: 8,
//         ),
//       ],
//     );
//   },
// );
// del();
