import 'package:flutter/material.dart';
import 'package:psych/UI/gameSelection/structure.dart';

class NameInputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String playerName;

    void submitName() async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => GameSelection(
            playerName: playerName,
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "What's your name?",
          ),
          TextField(
            onChanged: (val) {
              playerName = val;
            },
          ),
          RaisedButton(
            child: Text(
              "Go!",
            ),
            onPressed: () {
              playerName != null ? submitName() : null;
            },
          ),
          SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }
}
