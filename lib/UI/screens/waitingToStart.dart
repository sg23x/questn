import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:questn/UI/constants.dart';
import 'package:questn/UI/screens/questionsPage.dart';
import 'package:questn/UI/services/checkForGameEnd.dart';
import 'package:questn/UI/services/deletePlayer.dart';
import 'package:questn/UI/widgets/customAppBar.dart';
import 'package:questn/UI/widgets/playerCard.dart';
import 'package:questn/UI/widgets/startTheGameButton.dart';

class WaitingToStart extends StatefulWidget {
  WaitingToStart({
    @required this.gameID,
    @required this.playerID,
    @required this.isAdmin,
    @required this.playerName,
    this.quesCount,
    this.gameMode,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  final String playerName;

  @override
  _WaitingToStartState createState() => _WaitingToStartState();
}

class _WaitingToStartState extends State<WaitingToStart> {
  List<String> avatarList = [
    'assets/avatars/avatar1.png',
    'assets/avatars/avatar2.png',
    'assets/avatars/avatar3.png',
    'assets/avatars/avatar4.png',
    'assets/avatars/avatar5.png',
    'assets/avatars/avatar6.png',
    'assets/avatars/avatar7.png',
    'assets/avatars/avatar8.png',
  ];
  int round;
  bool abc = true;

  @override
  Widget build(BuildContext context) {
    getRounds() {
      Firestore.instance.collection('rooms').document(widget.gameID).get().then(
        (value) {
          setState(
            () {
              round = value.data['rounds'] - 1;
            },
          );
        },
      );
    }

    avatarList.shuffle();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        checkForGameEnd(
          context: context,
          gameID: widget.gameID,
          playerID: widget.playerID,
          isInLobby: true,
        );

        if (abc) {
          getRounds();
          abc = false;
        }
      },
    );

    Future<bool> onBackPressed() {
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
                    onPressed: widget.isAdmin
                        ? () {
                            Navigator.pop(context);
                            Firestore.instance
                                .collection('rooms')
                                .document(widget.gameID)
                                .collection('users')
                                .getDocuments()
                                .then(
                              (value) {
                                for (DocumentSnapshot ds in value.documents) {
                                  ds.reference.delete();
                                }
                              },
                            );
                          }
                        : () async {
                            deletePlayer(
                                id: widget.playerID, gameID: widget.gameID);
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
                  widget.isAdmin
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

    return WillPopScope(
      onWillPop: onBackPressed,
      child: StreamBuilder(
        builder: (context, snap) {
          if (!snap.hasData) {
            return Scaffold();
          }

          return StreamBuilder(
            builder: (context, roomsnap) {
              if (!roomsnap.hasData) {
                return Scaffold();
              }

              WidgetsBinding.instance.addPostFrameCallback(
                (_) async {
                  if (roomsnap.data['isGameStarted'] == true) {
                    HapticFeedback.vibrate();

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext newcontext) => QuestionsPage(
                          quesCount: widget.quesCount,
                          playerID: widget.playerID,
                          gameID: widget.gameID,
                          gameMode: widget.gameMode,
                          isAdmin: widget.isAdmin,
                          avatarList: avatarList,
                          round: round,
                          playerName: widget.playerName,
                        ),
                      ),
                    );
                  }
                },
              );

              return Scaffold(
                appBar: customAppBar(
                  context: context,
                  gameID: widget.gameID,
                  isAdmin: widget.isAdmin,
                  playerID: widget.playerID,
                  title: 'GAME ID: ${widget.gameID}',
                ),
                body: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      end: Alignment.bottomCenter,
                      begin: Alignment.topCenter,
                      stops: [0.0, 0.8],
                      colors: [
                        secondaryColor,
                        primaryColor,
                      ],
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1,
                            crossAxisCount: 2,
                          ),
                          itemBuilder: (context, i) {
                            return PlayerWaitingCard(
                              scale: 1,
                              avatarList: avatarList,
                              playersCount: snap.data.documents.length,
                              borderColor: Colors.transparent,
                              cardIndex: i,
                              name: snap.data.documents[i]['name'],
                            );
                          },
                          shrinkWrap: true,
                          itemCount: snap.data.documents.length,
                        ),
                      ),
                      snap.data.documents.length != 0
                          ? widget.isAdmin
                              ? StartTheGameButton(
                                  quesCount: widget.quesCount,
                                  isAdmin: widget.isAdmin,
                                  gameID: widget.gameID,
                                  playerID: widget.playerID,
                                  isPlayerPlural: snap.data.documents.length > 1
                                      ? true
                                      : false,
                                  gameMode: widget.gameMode,
                                )
                              : Container(
                                  color: Colors.black.withOpacity(0.7),
                                  height:
                                      MediaQuery.of(context).size.height * 0.09,
                                  width: MediaQuery.of(context).size.width,
                                  child: Center(
                                    child: Text(
                                      'waiting to start..',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Gotham-Book',
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.07,
                                      ),
                                    ),
                                  ),
                                )
                          : SizedBox(),
                    ],
                  ),
                ),
              );
            },
            stream: Firestore.instance
                .collection('rooms')
                .document(widget.gameID)
                .snapshots(),
          );
        },
        stream: Firestore.instance
            .collection('rooms')
            .document(widget.gameID)
            .collection('users')
            .orderBy('timestamp')
            .snapshots(),
      ),
    );
  }
}
