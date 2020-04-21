import 'package:flutter/material.dart';
import 'package:psych/UI/waitingToStart/structure.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NameInputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String playerName;
    void submitName(String name) {
      Firestore.instance.collection("test").add(
        {
          "playerName": playerName,
        },
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => WaitingToStart(
            playerName: name,
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
              playerName != null
                  ? submitName(
                      playerName,
                    )
                  : null;
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
