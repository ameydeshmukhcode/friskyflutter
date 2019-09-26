import 'package:flutter/material.dart';
import 'package:friskyflutter/Login/UserLogin.dart';
import 'package:friskyflutter/FriskyColors.dart';
import 'package:friskyflutter/Login/Email_SignIn.dart';
import 'HomeScreen.dart';
import 'package:friskyflutter/Login/Email_SignUp.dart';

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
      home: HomeScreen(),
      routes: <String,WidgetBuilder>{

        "/homepage":(BuildContext context) => HomeScreen(),
        "/esingin":(BuildContext context) => EmailSignIn(),
        "/esingup":(BuildContext context) => EmailSignUp(),
        "/login":(BuildContext context) => UserLogin(),



      },
    );
  }
}
