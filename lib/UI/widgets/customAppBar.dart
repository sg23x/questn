import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:psych/UI/constants.dart';

Widget customAppBar({
  String gameID,
  String playerID,
  context,
  String title,
  bool isAdmin,
}) {
  void deletePlayer(String id) async {
    await Firestore.instance
        .collection('rooms')
        .document(gameID)
        .collection('users')
        .document(id)
        .delete();
  }

  return AppBar(
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

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      contentTextStyle: TextStyle(
                        fontFamily: 'Indie-Flower',
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: MediaQuery.of(context).size.height * 0.025,
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
                                query.documents.length),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            Text(
                              'Kick player:',
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.08,
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: query.documents.length,
                              itemBuilder: (context, i) {
                                return GestureDetector(
                                  onTap: () {
                                    if (query.documents[i]['userID'] !=
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
                                                    fontFamily: 'Indie-Flower',
                                                    fontWeight: FontWeight.w900,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                  ),
                                                ),
                                              ),
                                              FlatButton(
                                                onPressed: () {
                                                  deletePlayer(
                                                    query.documents[i]
                                                        ['userID'],
                                                  );
                                                  Navigator.pop(context);
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "YES",
                                                  style: TextStyle(
                                                    fontFamily: 'Indie-Flower',
                                                    fontWeight: FontWeight.w900,
                                                    fontSize:
                                                        MediaQuery.of(context)
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
                                                  query.documents[i]['name'],
                                              style: TextStyle(
                                                fontFamily: 'Indie-Flower',
                                                fontWeight: FontWeight.w400,
                                                fontSize: MediaQuery.of(context)
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
                                                    fontFamily: 'Indie-Flower',
                                                    fontWeight: FontWeight.w900,
                                                    fontSize:
                                                        MediaQuery.of(context)
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
                                                fontSize: MediaQuery.of(context)
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
                                          query.documents[i]['name'],
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
          : SizedBox()
    ],
    backgroundColor: primaryColor,
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
