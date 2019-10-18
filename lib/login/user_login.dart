import 'package:flutter/material.dart';
import 'package:friskyflutter/size_config.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:friskyflutter/Login/email_signin.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  googleSignIn() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      print("signed in " + user.displayName);
      Navigator.pushReplacementNamed(context, "/homepage");
      return user;
    } catch (e) {
      showError(e.message);
    }
  }

  showError(String errorMessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
            actions: <Widget>[
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: FriskyColor().white,
      body: Container(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 8),
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        child: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: svg,
              ),
              RaisedButton(
                padding: EdgeInsets.all(10),
                onPressed: googleSignIn,
                shape: StadiumBorder(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      MdiIcons.google,
                      color: FriskyColor().colorCustom,
                    ),
                    SizedBox(
                      width: SizeConfig.safeBlockHorizontal * 3,
                    ),
                    Text("Use Google Account",
                        style: TextStyle(
                            fontSize: 20, color: FriskyColor().colorCustom)),
                  ],
                ),
                elevation: 8,
                color: FriskyColor().white,
              ),
              SizedBox(height: 8),
              RaisedButton(
                padding: EdgeInsets.all(10),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return EmailSignIn();
                      },
                    ),
                  );
                },
                shape: StadiumBorder(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.mail,
                      color: FriskyColor().white,
                    ),
                    SizedBox(
                      width: SizeConfig.safeBlockHorizontal * 3,
                    ),
                    Text("Use Email Address",
                        style: TextStyle(
                            fontSize: 20, color: FriskyColor().white)),
                  ],
                ),
                elevation: 8,
                color: FriskyColor().colorCustom,
              ),
              Container(
                padding: EdgeInsets.fromLTRB(32, 8, 32, 0),
                child: Text(
                  "By signing in, you\'re agreeing to our Terms and Privacy Policy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: FriskyColor().colorTextDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final String assetName = 'img/logo1.svg';
final Widget svg = new SvgPicture.asset(
  assetName,
  height: SizeConfig.safeBlockVertical * 14,
  width: SizeConfig.safeBlockHorizontal * 56,
);
