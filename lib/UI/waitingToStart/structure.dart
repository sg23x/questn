import 'package:flutter/material.dart';

class WaitingToStart extends StatelessWidget {
  WaitingToStart({@required this.playerName});
  final String playerName;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Hello $playerName",
        ),
      ),
    );
  }
}
