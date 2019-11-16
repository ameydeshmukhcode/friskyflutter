import 'package:firebase_auth/firebase_auth.dart';
import 'package:friskyflutter/provider_models/cart.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/screens/sign_in_screen.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:friskyflutter/screens/sign_in_email.dart';
import 'package:friskyflutter/screens/qrscan.dart';
import 'home_screen.dart';
import 'package:friskyflutter/screens/sign_up_email.dart';




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
      initRoute = SignInMain();
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(builder: (_) => Session()),
          ChangeNotifierProvider(builder: (_) => Cart()),
          ChangeNotifierProvider(builder: (_) => Orders()),
          // ListenableProvider(builder: (_)=> Orders())
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
            "/esingin": (BuildContext context) => SignInEmail(),
            "/esingup": (BuildContext context) => SignUpEmail(),
            "/login": (BuildContext context) => SignInMain(),
            "/scan": (BuildContext context) => Scan(),
            //  "/ordersscreen": (BuildContext context,) => OrdersScreen(),
            //   "/menu": (BuildContext context) => MenuScreen(restaurantName, tableName,sessionID),
          },
        ));
  }
}
