import 'package:flutter/material.dart';

class PlayerWaitingCard extends StatelessWidget {
  PlayerWaitingCard({
    @required this.name,
    @required this.cardIndex,
  });
  final String name;
  final int cardIndex;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        cardIndex % 2 == 0 ? MediaQuery.of(context).size.width * 0.02 : 0,
        MediaQuery.of(context).size.width * 0.02,
        MediaQuery.of(context).size.width * 0.02,
        0,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            height: MediaQuery.of(context).size.width * 0.22,
            child: CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.11,
              backgroundColor: Colors.grey,
              backgroundImage: AssetImage('assets/avatar.png'),
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
    );
  }
}
