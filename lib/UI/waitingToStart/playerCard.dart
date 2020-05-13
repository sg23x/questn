import 'package:flutter/material.dart';

class PlayerWaitingCard extends StatefulWidget {
  PlayerWaitingCard({
    @required this.name,
    @required this.colorList,
  });
  final String name;
  final List<Color> colorList;

  @override
  _PlayerWaitingCardState createState() => _PlayerWaitingCardState();
}

class _PlayerWaitingCardState extends State<PlayerWaitingCard> {
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.colorList,
        ),
        borderRadius: BorderRadius.circular(
          10,
        ),
      ),
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.of(context).size.height * 0.005,
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      height: MediaQuery.of(context).size.height * 0.1,
      child: Row(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.1,
          ),
          Text(
            widget.name,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.09,
              fontFamily: 'Indie-Flower',
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
