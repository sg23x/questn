import 'package:flutter/material.dart';
import 'package:psych/UI/constants.dart';

showErrorDialog({
  @required context,
  @required String errorMessage,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: TextStyle(
          fontFamily: 'Gotham-Book',
          color: Colors.black,
          fontSize: MediaQuery.of(context).size.width * 0.048,
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
                fontWeight: FontWeight.w900,
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
            ),
          )
        ],
        content: Text(
          errorMessage,
        ),
      );
    },
  );
}
