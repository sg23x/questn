import 'package:flutter/material.dart';

class PlayerScoreCard extends StatelessWidget {
  PlayerScoreCard({
    @required this.name,
    @required this.score,
    @required this.scoreAdded,
    @required this.isReady,
  });
  final String name;
  final String score;
  final String scoreAdded;
  final bool isReady;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(
        5,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
      ),
      color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '$name :',
            style: TextStyle(
              color: isReady ? Colors.green : Colors.red,
              fontSize: 25,
            ),
          ),
          Text(
            '$score (+$scoreAdded)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }
}
