import 'package:flutter/material.dart';

class ResponseCard extends StatelessWidget {
  ResponseCard({@required this.response});
  final String response;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        response,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Gotham-Book',
          fontSize: MediaQuery.of(context).size.height * 0.025,
          height: 1.25,
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.black.withOpacity(0.4),
        border: Border.all(color: Colors.white, width: 2),
      ),
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.height * 0.03,
      ),
      margin: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.height * 0.02,
          MediaQuery.of(context).size.height * 0.02,
          MediaQuery.of(context).size.height * 0.02,
          0),
    );
  }
}
