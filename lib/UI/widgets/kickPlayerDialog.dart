import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:questn/UI/constants.dart';
import 'package:questn/UI/services/deletePlayer.dart';

showKickPlayerDialog(
    {@required context,
    @required QuerySnapshot query,
    @required String playerID,
    @required String gameID}) {
  showDialog(
    barrierColor: Colors.black.withOpacity(0.8),
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            5,
          ),
        ),
        actions: <Widget>[],
        content: Container(
          height: (MediaQuery.of(context).size.height / 12) +
              (MediaQuery.of(context).size.height *
                  0.08 *
                  query.documents.length),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Text(
                'Kick player:',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.height * 0.04,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Gotham-Book',
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: query.documents.length,
                itemBuilder: (context, i) {
                  return GestureDetector(
                    onTap: () {
                      if (query.documents[i]['userID'] != playerID) {
                        showDialog(
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
                                      fontWeight: FontWeight.w900,
                                      color: primaryColor,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                  ),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    deletePlayer(
                                      id: query.documents[i]['userID'],
                                      gameID: gameID,
                                    );
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "YES",
                                    style: TextStyle(
                                      fontFamily: 'Gotham-Book',
                                      fontWeight: FontWeight.w900,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ),
                              ],
                              content: Container(
                                width: MediaQuery.of(context).size.width * 0.62,
                                child: Text(
                                  "Are you sure you want to kick " +
                                      query.documents[i]['name'] +
                                      '?',
                                  style: TextStyle(
                                    fontFamily: 'Gotham-Book',
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                  ),
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
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "OK",
                                    style: TextStyle(
                                      fontFamily: 'Gotham-Book',
                                      fontWeight: FontWeight.w900,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ),
                              ],
                              content: Container(
                                width: MediaQuery.of(context).size.width * 0.62,
                                child: Text(
                                  "You can't kick yourself!",
                                  style: TextStyle(
                                    fontFamily: 'Gotham-Book',
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 3,
                        ),
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.only(bottom: 10),
                      width: MediaQuery.of(context).size.width * 0.7,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: Center(
                        child: Text(
                          query.documents[i]['name'],
                          style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.035,
                            color: Colors.white,
                            fontFamily: 'Gotham-Book',
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
}
