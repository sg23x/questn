import 'package:flutter/material.dart';

class WaitingForSubmissionPlayerCard extends StatefulWidget {
  WaitingForSubmissionPlayerCard({
    @required this.name,
    @required this.hasSubmitted,
    @required this.animationIndex,
  });
  final String name;
  final bool hasSubmitted;
  final int animationIndex;

  @override
  _WaitingForSubmissionPlayerCardState createState() =>
      _WaitingForSubmissionPlayerCardState();
}

class _WaitingForSubmissionPlayerCardState
    extends State<WaitingForSubmissionPlayerCard> {
  Alignment align;
  @override
  void initState() {
    align = widget.animationIndex % 2 == 0
        ? Alignment.lerp(
            Alignment.center,
            Alignment.centerRight,
            120,
          )
        : Alignment.lerp(
            Alignment.center,
            Alignment.centerLeft,
            120,
          );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        setState(
          () {
            align = Alignment.center;
          },
        );
      },
    );

    return AnimatedAlign(
      curve: Curves.fastOutSlowIn,
      alignment: align,
      duration: Duration(
        milliseconds: 350,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.97,
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.width * 0.0075,
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.hasSubmitted ? Colors.green : Colors.red,
              Colors.black,
            ],
          ),
          borderRadius: BorderRadius.circular(
            15,
          ),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            Text(
              widget.name,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.09,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                fontFamily: 'Indie-Flower',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
