import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  QuestionCard({@required this.question});
  final String question;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      padding: EdgeInsets.all(
        10,
      ),
      margin: EdgeInsets.all(
        10,
      ),
      child: Text(
        question,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}
