import 'package:flutter/material.dart';
import 'package:psych/UI/gameSelection/joinButton.dart';
import 'package:psych/UI/gameSelection/startButton.dart';

class GameSelection extends StatelessWidget {
  GameSelection({
    @required this.playerName,
  });
  final String playerName;
  Widget build(BuildContext context) {
    return Scaffold(
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
