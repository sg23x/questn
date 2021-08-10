import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:questn/UI/services/changeNavigationState.dart';

class StartTheGameButton extends StatefulWidget {
  StartTheGameButton({
    @required this.gameID,
    @required this.playerID,
    @required this.isPlayerPlural,
    @required this.gameMode,
    @required this.isAdmin,
    @required this.quesCount,
  });
  final String gameID;
  final String playerID;
  final bool isPlayerPlural;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;

  @override
  _StartTheGameButtonState createState() => _StartTheGameButtonState();
}

class _StartTheGameButtonState extends State<StartTheGameButton> {
  Alignment align;

  List playerNames = [];
  @override
  void initState() {
    align = Alignment.center;
    super.initState();
  }

  generateRandomIndex(int len) {
    Random rnd;
    int min = 0;
    int max = len;
    rnd = new Random();
    var r = min + rnd.nextInt(max - min);
    return r;
  }

  List getIndexes(int len, int n) {
    if (n == 1) {
      return [
        generateRandomIndex(
          len,
        ),
      ];
    } else if (n == 2) {
      List x = [];
      x.add(
        generateRandomIndex(
          len,
        ),
      );
      void test() {
        int newIndex = generateRandomIndex(
          len,
        );
        if (x.contains(newIndex)) {
          test();
        } else {
          x.add(newIndex);
        }
      }

      test();
      return x;
    }
  }

  String quesIndex() {
    return (generateRandomIndex(widget.quesCount) + 1).toString();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snap) {
        return StreamBuilder(
          builder: (context, usersnap) {
            return GestureDetector(
              onTap: widget.isPlayerPlural
                  ? () {
                      DocumentSnapshot questionRaw = snap.data;

                      List indexes =
                          getIndexes(usersnap.data.documents.length, 2);

                      String question = !questionRaw.data['question']
                              .contains('abc')
                          ? questionRaw.data['question'].replaceAll(
                              'xyz',
                              usersnap.data.documents[indexes[0]]['name'],
                            )
                          : questionRaw.data['question']
                              .replaceAll('xyz',
                                  usersnap.data.documents[indexes[0]]['name'])
                              .replaceAll(
                                'abc',
                                usersnap.data.documents[indexes[1]]['name'],
                              );

                      Firestore.instance
                          .collection('rooms')
                          .document(widget.gameID)
                          .updateData(
                        {
                          'currentQuestion': question,
                        },
                      );
                      changeNavigationStateToTrue(
                        gameID: widget.gameID,
                        field: 'isGameStarted',
                      );
                    }
                  : null,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                height: MediaQuery.of(context).size.height * 0.09,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Text(
                    widget.isPlayerPlural
                        ? 'CONTINUE'
                        : 'waiting for players..',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gotham-Book',
                      fontSize: MediaQuery.of(context).size.width * 0.07,
                    ),
                  ),
                ),
              ),
            );
          },
          stream: Firestore.instance
              .collection('rooms')
              .document(widget.gameID)
              .collection('users')
              .snapshots(),
        );
      },
      stream: Firestore.instance
          .collection('questions')
          .document('modes')
          .collection(widget.gameMode)
          .document(quesIndex())
          .snapshots(),
    );
  }
}
