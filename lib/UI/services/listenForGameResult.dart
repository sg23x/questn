import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/screens/gameSelection.dart';

void listenForGameResult({
  @required gameID,
  @required context,
  @required name,
}) {
  Firestore.instance.collection('rooms').document(gameID).snapshots().listen(
    (event) async {
      if (event.data['isGameEnded'] == true) {
        QuerySnapshot query = await Firestore.instance
            .collection('rooms')
            .document(gameID)
            .collection('users')
            .getDocuments();
        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.8),
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                content: Container(
                  width: 100,
                  height: 100,
                  child: ListView.builder(
                    itemCount: query.documents.length,
                    itemBuilder: (context, i) {
                      return Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(query.documents[i].data['name']),
                            Text(query.documents[i].data['score'].toString()),
                          ],
                        ),
                      );
                    },
                    shrinkWrap: true,
                  ),
                ),
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
              ),
            );
          },
        );
      }
    },
  );
}
