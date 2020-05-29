import 'package:friskyflutter/init_widget.dart';
import 'package:friskyflutter/provider_models/cart.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/provider_models/profile.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/auth/sign_in_email.dart';
import 'package:friskyflutter/screens/auth/sign_in_screen.dart';
import 'package:friskyflutter/screens/auth/sign_up_email.dart';
import 'package:friskyflutter/screens/home/home_screen.dart';
import 'package:friskyflutter/screens/slideshow_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/frisky_colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => Profile()),
          ChangeNotifierProvider(create: (_) => Session()),
          ChangeNotifierProvider(create: (_) => Cart()),
          ChangeNotifierProvider(create: (_) => Orders()),
        ],
        child: MaterialApp(
          title: 'Frisky',
          theme: ThemeData(
              primaryColor: FriskyColor.colorPrimary,
              accentColor: FriskyColor.colorPrimary,
              canvasColor: Colors.transparent),
          initialRoute: 'init',
          routes: {
            'init': (context) => InitWidget(),
            'slideshow': (context) => SlideshowScreen(),
            'sign_in': (context) => SignInMain(),
            'sign_in_email': (context) => SignInEmail(),
            'sign_up_email': (context) => SignUpEmail(),
            'home': (context) => HomeScreen()
          },
        ));
  }
}
