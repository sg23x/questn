import 'package:flutter/material.dart';
import 'package:psych/UI/landing/joinButton.dart';
import 'package:psych/UI/landing/startButton.dart';

class LandingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              JoinGameButton(),
              StartAGameButton(),
            ],
          ),
        ],
      ),
    );
  }
}
