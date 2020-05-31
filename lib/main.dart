import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'frisky_colors.dart';
import 'init_widget.dart';
import 'provider_models/cart.dart';
import 'provider_models/orders.dart';
import 'provider_models/session.dart';
import 'screens/auth/sign_in_email.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/sign_up_email.dart';
import 'screens/home/home_screen.dart';
import 'screens/slideshow_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
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
