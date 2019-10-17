import 'package:flutter/material.dart';
import 'package:friskyflutter/Login/user_login.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:friskyflutter/Login/email_signin.dart';
import 'home_screen.dart';
import 'package:friskyflutter/Login/email_signup.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FriSky Flutter',
      theme: ThemeData(
        primaryColor: FriskyColor().colorCustom,
        accentColor: FriskyColor().colorCustom,
      ),
      home: HomeScreen(),
      routes: <String, WidgetBuilder>{
        "/homepage": (BuildContext context) => HomeScreen(),
        "/esingin": (BuildContext context) => EmailSignIn(),
        "/esingup": (BuildContext context) => EmailSignUp(),
        "/login": (BuildContext context) => UserLogin(),
      },
    );
  }
}
