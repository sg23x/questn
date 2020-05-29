import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/QuestionsPage/structure.dart';
import 'package:psych/UI/nameInput/structure.dart';
import 'package:psych/UI/waitingToStart/playerCard.dart';
import 'package:psych/UI/waitingToStart/startTheGameButton.dart';
import 'package:psych/UI/widgets/customAppBar.dart';

class WaitingToStart extends StatefulWidget {
  WaitingToStart({
    @required this.gameID,
    @required this.playerID,
  });
  final String gameID;
  final String playerID;

  @override
  _WaitingToStartState createState() => _WaitingToStartState();
}

class _WaitingToStartState extends State<WaitingToStart> {
  @override
  Widget build(BuildContext context) {
    void deletePlayer(String id) async {
      await Firestore.instance
          .collection('roomDetails')
          .document(widget.gameID)
          .collection('users')
          .document(id)
          .delete();
    }

    Future<bool> _onBackPressed() {
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
                    onPressed: () {
                      deletePlayer(widget.playerID);
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
                  "You sure you wanna leave the game?",
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

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        Firestore.instance
            .collection('roomDetails')
            .document(widget.gameID)
            .collection('users')
            .reference()
            .snapshots()
            .listen(
          (event) {
            if (event.documents
                    .where(
                      (element) => element.documentID == widget.playerID,
                    )
                    .toList()
                    .length !=
                1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => NameInputPage(),
                ),
              );
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
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "OK",
                          style: TextStyle(
                            fontFamily: 'Indie-Flower',
                            color: Colors.pink,
                            fontWeight: FontWeight.w900,
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                          ),
                        ),
                      )
                    ],
                    content: Text(
                      "The game has ended!",
                    ),
                  );
                },
              );
            }
          },
        );
      },
    );

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: StreamBuilder(
        builder: (context, snap) {
          if (!snap.hasData) {
            return Scaffold();
          }

          if (snap.data.documents.every(
                (x) => x['isReady'] == true,
              ) &&
              snap.data.documents.length != 0) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => QuestionsPage(
                      playerID: widget.playerID,
                      gameID: widget.gameID,
                    ),
                  ),
                );
              },
            );
          }
          return StreamBuilder(
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Scaffold();
              }

              return Scaffold(
                appBar: customAppBar(
                  widget.gameID,
                  widget.playerID,
                  context,
                  'GAME ID: ${widget.gameID}',
                ),
                body: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, i) {
                          return PlayerWaitingCard(
                            animationIndex: i,
                            colorList: i % 2 == 0
                                ? [
                                    Colors.cyan,
                                    Colors.blue,
                                  ]
                                : [
                                    Colors.blue,
                                    Colors.cyan,
                                  ],
                            name: snap.data.documents.length != 0
                                ? snap.data.documents[i]['name']
                                : '',
                          );
                        },
                        shrinkWrap: true,
                        itemCount: snap.data.documents.length,
                      ),
                    ),
                    snap.data.documents.length != 0
                        ? widget.playerID == snapshot.data['admin']
                            ? StartTheGameButton(
                                gameID: widget.gameID,
                                playerID: widget.playerID,
                                isPlayerPlural: snap.data.documents.length > 1
                                    ? true
                                    : false,
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "Waiting to start...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Indie-Flower',
                                    fontWeight: FontWeight.w900,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.03,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black,
                                      Colors.grey,
                                    ],
                                  ),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                margin: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).size.height * 0.01,
                                  top:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                width: MediaQuery.of(context).size.width * 0.96,
                              )
                        : SizedBox(),
                  ],
                ),
              );
            },
            stream: Firestore.instance
                .collection('roomDetails')
                .document(widget.gameID)
                .snapshots(),
          );
        },
        stream: Firestore.instance
            .collection('roomDetails')
            .document(widget.gameID)
            .collection('users')
            .orderBy(
              'timestamp',
            )
            .snapshots(),
      ),
    );
  }
}
