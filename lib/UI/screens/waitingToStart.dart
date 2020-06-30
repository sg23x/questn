import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:psych/UI/constants.dart';
import 'package:psych/UI/services/backPressCall.dart';
import 'package:psych/UI/services/checkForGameEnd.dart';
import 'package:psych/UI/services/checkForNavigation.dart';
import 'package:psych/UI/widgets/customAppBar.dart';
import 'package:psych/UI/widgets/playerCard.dart';
import 'package:psych/UI/widgets/startTheGameButton.dart';

class WaitingToStart extends StatefulWidget {
  WaitingToStart({
    @required this.gameID,
    @required this.playerID,
    @required this.isAdmin,
    this.quesCount,
    this.gameMode,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;

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
          isInLobby: true,
        );
        checkForNavigation(
            quesCount: widget.quesCount,
            context: context,
            gameID: widget.gameID,
            playerID: widget.playerID,
            gameMode: widget.gameMode,
            isAdmin: widget.isAdmin,
            currentPage: 'WaitingToStart');
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: 1,
                        crossAxisCount: 2,
                      ),
                      itemBuilder: (context, i) {
                        return PlayerWaitingCard(
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
                                bottom:
                                    MediaQuery.of(context).size.height * 0.01,
                                top: MediaQuery.of(context).size.height * 0.01,
                              ),
                              width: MediaQuery.of(context).size.width * 0.96,
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
            .collection('users')
            .orderBy('timestamp')
            .snapshots(),
      ),
    );
  }
}
