import 'package:firebase_auth/firebase_auth.dart';
import 'package:friskyflutter/provider_models/cart.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/screens/sign_in_screen.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'home_screen.dart';

Widget _homeWidget = Text("hellow");

Future<FirebaseUser> getUser() async {
  return await FirebaseAuth.instance.currentUser();
}

void main() {
  getUser().then((user) {
    if (user == null) {
      _homeWidget = SignInMain();
      runApp(MyApp());
      return _homeWidget;
    } else {
      _homeWidget = HomeScreen();
      runApp(MyApp());
      return _homeWidget;
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
        ],
        child: MaterialApp(
            title: 'FriSky Flutter',
            theme: ThemeData(
              primaryColor: FriskyColor().colorPrimary,
              accentColor: FriskyColor().colorPrimary,
            ),
            home: _homeWidget));
  }
}
