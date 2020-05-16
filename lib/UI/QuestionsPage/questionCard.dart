import 'package:flutter/material.dart';

class QuestionCard extends StatefulWidget {
  QuestionCard({@required this.question});
  final String question;

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  Color col;
  Color borderCol;
  @override
  void initState() {
    col = Colors.white;
    borderCol = Colors.white;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        setState(
          () {
            col = Colors.black;
            borderCol = Colors.cyan;
          },
        );
      },
    );
    return AnimatedContainer(
      duration: Duration(
        milliseconds: 1000,
      ),
      decoration: BoxDecoration(
        color: col,
        borderRadius: BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color: borderCol,
          width: 5,
        ),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        minWidth: MediaQuery.of(context).size.width,
      ),
      padding: EdgeInsets.all(
        MediaQuery.of(context).size.height * 0.03,
      ),
      margin: EdgeInsets.all(
        MediaQuery.of(context).size.width * 0.03,
      ),
      child: Text(
        widget.question,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Indie-Flower',
          fontSize: MediaQuery.of(context).size.height * 0.025,
        ),
      ),
    );
  }
}
