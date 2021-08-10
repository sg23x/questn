import 'package:flutter/material.dart';
import 'package:questn/UI/constants.dart';

class QuestionCard extends StatefulWidget {
  QuestionCard({@required this.question});
  final String question;

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.black.withOpacity(0.9),
      child: Text(
        widget.question,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Gotham-Book',
          fontSize: MediaQuery.of(context).size.height * 0.025,
          height: 1.25,
        ),
      ),
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.height * 0.03,
      ),
    );
  }
}
