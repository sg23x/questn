import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:questn/UI/constants.dart';
import 'package:questn/UI/services/deletePlayer.dart';

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
                    fontFamily: 'Gotham-Book',
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    color: primaryColor,
                  ),
                ),
              ),
              FlatButton(
                onPressed: isAdmin
                    ? () {
                        Navigator.pop(context);
                        Firestore.instance
                            .collection('rooms')
                            .document(gameID)
                            .updateData(
                          {'isGameEnded': true},
                        );
                      }
                    : () async {
                        deletePlayer(id: playerID, gameID: gameID);
                      },
                child: Text(
                  "YES",
                  style: TextStyle(
                    fontFamily: 'Gotham-Book',
                    fontWeight: FontWeight.w900,
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    color: secondaryColor,
                  ),
                ),
              ),
            ],
            content: Text(
              isAdmin
                  ? "Are you sure you want to end the game?"
                  : "Are you sure you want to leave the game?",
              style: TextStyle(
                fontFamily: 'Gotham-Book',
                fontSize: MediaQuery.of(context).size.width * 0.05,
              ),
            ),
          );
        },
      ) ??
      false;
}
