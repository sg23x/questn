import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/constants.dart';
import 'package:psych/UI/services/backPressCall.dart';
import 'package:psych/UI/services/changeNavigationState.dart';
import 'package:psych/UI/services/checkForGameEnd.dart';
import 'package:psych/UI/services/checkForNavigation.dart';
import 'package:psych/UI/services/listenForGameResult.dart';
import 'dart:math';
import 'package:psych/UI/widgets/customAppBar.dart';
import 'package:psych/UI/widgets/playerCard.dart';
import 'package:psych/UI/widgets/responseCard.dart';

class WaitForReady extends StatefulWidget {
  WaitForReady({
    @required this.gameID,
    @required this.playerID,
    @required this.gameMode,
    @required this.isAdmin,
    @required this.quesCount,
    @required this.avatarList,
    @required this.round,
    @required this.playerName,
  });
  final String gameID;
  final String playerID;
  final String gameMode;
  final bool isAdmin;
  final int quesCount;
  final List avatarList;
  final int round;
  final String playerName;

  @override
  _WaitForReadyState createState() => _WaitForReadyState();
}

class _WaitForReadyState extends State<WaitForReady> {
  bool isReadyButtonEnabled;
  generateRandomIndex(int len) {
    Random rnd;
    int min = 0;
    int max = len;
    rnd = new Random();
    var r = min + rnd.nextInt(max - min);
    return r;
  }

  String quesIndex() {
    return (generateRandomIndex(widget.quesCount) + 1).toString();
  }

  void checkForRoundsComplete() {
    if (widget.isAdmin) {
      if (widget.round == 0) {
        Firestore.instance
            .collection('rooms')
            .document(widget.gameID)
            .updateData(
          {'isGameEnded': true},
        );
      }
    }
  }

  @override
  void initState() {
    isReadyButtonEnabled = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        checkForGameEnd(
          context: context,
          gameID: widget.gameID,
          playerID: widget.playerID,
        );
        checkForNavigation(
          quesCount: widget.quesCount,
          context: context,
          gameID: widget.gameID,
          playerID: widget.playerID,
          gameMode: widget.gameMode,
          isAdmin: widget.isAdmin,
          currentPage: 'WaitForReady',
          avatarList: widget.avatarList,
          round: widget.round,
          playerName: widget.playerName,
        );
        changeNavigationStateToTrue(
          gameID: widget.gameID,
          field: 'isReady',
          playerField: 'isReady',
        );

        checkForRoundsComplete();
        Timer(
          Duration(milliseconds: 3500),
          () {
            listenForGameResult(
              gameID: widget.gameID,
              context: context,
              name: widget.playerName,
            );
          },
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
        stream: Firestore.instance
            .collection('rooms')
            .document(widget.gameID)
            .collection('users')
            .snapshots(),
        builder: (context, snappp) {
          if (!snappp.hasData) {
            return SizedBox();
          }
          return AbsorbPointer(
            absorbing: widget.round == 0 ? true : false,
            child: Scaffold(
              appBar: customAppBar(
                context: context,
                gameID: widget.gameID,
                isAdmin: widget.isAdmin,
                playerID: widget.playerID,
                title: 'Rounds left: ' + widget.round.toString(),
              ),
              body: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                ),
                child: Stack(
                  children: [
                    ListView(
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                        snappp.data.documents
                                    .where(
                                      (x) => x['selection'] == widget.playerID,
                                    )
                                    .toList()
                                    .length !=
                                0
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Players who chose your answer:",
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.047,
                                      color: Colors.white,
                                      fontFamily: 'Gotham-Book',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(),
                        snappp.data.documents
                                    .where(
                                      (x) => x['selection'] == widget.playerID,
                                    )
                                    .toList()
                                    .length !=
                                0
                            ? Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.28,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, i) {
                                    return PlayerWaitingCard(
                                        scale: 0.8,
                                        name: snappp.data.documents
                                            .where((x) =>
                                                x['selection'] ==
                                                widget.playerID)
                                            .toList()[i]['name'],
                                        cardIndex: i,
                                        borderColor: secondaryColor,
                                        playersCount:
                                            snappp.data.documents.length,
                                        avatarList: widget.avatarList);
                                  },
                                  itemCount: snappp.data.documents
                                      .where(
                                        (x) =>
                                            x['selection'] == widget.playerID,
                                      )
                                      .toList()
                                      .length,
                                  shrinkWrap: true,
                                ),
                              )
                            : SizedBox(),
                        Row(
                          children: <Widget>[
                            Text(
                              "TIMES SELECTED:",
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.055,
                                color: Colors.white,
                                fontFamily: 'Gotham-Book',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            return Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  child: ResponseCard(
                                    response: snappp.data.documents[i]
                                        ['response'],
                                    borderColor: Colors.white,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    child: Center(
                                      child: Text(
                                        snappp.data.documents
                                            .where(
                                              (x) =>
                                                  x['selection'] ==
                                                  snappp.data.documents[i]
                                                      .documentID,
                                            )
                                            .toList()
                                            .length
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Gotham-Book',
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.082),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          shrinkWrap: true,
                          itemCount: snappp.data.documents.length,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.03,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              "SCORE:",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Gotham-Book',
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.055,
                              ),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.center,
                        ),
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, ind) {
                            return Row(
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.75,
                                  child: ResponseCard(
                                    response: snappp.data.documents[ind]
                                        ['name'],
                                    borderColor: snappp.data.documents[ind]
                                            ['isReady']
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right:
                                          MediaQuery.of(context).size.height *
                                              0.02,
                                    ),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            snappp.data.documents[ind]['score']
                                                .toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Gotham-Book',
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.082),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.008,
                                          ),
                                          Text(
                                            '(+' +
                                                snappp.data.documents
                                                    .where(
                                                      (x) =>
                                                          x['selection'] ==
                                                          snappp
                                                              .data
                                                              .documents[ind]
                                                              .documentID,
                                                    )
                                                    .toList()
                                                    .length
                                                    .toString() +
                                                ')',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Gotham-Book',
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.052),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          itemCount: snappp.data.documents.length,
                          shrinkWrap: true,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.11,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.09,
                            color: Colors.black.withOpacity(0.8),
                            child: Center(
                              child: Text(
                                isReadyButtonEnabled
                                    ? 'R E A D Y ?'
                                    : 'waiting for others..',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isReadyButtonEnabled
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  backgroundColor: Colors.black,
                                  fontFamily: 'Gotham-Book',
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.07,
                                ),
                              ),
                            ),
                          ),
                          onTap: isReadyButtonEnabled
                              ? () {
                                  setState(
                                    () {
                                      isReadyButtonEnabled = false;
                                    },
                                  );
                                  widget.isAdmin ? fetchQues(snappp) : null;

                                  Firestore.instance
                                      .collection('rooms')
                                      .document(widget.gameID)
                                      .collection('users')
                                      .document(widget.playerID)
                                      .updateData(
                                    {
                                      'hasSelected': false,
                                      'hasSubmitted': false,
                                    },
                                  );

                                  changeReadyStateToTrue();
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void changeReadyStateToTrue() {
    Firestore.instance
        .collection('rooms')
        .document(widget.gameID)
        .collection('users')
        .document(widget.playerID)
        .updateData(
      {
        'isReady': true,
      },
    );
  }

  void fetchQues(snappp) {
    List getIndexes(int len, int n) {
      if (n == 1) {
        return [
          generateRandomIndex(
            len,
          ),
        ];
      } else if (n == 2) {
        List x = [];
        x.add(
          generateRandomIndex(
            len,
          ),
        );
        void test() {
          int newIndex = generateRandomIndex(
            len,
          );
          if (x.contains(newIndex)) {
            test();
          } else {
            x.add(newIndex);
          }
        }

        test();
        return x;
      }
    }

    changeNavigationStateToFalse(
      gameID: widget.gameID,
      field: 'isResponseSubmitted',
    );
    changeNavigationStateToFalse(
      gameID: widget.gameID,
      field: 'isResponseSelected',
    );

    Firestore.instance
        .collection('questions')
        .document('modes')
        .collection(widget.gameMode)
        .document(quesIndex())
        .snapshots()
        .listen(
      (event) async {
        List indexes = getIndexes(
          snappp.data.documents.length,
          snappp.data.documents.length == 1 ? 1 : 2,
        );

        String question = !event.data['question'].contains('abc')
            ? event.data['question'].replaceAll(
                'xyz',
                snappp.data.documents[indexes[0]]['name'],
              )
            : event.data['question']
                .replaceAll('xyz', snappp.data.documents[indexes[0]]['name'])
                .replaceAll(
                  'abc',
                  snappp.data.documents[indexes[1]]['name'],
                );

        await Firestore.instance
            .collection('rooms')
            .document(widget.gameID)
            .updateData(
          {
            'currentQuestion': question,
          },
        );
      },
    );
  }
}

//  widget.isAdmin
//                                   ? RaisedButton(
//                                       onPressed: () {
//                                         showDialog(
//                                           context: context,
//                                           builder: (BuildContext context) {
//                                             return AlertDialog(
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                   10,
//                                                 ),
//                                               ),
//                                               actions: <Widget>[
//                                                 FlatButton(
//                                                   onPressed: () {
//                                                     Navigator.of(context)
//                                                         .pop(false);
//                                                   },
//                                                   child: Text(
//                                                     "NO",
//                                                     style: TextStyle(
//                                                       fontFamily: 'Gotham-Book',
//                                                       fontSize:
//                                                           MediaQuery.of(context)
//                                                                   .size
//                                                                   .width *
//                                                               0.04,
//                                                       color: primaryColor,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 FlatButton(
//                                                   onPressed: () async {
//                                                     Firestore.instance
//                                                         .collection('rooms')
//                                                         .document(widget.gameID)
//                                                         .updateData({
//                                                       'isGameEnded': true
//                                                     });
//                                                     Navigator.of(context)
//                                                         .pop(false);
//                                                   },
//                                                   child: Text(
//                                                     "YES",
//                                                     style: TextStyle(
//                                                       fontFamily: 'Gotham-Book',
//                                                       fontWeight:
//                                                           FontWeight.w900,
//                                                       fontSize:
//                                                           MediaQuery.of(context)
//                                                                   .size
//                                                                   .width *
//                                                               0.04,
//                                                       color: secondaryColor,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ],
//                                               content: Text(
//                                                 "Are you sure you want to end the game?",
//                                                 style: TextStyle(
//                                                   fontFamily: 'Gotham-Book',
//                                                   fontSize:
//                                                       MediaQuery.of(context)
//                                                               .size
//                                                               .width *
//                                                           0.05,
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         );
//                                       },
//                                       color: Colors.green,
//                                       child: Text('End game'),
//                                     )
//                                   : SizedBox(),

//  onPressed: () async {
//                                   widget.isAdmin ? fetchQues(snappp) : null;

//                                   Firestore.instance
//                                       .collection('rooms')
//                                       .document(widget.gameID)
//                                       .collection('users')
//                                       .document(widget.playerID)
//                                       .updateData(
//                                     {
//                                       'hasSelected': false,
//                                       'hasSubmitted': false,
//                                     },
//                                   );

//                                   changeReadyStateToTrue();
//                                 },
