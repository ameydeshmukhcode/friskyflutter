import 'package:firebase_auth/firebase_auth.dart';
import 'package:friskyflutter/provider_models/cart.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/orders_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/login/user_login.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:friskyflutter/login/email_signin.dart';
import 'package:friskyflutter/screens/qrscan.dart';
import 'home_screen.dart';
import 'package:friskyflutter/login/email_signup.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseUser user;
Widget initRoute = Text("hellow");

Future<FirebaseUser> getUser() async {
  return await _auth.currentUser();
}

void main() {
  getUser().then((user) {
    if (user == null) {
      print("null user");
      initRoute = UserLogin();
      runApp(MyApp());
      return initRoute;
    } else {
      print("not null user = " + user.displayName.toString());
      initRoute = HomeScreen();
      runApp(MyApp());
      return initRoute;
    }
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(builder: (_) => Session()),
          ChangeNotifierProvider(builder: (_) => Cart())
        ],
        child: MaterialApp(
          title: 'FriSky Flutter',
          theme: ThemeData(
            primaryColor: FriskyColor().colorPrimary,
            accentColor: FriskyColor().colorPrimary,
          ),
          home: initRoute,
          routes: <String, WidgetBuilder>{
            "/homepage": (BuildContext context) => HomeScreen(),
            "/esingin": (BuildContext context) => EmailSignIn(),
            "/esingup": (BuildContext context) => EmailSignUp(),
            "/login": (BuildContext context) => UserLogin(),
            "/scan": (BuildContext context) => Scan(),
            "/ordersscreen": (BuildContext context) => OrdersScreen(),
            //   "/menu": (BuildContext context) => MenuScreen(restaurantName, tableName,sessionID),
          },
        ));
  }
}
