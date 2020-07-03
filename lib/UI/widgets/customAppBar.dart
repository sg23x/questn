import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psych/UI/constants.dart';
import 'package:psych/UI/widgets/kickPlayerDialog.dart';

Widget customAppBar({
  String gameID,
  String playerID,
  context,
  String title,
  bool isAdmin,
}) {
  return AppBar(
    elevation: 20,
    actions: [
      isAdmin
          ? IconButton(
              icon: Icon(
                Icons.remove_circle_outline,
              ),
              onPressed: () async {
                QuerySnapshot query = await Firestore.instance
                    .collection('rooms')
                    .document(
                      gameID,
                    )
                    .collection('users')
                    .getDocuments();
                showKickPlayerDialog(
                    context: context,
                    query: query,
                    playerID: playerID,
                    gameID: gameID);
              },
            )
          : SizedBox()
    ],
    backgroundColor: primaryColor,
    title: Text(
      title,
      style: TextStyle(
          fontSize: MediaQuery.of(context).size.width * 0.057,
          fontFamily: 'Gotham-Book'),
    ),
    centerTitle: true,
  );
}
