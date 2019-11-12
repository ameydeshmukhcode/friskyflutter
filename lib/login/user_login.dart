import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:friskyflutter/login/email_signin.dart';
import 'package:friskyflutter/size_config.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  showLoader() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Signing you in",
            style: TextStyle(
                color: FriskyColor().colorTextDark,
                fontWeight: FontWeight.bold),
          ),
          content: Container(
            height: SizeConfig.safeBlockVertical * 10,
            width: SizeConfig.safeBlockVertical * 10,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  FriskyColor().colorPrimary,
                ),
              ),
            ),
          ),
        );
      },
      barrierDismissible: false,
    );
  }


  googleSignIn() async {
    try {
      showLoader();
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
      Navigator.pop(context);
      Navigator.pushReplacementNamed(context, "/homepage");
      return user;
    } catch (e) {
      Navigator.pop(context);
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
      backgroundColor: Colors.white,
      body: Container(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        child: Center(
          child: Column(
            children: <Widget>[
              Expanded(
                child: SvgPicture.asset(
                  'img/logo1.svg',
                  height: SizeConfig.safeBlockVertical * 14,
                  width: SizeConfig.safeBlockHorizontal * 56,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: RaisedButton(
                  padding: EdgeInsets.all(10),
                  shape: StadiumBorder(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SvgPicture.asset(
                        'img/google.svg',
                        height: 20,
                        width: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                      ),
                      Text("Use Google Account",
                          style: TextStyle(
                            fontSize: 20,
                            color: FriskyColor().colorPrimary,
                          )),
                    ],
                  ),
                  onPressed: googleSignIn,
                  elevation: 2,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: RaisedButton(
                  padding: EdgeInsets.all(10),
                  shape: StadiumBorder(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.mail,
                        color: Colors.white,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                      ),
                      Text("Use Email Address",
                          style: TextStyle(fontSize: 20, color: Colors.white)),
                    ],
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return EmailSignIn();
                        },
                      ),
                    );
                  },
                  elevation: 2,
                  color: FriskyColor().colorPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(56, 8, 56, 8),
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
