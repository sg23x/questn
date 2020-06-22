import 'package:flutter/material.dart';
import 'package:psych/UI/screens/nameInput.dart';

main() => runApp(
      MyApp(),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NameInputPage(),
      title: 'QuestN',
    );
  }
}
