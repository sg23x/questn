import 'package:flutter/material.dart';

class PlayerWaitingCard extends StatelessWidget {
  PlayerWaitingCard({
    @required this.name,
    @required this.cardIndex,
    @required this.borderColor,
    @required this.playersCount,
    @required this.avatarList,
    @required this.scale,
  });

  final String name;
  final int cardIndex;
  final Color borderColor;
  final int playersCount;
  final List avatarList;
  final double scale;
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          cardIndex % 2 == 0 ? MediaQuery.of(context).size.width * 0.02 : 0,
          MediaQuery.of(context).size.width * 0.02,
          MediaQuery.of(context).size.width * 0.02,
          playersCount % 2 == 0
              ? cardIndex == playersCount - 1 || cardIndex == playersCount - 2
                  ? MediaQuery.of(context).size.width * 0.02
                  : 0
              : cardIndex == playersCount - 1
                  ? MediaQuery.of(context).size.width * 0.02
                  : 0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black.withOpacity(0.5),
          border: Border.all(
            color: borderColor,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: MediaQuery.of(context).size.width * 0.22,
              child: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.11,
                backgroundColor: Colors.grey,
                backgroundImage: AssetImage(
                  avatarList[cardIndex],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.38,
              height: MediaQuery.of(context).size.width * 0.13,
              child: Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Gotham-Book',
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
