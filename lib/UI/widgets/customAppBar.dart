import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:questn/UI/constants.dart';
import 'package:questn/UI/widgets/kickPlayerDialog.dart';

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
              icon: Image.asset(
                'assets/kick.png',
                color: Colors.white,
                scale: 20,
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
