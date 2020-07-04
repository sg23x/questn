import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psych/UI/constants.dart';
import 'package:psych/UI/screens/waitingToStart.dart';
import 'dart:math';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:psych/UI/widgets/customProgressIndicator.dart';

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
  int rounds;

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

    generateRandomNumber(int len) {
      Random rnd;
      int min = 1;
      int max = len;
      rnd = new Random();
      var r = min + rnd.nextInt(max - min);
      return r;
    }

    final String playerID = generateUserCode();

    void resetLastRoom() async {
      await Firestore.instance
          .collection('newGame')
          .document('lastRoom')
          .updateData(
        {
          'gameID': int.parse(gameID),
        },
      );
    }

    void startGame({String gameMode, int quesCount}) async {
      await Firestore.instance.collection('rooms').document(gameID).setData(
        {
          'currentQuestion': '',
          'timestamp': Timestamp.now().millisecondsSinceEpoch,
          'isGameStarted': false,
          'isResponseSubmitted': false,
          'isResponseSelected': false,
          'isReady': false,
          'isGameEnded': false,
          'rounds': rounds,
        },
      );

      await Firestore.instance
          .collection('rooms')
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

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => WaitingToStart(
            gameID: gameID,
            playerID: playerID,
            gameMode: gameMode,
            isAdmin: true,
            quesCount: quesCount,
          ),
        ),
      );
    }

    void del({String gameMode, int quesCount}) async {
      DocumentSnapshot query =
          await Firestore.instance.collection('rooms').document(gameID).get();

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
      startGame(
        gameMode: gameMode,
        quesCount: quesCount,
      );
    }

    void createRoomID({String gameMode, int quesCount}) async {
      DocumentSnapshot query = await Firestore.instance
          .collection('newGame')
          .document('lastRoom')
          .get();

      setState(
        () {
          if (query.data['gameID'] < 9990) {
            gameID =
                (query.data['gameID'] + generateRandomNumber(5)).toString();
          } else {
            gameID = '1001';
          }
        },
      );

      resetLastRoom();

      del(
        gameMode: gameMode,
        quesCount: quesCount,
      );
    }

    void displayGameModes() {
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
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircularProgressIndicator(
                      backgroundColor: Colors.pink,
                      strokeWidth: 8,
                    ),
                  ],
                );
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
                        contentPadding: EdgeInsets.all(3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        content: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                secondaryColor,
                                primaryColor,
                              ],
                            ),
                          ),
                          height: MediaQuery.of(context).size.height * 0.5,
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              gameModeData['isLocked']
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.075,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Icon(
                                            Icons.lock_outline,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01,
                                          ),
                                          Text(
                                            'View ad to unlock!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.038,
                                              fontFamily: 'Gotham-Book',
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.075,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Icon(
                                            Icons.lock_open,
                                            size: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.04,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.01,
                                          ),
                                          Text(
                                            'Free pack!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.038,
                                              fontFamily: 'Gotham-Book',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                child: Image.network(
                                  gameModeData['imageLink'],
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: secondaryColor,
                                        strokeWidth: 8,
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Text(
                                  gameModeData['description'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Gotham-Book',
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                  ),
                                ),
                              ),
                              FlatButton(
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size:
                                      MediaQuery.of(context).size.height * 0.05,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('How many rounds?'),
                                        content: TextField(
                                          keyboardType:
                                              TextInputType.numberWithOptions(),
                                          onChanged: (val) {
                                            rounds = int.parse(val);
                                          },
                                        ),
                                        actions: [
                                          FlatButton(
                                            onPressed: gameModeData['isLocked']
                                                ? () {
                                                    myAd.load(
                                                      adUnitId:
                                                          'ca-app-pub-2468807992323747/9025521431',
                                                      targetingInfo:
                                                          targetingInfo,
                                                    );
                                                    myAd.listener = (
                                                      RewardedVideoAdEvent
                                                          event, {
                                                      String rewardType,
                                                      int rewardAmount,
                                                    }) {
                                                      if (event ==
                                                          RewardedVideoAdEvent
                                                              .loaded) {
                                                        myAd.show();
                                                      }
                                                      if (event ==
                                                          RewardedVideoAdEvent
                                                              .rewarded) {
                                                        adCloseChecker =
                                                            !adCloseChecker;
                                                        createRoomID(
                                                          gameMode:
                                                              gameModeData[
                                                                  'gameMode'],
                                                          quesCount:
                                                              gameModeData[
                                                                  'quesCount'],
                                                        );
                                                        customProgressIndicator(
                                                            context: context);
                                                      }
                                                      if (event ==
                                                          RewardedVideoAdEvent
                                                              .failedToLoad) {
                                                        createRoomID(
                                                          gameMode:
                                                              gameModeData[
                                                                  'gameMode'],
                                                          quesCount:
                                                              gameModeData[
                                                                  'quesCount'],
                                                        );
                                                      }
                                                      if (event ==
                                                              RewardedVideoAdEvent
                                                                  .closed &&
                                                          adCloseChecker) {
                                                        Navigator.pop(context);
                                                      }
                                                    };

                                                    customProgressIndicator(
                                                        context: context);
                                                  }
                                                : () {
                                                    createRoomID(
                                                      gameMode: gameModeData[
                                                          'gameMode'],
                                                      quesCount: gameModeData[
                                                          'quesCount'],
                                                    );
                                                    customProgressIndicator(
                                                        context: context);
                                                  },
                                            child: Text('Go'),
                                          ),
                                        ],
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
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FlatButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          color: Colors.transparent,
          padding: EdgeInsets.all(
            0,
          ),
          onPressed: () {
            displayGameModes();
          },
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.4,
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'START\nGAME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.15,
                        fontFamily: 'Gotham-Book',
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
