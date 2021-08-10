import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:questn/UI/screens/nameInput.dart';

main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (value) => runApp(
      MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NameInputPage(),
      title: 'QuestN',
    );
  }
}
