import 'package:firebase_auth/firebase_auth.dart';
import 'package:friskyflutter/init_widget.dart';
import 'package:friskyflutter/provider_models/cart.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/screens/sign_in_screen.dart';
import 'package:friskyflutter/frisky_colors.dart';

void main() {
  FirebaseAuth.instance.currentUser().then((user) {
    if (user == null) {
      runApp(MyApp(SignInMain()));
    } else {
      runApp(MyApp(InitWidget()));
    }
  });
}

class MyApp extends StatelessWidget {
  final Widget _homeWidget;

  MyApp(this._homeWidget);

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
