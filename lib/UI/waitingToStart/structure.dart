import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psych/UI/QuestionsPage/structure.dart';
import 'package:psych/UI/functionCalls/backPressCall.dart';
import 'package:psych/UI/functionCalls/checkForGameEnd.dart';
import 'package:psych/UI/waitingToStart/playerCard.dart';
import 'package:psych/UI/waitingToStart/startTheGameButton.dart';
import 'package:psych/UI/widgets/customAppBar.dart';

class WaitingToStart extends StatefulWidget {
  WaitingToStart({
    @required this.gameID,
    @required this.playerID,
    @required this.isAdmin,
    this.gameMode,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;

  @override
  _WaitingToStartState createState() => _WaitingToStartState();
}

class _WaitingToStartState extends State<WaitingToStart> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        checkForGameEnd(
          context: context,
          gameID: widget.gameID,
          playerID: widget.playerID,
        );
      },
    );

    return WillPopScope(
      onWillPop: () => onBackPressed(
        context: context,
        gameID: widget.gameID,
        isAdmin: widget.isAdmin,
        playerID: widget.playerID,
      ),
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
                HapticFeedback.vibrate();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => QuestionsPage(
                      playerID: widget.playerID,
                      gameID: widget.gameID,
                      gameMode: widget.gameMode,
                      isAdmin: widget.isAdmin,
                    ),
                  ),
                );
              },
            );
          }

          return Scaffold(
            appBar: customAppBar(
              context: context,
              gameID: widget.gameID,
              isAdmin: widget.isAdmin,
              playerID: widget.playerID,
              title: 'GAME ID: ${widget.gameID}',
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
                    ? widget.isAdmin
                        ? StartTheGameButton(
                            gameID: widget.gameID,
                            playerID: widget.playerID,
                            isPlayerPlural:
                                snap.data.documents.length > 1 ? true : false,
                            gameMode: widget.gameMode,
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
                                    MediaQuery.of(context).size.height * 0.03,
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
                            height: MediaQuery.of(context).size.height * 0.1,
                            margin: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.height * 0.01,
                              top: MediaQuery.of(context).size.height * 0.01,
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
            .collection('users')
            .orderBy(
              'timestamp',
            )
            .snapshots(),
      ),
    );
  }
}
