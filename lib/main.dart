import 'package:friskyflutter/provider_models/session.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/login/user_login.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:friskyflutter/login/email_signin.dart';
import 'package:friskyflutter/screens/qrscan.dart';
import 'home_screen.dart';
import 'package:friskyflutter/login/email_signup.dart';

void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(builder: (_)=>Session())
      ],
      child: MaterialApp(
        title: 'FriSky Flutter',
        theme: ThemeData(
          primaryColor: FriskyColor().colorPrimary,
          accentColor: FriskyColor().colorPrimary,
        ),
        home: HomeScreen(),
        routes: <String, WidgetBuilder>{
          "/homepage": (BuildContext context) => HomeScreen(),
          "/esingin": (BuildContext context) => EmailSignIn(),
          "/esingup": (BuildContext context) => EmailSignUp(),
          "/login": (BuildContext context) => UserLogin(),
          "/scan": (BuildContext context) => Scan(),
       //   "/menu": (BuildContext context) => MenuScreen(restaurantName, tableName,sessionID),
        },
      ),
    );
  }
}
