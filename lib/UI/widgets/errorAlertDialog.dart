import 'package:flutter/material.dart';

showErrorDialog({
  @required context,
  @required String errorMessage,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentTextStyle: TextStyle(
          fontFamily: 'Indie-Flower',
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: MediaQuery.of(context).size.height * 0.025,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12,
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
                fontFamily: 'Indie-Flower',
                color: Colors.pink,
                fontWeight: FontWeight.w900,
                fontSize: MediaQuery.of(context).size.height * 0.03,
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
