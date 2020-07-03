import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/screens/gameSelection.dart';

void listenForGameResult({
  @required gameID,
  @required context,
  @required name,
}) {
  Firestore.instance.collection('rooms').document(gameID).snapshots().listen(
    (event) {
      if (event.data['isGameEnded'] == true) {
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.7),
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text('Score comes here'),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => GameSelection(
                          playerName: name,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Go back",
                  ),
                ),
              ],
            );
          },
        );
      }
    },
  );
}
