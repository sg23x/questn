import 'package:flutter/material.dart';

class WaitForSubmissions extends StatelessWidget {
  WaitForSubmissions({@required this.gameID, @required this.playerID});
  final String gameID;
  final String playerID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Your response has been recorded!",
        ),
      ),
    );
  }
}
