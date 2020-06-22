import 'package:flutter/material.dart';

class ResultResponseCard extends StatelessWidget {
  ResultResponseCard({
    @required this.response,
    @required this.timesSelected,
  });
  final String response;
  final String timesSelected;
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
      color: Colors.pink,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '$response',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          Text(
            '$timesSelected',
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
