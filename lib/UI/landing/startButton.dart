import 'package:flutter/material.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/waitingToStart/structure.dart';

class StartAGameButton extends StatelessWidget {
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
        "Start a Game",
      ),
      onPressed: () {
        joinGame();
      },
    );
  }
}
