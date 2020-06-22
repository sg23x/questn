import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:psych/UI/screens/gameSelection.dart';

class NameInputPage extends StatefulWidget {
  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  String playerName;
  bool isButtonEnabled;
  Alignment align;

  FocusNode focus;

  @override
  void initState() {
    isButtonEnabled = false;
    align = Alignment.lerp(
      Alignment.center,
      Alignment.centerLeft,
      2,
    );
    focus = new FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void submitName() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => GameSelection(
            playerName: playerName,
          ),
        ),
      );
    }

    Future<bool> _onBackPressed() {
      return showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text(
                      "NO",
                      style: TextStyle(
                        fontFamily: 'Indie-Flower',
                        fontWeight: FontWeight.w900,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                      ),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: Text(
                      "YES",
                      style: TextStyle(
                        fontFamily: 'Indie-Flower',
                        fontWeight: FontWeight.w900,
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: Colors.pink,
                      ),
                    ),
                  ),
                ],
                content: Text(
                  "are you sure you want to exit?",
                  style: TextStyle(
                    fontFamily: 'Indie-Flower',
                    fontWeight: FontWeight.w400,
                    fontSize: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
              );
            },
          ) ??
          false;
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        resizeToAvoidBottomPadding: false,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue,
                Colors.cyan,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(),
              Text(
                'Welcome!',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).size.height * 0.1,
                  color: focus.hasFocus ? Colors.yellow : Colors.black,
                  fontFamily: 'Indie-Flower',
                ),
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Theme(
                            data: ThemeData(
                              primaryColor: Colors.yellow,
                              cursorColor: Colors.yellow,
                            ),
                            child: TextField(
                              focusNode: focus,
                              maxLength: 15,
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                color: Colors.yellow,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Indie-Flower',
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.04,
                              ),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.tag_faces,
                                ),
                                counterText: '',
                                labelText: 'Who are you?',
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.027,
                                  fontFamily: 'Indie-Flower',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  ),
                                ),
                              ),
                              onChanged: (val) {
                                playerName = val.trim();
                                if (!(playerName == null ||
                                    playerName.length == 0)) {
                                  setState(
                                    () {
                                      isButtonEnabled = true;
                                      align = Alignment.center;
                                    },
                                  );
                                } else {
                                  setState(
                                    () {
                                      isButtonEnabled = false;
                                      align = Alignment.lerp(
                                        Alignment.center,
                                        Alignment.centerLeft,
                                        2,
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    AnimatedAlign(
                      onEnd: align ==
                              Alignment.lerp(
                                Alignment.center,
                                Alignment.centerRight,
                                2,
                              )
                          ? submitName
                          : null,
                      curve: Curves.fastOutSlowIn,
                      alignment: align,
                      duration: Duration(
                        milliseconds: 250,
                      ),
                      child: FlatButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: isButtonEnabled
                            ? () {
                                setState(
                                  () {
                                    align = Alignment.lerp(
                                      Alignment.center,
                                      Alignment.centerRight,
                                      2,
                                    );
                                  },
                                );
                              }
                            : null,
                        child: Icon(
                          Icons.arrow_forward,
                          size: MediaQuery.of(context).size.height * 0.14,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(),
              SizedBox(),
              SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
