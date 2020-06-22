import 'package:flutter/material.dart';
import 'package:psych/UI/screens/nameInput.dart';
import 'package:psych/UI/widgets/joinButton.dart';
import 'package:psych/UI/widgets/startButton.dart';

class GameSelection extends StatelessWidget {
  GameSelection({
    @required this.playerName,
  });
  final String playerName;

  Widget build(BuildContext context) {
    void _onBackPressed() {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => NameInputPage(),
          ),
          (route) => false);
    }

    return WillPopScope(
      onWillPop: () {
        _onBackPressed();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue,
                Colors.cyan,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              JoinGameButton(
                playerName: playerName,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              StartAGameButton(
                playerName: playerName,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
