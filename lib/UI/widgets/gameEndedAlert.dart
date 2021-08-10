import 'package:flutter/material.dart';
import 'package:questn/UI/constants.dart';

gameEndedAlert({@required context}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: TextStyle(
          fontFamily: 'Gotham-Book',
          color: primaryColor,
          fontSize: MediaQuery.of(context).size.height * 0.025,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(
                fontFamily: 'Gotham-Book',
                color: secondaryColor,
                fontSize: MediaQuery.of(context).size.height * 0.02,
              ),
            ),
          )
        ],
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Text(
            "The game has ended!",
            textAlign: TextAlign.center,
          ),
        ),
      );
    },
  );
}
