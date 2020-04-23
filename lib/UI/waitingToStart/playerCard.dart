import 'package:flutter/material.dart';

class PlayerWaitingCard extends StatelessWidget {
  PlayerWaitingCard({
    @required this.name,
  });
  final String name;

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(
        5,
      ),
      height: MediaQuery.of(context).size.height * 0.1,
      color: Color(0xfff2f3f5),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.1,
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width * 0.08,
            ),
          ),
        ],
      ),
    );
  }
}
