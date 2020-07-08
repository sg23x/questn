import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/constants.dart';
import 'package:psych/UI/screens/gameSelection.dart';

void listenForGameResult({
  @required gameID,
  @required context,
  @required name,
}) {
  bool flag = true;
  Firestore.instance.collection('rooms').document(gameID).snapshots().listen(
    (event) async {
      if (event.data['isGameEnded'] == true && flag) {
        QuerySnapshot query = await Firestore.instance
            .collection('rooms')
            .document(gameID)
            .collection('users')
            .orderBy('score', descending: true)
            .getDocuments();

        showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black.withOpacity(0.8),
          builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: secondaryColor, width: 2),
                ),
                contentPadding: EdgeInsets.all(0),
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: (MediaQuery.of(context).size.height * 0.15) +
                      MediaQuery.of(context).size.height *
                          0.07 *
                          query.documents.length,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'GAME OVER!',
                        style: TextStyle(
                            fontFamily: 'Gotham-Book',
                            fontSize: MediaQuery.of(context).size.width * 0.07,
                            decoration: TextDecoration.underline),
                      ),
                      ListView.builder(
                        itemCount: query.documents.length,
                        itemBuilder: (context, i) {
                          return Container(
                            margin: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).size.height * 0.02),
                            padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.05,
                              right: MediaQuery.of(context).size.width * 0.01,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  query.documents[i].data['name'],
                                  style: TextStyle(
                                      fontFamily: 'Gotham-Book',
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.06),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.09,
                                  child: Center(
                                    child: Text(
                                      query.documents[i].data['score']
                                          .toString(),
                                      style: TextStyle(
                                          fontFamily: 'Gotham-Book',
                                          color: secondaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.06),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        shrinkWrap: true,
                      ),
                    ],
                  ),
                ),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text(
                      "Go back",
                      style: TextStyle(
                          fontFamily: 'Gotham-Book',
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04),
                    ),
                  ),
                ],
              ),
            );
          },
        );
        flag = false;
      }
    },
  );
}
