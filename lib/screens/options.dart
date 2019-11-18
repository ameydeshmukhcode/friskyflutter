import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/screens/sign_in_screen.dart';

import '../frisky_colors.dart';

class OptionsScreen extends StatefulWidget {
  @override
  _OptionsScreenState createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Options",
          style: TextStyle(fontFamily: "museoM"),
        ),
        elevation: 4,
        backgroundColor: FriskyColor().colorPrimary,
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: SvgPicture.asset(
                'images/logo_text.svg',
                height: 40,
              ),
            ),
          ),
          Align(
              alignment: Alignment.center,
              child: InkWell(
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: _signOut,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Log out",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  _signOut() async {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(builder: (context) => SignInMain()),
        (Route route) => false);
  }
}
