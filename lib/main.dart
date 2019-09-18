import 'package:flutter/material.dart';
import 'package:friskyflutter/Login/UserLogin.dart';
import 'package:friskyflutter/FriskyColors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FriSky Flutter',
      theme: ThemeData(
        primaryColor:  FriskyColor().colorCustom
      ),
      home: UserLogin(),
    );
  }
}
