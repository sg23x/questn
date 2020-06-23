import 'package:flutter/material.dart';
import 'package:psych/UI/constants.dart';

customProgressIndicator({@required context}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            backgroundColor: secondaryColor,
            strokeWidth: 8,
          ),
        ],
      );
    },
  );
}
