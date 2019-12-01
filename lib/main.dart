import 'package:friskyflutter/init_widget.dart';
import 'package:friskyflutter/provider_models/cart.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/provider_models/session.dart';
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
          ChangeNotifierProvider(create: (_) => Session()),
          ChangeNotifierProvider(create: (_) => Cart()),
          ChangeNotifierProvider(create: (_) => Orders()),
        ],
        child: MaterialApp(
            title: 'Frisky',
            theme: ThemeData(
              primaryColor: FriskyColor.colorPrimary,
              accentColor: FriskyColor.colorPrimary,
            ),
            home: InitWidget()));
  }
}
