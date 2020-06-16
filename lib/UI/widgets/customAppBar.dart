import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Widget customAppBar({
  String gameID,
  String playerID,
  context,
  String title,
  bool isAdmin,
}) {
  void deletePlayer(String id) async {
    await Firestore.instance
        .collection('roomDetails')
        .document(gameID)
        .collection('users')
        .document(id)
        .delete();
  }

  return AppBar(
    actions: [
      StreamBuilder(
        builder: (context, kicksnap) {
          if (!kicksnap.hasData) {
            return SizedBox();
          }

          return isAdmin
              ? IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentTextStyle: TextStyle(
                            fontFamily: 'Indie-Flower',
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.025,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ),
                          ),
                          actions: <Widget>[],
                          content: Container(
                            height: (MediaQuery.of(context).size.height / 10) +
                                (MediaQuery.of(context).size.height *
                                    0.08 *
                                    kicksnap.data.documents.length),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Text(
                                  'Kick player:',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.08,
                                  ),
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: kicksnap.data.documents.length,
                                  itemBuilder: (context, i) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (kicksnap.data.documents[i]
                                                ['userID'] !=
                                            playerID) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop(false);
                                                    },
                                                    child: Text(
                                                      "NO",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Indie-Flower',
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                      ),
                                                    ),
                                                  ),
                                                  FlatButton(
                                                    onPressed: () {
                                                      deletePlayer(
                                                        kicksnap.data
                                                                .documents[i]
                                                            ['userID'],
                                                      );
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "YES",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Indie-Flower',
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                        color: Colors.pink,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                content: Text(
                                                  "You sure you wanna kick " +
                                                      kicksnap.data.documents[i]
                                                          ['name'],
                                                  style: TextStyle(
                                                    fontFamily: 'Indie-Flower',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.06,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      "OK",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Indie-Flower',
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                        color: Colors.pink,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                content: Text(
                                                  "You can't kick yourself!",
                                                  style: TextStyle(
                                                    fontFamily: 'Indie-Flower',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.06,
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }
                                      },
                                      child: Card(
                                        child: Container(
                                          height: 50,
                                          child: Center(
                                            child: Text(
                                              kicksnap.data.documents[i]
                                                  ['name'],
                                              style: TextStyle(
                                                fontSize: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                )
              : SizedBox();
        },
        stream: Firestore.instance
            .collection('roomDetails')
            .document(
              gameID,
            )
            .collection('users')
            .orderBy(
              'timestamp',
            )
            .snapshots(),
      ),
    ],
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue,
            Colors.cyan,
          ],
        ),
      ),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: MediaQuery.of(context).size.height * 0.03,
        fontWeight: FontWeight.w500,
      ),
    ),
    centerTitle: true,
  );
}
