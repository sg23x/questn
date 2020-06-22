import 'package:flutter/material.dart';

customProgressIndicator({@required context}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            backgroundColor: Colors.pink,
            strokeWidth: 8,
          ),
        ],
      );
    },
  );
}
