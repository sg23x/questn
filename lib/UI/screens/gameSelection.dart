import 'package:flutter/material.dart';
import 'package:questn/UI/constants.dart';
import 'package:questn/UI/screens/nameInput.dart';
import 'package:questn/UI/widgets/joinButton.dart';
import 'package:questn/UI/widgets/startButton.dart';

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
        backgroundColor: primaryColor,
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/back.png'),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                JoinGameButton(playerName: playerName),
                StartAGameButton(playerName: playerName),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
