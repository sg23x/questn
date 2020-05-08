import 'package:flutter/material.dart';
import 'package:psych/UI/nameInput/structure.dart';

main() => runApp(
      MyApp(),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, WidgetBuilder> appRoutes = {
      '/nameInput': (context) => NameInputPage(),
    };
    return MaterialApp(
      home: NameInputPage(),
      routes: appRoutes,
    );
  }
}
