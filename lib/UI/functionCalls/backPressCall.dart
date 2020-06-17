import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> onBackPressed({
  context,
  isAdmin,
  gameID,
  playerID,
}) {
  return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text(
                  "NO",
                  style: TextStyle(
                    fontFamily: 'Indie-Flower',
                    fontWeight: FontWeight.w900,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                  ),
                ),
              ),
              FlatButton(
                onPressed: () async {
                  isAdmin
                      ? await Firestore.instance
                          .collection('roomDetails')
                          .document(gameID)
                          .collection('users')
                          .getDocuments()
                          .then(
                          (snapshot) {
                            for (DocumentSnapshot ds in snapshot.documents) {
                              ds.reference.delete();
                            }
                          },
                        )
                      : await Firestore.instance
                          .collection('roomDetails')
                          .document(gameID)
                          .collection('users')
                          .document(playerID)
                          .delete();
                },
                child: Text(
                  "YES",
                  style: TextStyle(
                    fontFamily: 'Indie-Flower',
                    fontWeight: FontWeight.w900,
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    color: Colors.pink,
                  ),
                ),
              ),
            ],
            content: Text(
              isAdmin
                  ? "You sure you wanna end the game?"
                  : "You sure you wanna leave the game?",
              style: TextStyle(
                fontFamily: 'Indie-Flower',
                fontWeight: FontWeight.w400,
                fontSize: MediaQuery.of(context).size.width * 0.06,
              ),
            ),
          );
        },
      ) ??
      false;
}
