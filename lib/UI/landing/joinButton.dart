import 'package:flutter/material.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/waitingToStart/structure.dart';

class JoinGameButton extends StatelessWidget {
  Widget build(BuildContext context) {
    void joinGame() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => NameInputPage(),
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
