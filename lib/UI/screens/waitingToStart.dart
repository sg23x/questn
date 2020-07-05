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
  List<AssetImage> avatarList = [
    AssetImage('assets/avatars/avatar1.png'),
    AssetImage('assets/avatars/avatar2.png'),
    AssetImage('assets/avatars/avatar3.png'),
    AssetImage('assets/avatars/avatar4.png'),
    AssetImage('assets/avatars/avatar5.png'),
    AssetImage('assets/avatars/avatar6.png'),
    AssetImage('assets/avatars/avatar7.png'),
    AssetImage('assets/avatars/avatar8.png'),
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
              round = value.data['rounds'];
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
        checkForNavigation(
          quesCount: widget.quesCount,
          context: context,
          gameID: widget.gameID,
          playerID: widget.playerID,
          gameMode: widget.gameMode,
          isAdmin: widget.isAdmin,
          currentPage: 'WaitingToStart',
          avatarList: avatarList,
          round: round,
        );
        if (abc) {
          getRounds();
          abc = false;
        }
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
                              isPlayerPlural:
                                  snap.data.documents.length > 1 ? true : false,
                              gameMode: widget.gameMode,
                            )
                          : Container(
                              color: Colors.black.withOpacity(0.7),
                              height: MediaQuery.of(context).size.height * 0.09,
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
            .collection('users')
            .orderBy('timestamp')
            .snapshots(),
      ),
    );
  }
}
