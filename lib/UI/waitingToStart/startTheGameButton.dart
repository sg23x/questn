import 'package:flutter/material.dart';
import 'package:psych/UI/gameStarted/structure.dart';

class StartTheGameButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      child: Text(
        "Start Game",
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => GameStart(),
          ),
        );
      },
    );
  }
}
