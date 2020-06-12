import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/waitingToStart/structure.dart';
import 'dart:math';
import 'package:firebase_admob/firebase_admob.dart';

class StartAGameButton extends StatefulWidget {
  StartAGameButton({
    @required this.playerName,
  });
  final String playerName;

  @override
  _StartAGameButtonState createState() => _StartAGameButtonState();
}

class _StartAGameButtonState extends State<StartAGameButton> {
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo();
  RewardedVideoAd myAd = RewardedVideoAd.instance;
  String gameID;
  Alignment axis;
  bool adCloseChecker;

  @override
  void initState() {
    gameID = '';
    adCloseChecker = true;
    axis = Alignment.lerp(
      Alignment.bottomCenter,
      Alignment.bottomLeft,
      1,
    );
    FirebaseAdMob.instance.initialize(
      appId: FirebaseAdMob.testAppId,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String generateUserCode() {
      Random rnd;
      int min = 100000000;
      int max = 999999999;
      rnd = new Random();
      var r = min + rnd.nextInt(max - min);
      return r.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        setState(
          () {
            axis = Alignment.lerp(
              Alignment.bottomCenter,
              Alignment.bottomRight,
              0.5,
            );
          },
        );
      },
    );

    final String playerID = generateUserCode();

    void startGame(String gameMode) async {
      await Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .setData(
        {
          'currentQuestion': '',
          'timestamp': Timestamp.now().millisecondsSinceEpoch,
          'isGameStarted': false,
          'admin': playerID,
        },
      );

      await Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .collection('users')
          .document(
            playerID,
          )
          .setData(
        {
          'name': widget.playerName,
          'userID': playerID,
          'score': 0,
          'timestamp': Timestamp.now().millisecondsSinceEpoch.toString(),
          'hasSubmitted': false,
          'response': '',
          'hasSelected': false,
          'selection': '',
          'isReady': false,
        },
      );

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => WaitingToStart(
            gameID: gameID,
            playerID: playerID,
            gameMode: gameMode,
          ),
        ),
      );
    }

    void del(String gameMode) async {
      DocumentSnapshot query = await Firestore.instance
          .collection('roomDetails')
          .document(gameID)
          .get();

      if (query.exists) {
        await query.reference.collection('users').getDocuments().then(
          (onValue) {
            for (DocumentSnapshot ds in onValue.documents) {
              ds.reference.delete();
            }
          },
        );

        await query.reference.delete();
      }
      startGame(gameMode);
    }

    void createRoomID(String gameMode) async {
      QuerySnapshot query = await Firestore.instance
          .collection('roomDetails')
          .orderBy('timestamp')
          .getDocuments();

      setState(
        () {
          gameID = query.documents.length != 0
              ? query.documents.length.toString() ==
                      (int.parse(query.documents.last.documentID) - 1000)
                          .toString()
                  ? ((int.parse(query.documents.last.documentID) % 9999) + 1)
                      .toString()
                  : query.documents[0].documentID
              : '1001';
        },
      );

      del(gameMode);
    }

    return AnimatedAlign(
      duration: Duration(
        milliseconds: 400,
      ),
      alignment: axis,
      child: RaisedButton(
        color: Colors.transparent,
        padding: EdgeInsets.all(
          0,
        ),
        elevation: 15,
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              bool willPop = true;
              return StreamBuilder(
                stream: Firestore.instance
                    .collection('gameModes')
                    .orderBy('index')
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return SizedBox();
                  }
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(willPop);
                    },
                    child: PageView.builder(
                      controller: PageController(
                        viewportFraction: 0.7,
                      ),
                      scrollDirection: Axis.horizontal,
                      itemCount: snap.data.documents.length,
                      itemBuilder: (context, i) {
                        DocumentSnapshot gameModeData = snap.data.documents[i];
                        return GestureDetector(
                          onTap: () {
                            setState(
                              () {
                                willPop = false;
                              },
                            );
                          },
                          child: AlertDialog(
                            backgroundColor: Color(
                              int.parse(gameModeData['colorCode']),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            content: Container(
                              decoration: BoxDecoration(),
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  gameModeData['isLocked']
                                      ? Container(
                                          height: 80,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Icon(
                                                Icons.lock,
                                                size: 35,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                'View ad to unlock!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(
                                          height: 80,
                                        ),
                                  Text(
                                    gameModeData['gameName'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                    ),
                                  ),
                                  RaisedButton(
                                    child: Text(
                                      'Play!',
                                    ),
                                    onPressed: gameModeData['isLocked']
                                        ? () {
                                            myAd.load(
                                              adUnitId:
                                                  'ca-app-pub-2468807992323747/9025521431',
                                              targetingInfo: targetingInfo,
                                            );
                                            myAd.listener = (
                                              RewardedVideoAdEvent event, {
                                              String rewardType,
                                              int rewardAmount,
                                            }) {
                                              if (event ==
                                                  RewardedVideoAdEvent.loaded) {
                                                myAd.show();
                                              }
                                              if (event ==
                                                  RewardedVideoAdEvent
                                                      .rewarded) {
                                                adCloseChecker =
                                                    !adCloseChecker;
                                                createRoomID(
                                                  gameModeData['gameMode'],
                                                );
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder:
                                                      (BuildContext context) {
                                                    return WillPopScope(
                                                      onWillPop: () async =>
                                                          false,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          CircularProgressIndicator(
                                                            backgroundColor:
                                                                Colors.pink,
                                                            strokeWidth: 8,
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                              if (event ==
                                                  RewardedVideoAdEvent
                                                      .failedToLoad) {
                                                createRoomID(
                                                  gameModeData['gameMode'],
                                                );
                                              }
                                              if (event ==
                                                      RewardedVideoAdEvent
                                                          .closed &&
                                                  adCloseChecker) {
                                                Navigator.pop(context);
                                              }
                                            };

                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return WillPopScope(
                                                  onWillPop: () async => false,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.pink,
                                                        strokeWidth: 8,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        : () {
                                            createRoomID(
                                              gameModeData['gameMode'],
                                            );
                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return WillPopScope(
                                                  onWillPop: () async => false,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.pink,
                                                        strokeWidth: 8,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              10,
            ),
            color: Colors.pink,
            border: Border.all(
              width: 3,
              color: Colors.white,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Start Game',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Indie-Flower',
                  fontWeight: FontWeight.w900,
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
