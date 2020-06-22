import 'package:flutter/material.dart';

class ResponseCard extends StatelessWidget {
  ResponseCard({@required this.response});
  final String response;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      height: MediaQuery.of(context).size.height * 0.1,
      color: Colors.blueGrey,
      child: Text(
        response,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }
}
