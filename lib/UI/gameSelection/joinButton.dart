import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/gameIDInput/structure.dart';
import 'package:psych/UI/gameSelection/structure.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/waitingToStart/structure.dart';

class JoinGameButton extends StatelessWidget {
  JoinGameButton({
    @required this.playerName,
  });
  final String playerName;
  Widget build(BuildContext context) {
    void joinGame() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => GameIDInput(
            playerName: playerName,
          ),
        ),
      );
    }

    return RaisedButton(
      child: Text(
        "Join Game",
      ),
      onPressed: () {
        joinGame();
      },
    );
  }
}
