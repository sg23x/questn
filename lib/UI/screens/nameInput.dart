import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:questn/UI/constants.dart';
import 'package:questn/UI/screens/gameSelection.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';

class NameInputPage extends StatefulWidget {
  @override
  _NameInputPageState createState() => _NameInputPageState();
}

class _NameInputPageState extends State<NameInputPage> {
  String playerName;
  bool isButtonEnabled;
  Alignment align;

  FocusNode focus;

  Color buttonColor;
  Color submitColor;

  @override
  void initState() {
    isButtonEnabled = false;
    align = Alignment.lerp(
      Alignment.center,
      Alignment.centerLeft,
      1.25,
    );
    focus = new FocusNode();
    buttonColor = primaryColor;
    submitColor = primaryColor;

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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: DoubleBackToCloseApp(
        snackBar: SnackBar(
          content: Text(
            'Press back again to close app',
          ),
        ),
        child: Container(
          color: primaryColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(),
              Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: 'what\'s\n',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.1,
                              color: Colors.white70,
                              fontFamily: 'Gotham-Book',
                            ),
                          ),
                          TextSpan(
                            text: 'your\n',
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.05,
                              color: Colors.white,
                              fontFamily: 'Gotham-Book',
                            ),
                          ),
                          TextSpan(
                            text: 'name',
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.07,
                              color: Colors.white70,
                              fontFamily: 'Gotham-Book',
                            ),
                          ),
                          TextSpan(
                            text: '?',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.07,
                              color: secondaryColor,
                              fontFamily: 'Gotham-Book',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                              primaryColor: Colors.transparent,
                              cursorColor: primaryColor,
                            ),
                            child: TextField(
                              focusNode: focus,
                              maxLength: 15,
                              textCapitalization: TextCapitalization.words,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Gotham-Book',
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.04,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.06,
                                  vertical: MediaQuery.of(context).size.height *
                                      0.018,
                                ),
                                fillColor: Colors.white.withOpacity(0.2),
                                filled: true,
                                counterText: '',
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
                                      buttonColor = secondaryColor;
                                      submitColor = Colors.white;
                                    },
                                  );
                                } else {
                                  setState(
                                    () {
                                      isButtonEnabled = false;
                                      align = Alignment.lerp(
                                        Alignment.center,
                                        Alignment.centerLeft,
                                        1.25,
                                      );
                                      buttonColor = primaryColor;
                                      submitColor = primaryColor;
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.035,
                    ),
                    AnimatedContainer(
                      duration: Duration(
                        milliseconds: 300,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: LinearGradient(
                          colors: [
                            buttonColor,
                            primaryColor,
                          ],
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: FlatButton(
                        onPressed: isButtonEnabled
                            ? () {
                                setState(
                                  () {
                                    align = Alignment.lerp(
                                      Alignment.center,
                                      Alignment.centerRight,
                                      3,
                                    );
                                  },
                                );
                              }
                            : null,
                        child: AnimatedAlign(
                          onEnd: align ==
                                  Alignment.lerp(
                                    Alignment.center,
                                    Alignment.centerRight,
                                    3,
                                  )
                              ? submitName
                              : null,
                          curve: Curves.fastOutSlowIn,
                          alignment: align,
                          duration: Duration(
                            milliseconds: 250,
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            size: MediaQuery.of(context).size.height * 0.06,
                            color: submitColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(),
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
