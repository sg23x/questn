import 'package:flutter/material.dart';

class PlayerWaitingCard extends StatefulWidget {
  PlayerWaitingCard({
    @required this.name,
    @required this.colorList,
    @required this.animationIndex,
  });
  final String name;
  final List<Color> colorList;
  final int animationIndex;

  @override
  _PlayerWaitingCardState createState() => _PlayerWaitingCardState();
}

class _PlayerWaitingCardState extends State<PlayerWaitingCard> {
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
      alignment: align,
      duration: Duration(
        milliseconds: 250,
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.colorList,
          ),
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.005,
          horizontal: MediaQuery.of(context).size.width * 0.02,
        ),
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
            ),
            Text(
              widget.name,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.09,
                fontFamily: 'Indie-Flower',
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
