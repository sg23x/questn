import 'package:flutter/material.dart';
import 'package:psych/UI/gameSelection/joinButton.dart';
import 'package:psych/UI/gameSelection/startButton.dart';
import 'package:psych/UI/nameInput/structure.dart';

class GameSelection extends StatelessWidget {
  GameSelection({
    @required this.playerName,
    @required this.gameID,
  });
  final String playerName;
  final String gameID;
  Widget build(BuildContext context) {
    Future<bool> _onBackPressed() {
      return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      "NO",
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => NameInputPage(),
                        ),
                      );
                    },
                    child: Text(
                      "YES",
                    ),
                  ),
                ],
                content: Text(
                  "You sure you wanna leave the game?",
                ),
              );
            },
          ) ??
          false;
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                JoinGameButton(
                  playerName: playerName,
                ),
                StartAGameButton(
                  playerName: playerName,
                  gameID: gameID,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
