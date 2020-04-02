import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:friskyflutter/screens/home/home_screen.dart';
import 'package:friskyflutter/screens/auth/sign_in_email.dart';
import 'package:friskyflutter/widgets/text_fa.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInMain extends StatefulWidget {
  @override
  _SignInMainState createState() => _SignInMainState();
}

class _SignInMainState extends State<SignInMain> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(left: 64, right: 64),
            child: SvgPicture.asset(
              'images/logo_text.svg',
            ),
          )),
          Container(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: RaisedButton(
              elevation: 2,
              color: Colors.white,
              padding: EdgeInsets.all(8),
              shape: StadiumBorder(),
              onPressed: _signInWithGoogle,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SvgPicture.asset(
                    'images/icons/google.svg',
                    height: 20,
                    width: 20,
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                  ),
                  FAText("Use Google Account", 20, FriskyColor.colorPrimary),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: RaisedButton(
              color: FriskyColor.colorPrimary,
              padding: EdgeInsets.all(8),
              shape: StadiumBorder(),
              elevation: 2,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.mail,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: EdgeInsets.all(4),
                  ),
                  FAText("Use Email Address", 20, Colors.white),
                ],
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return SignInEmail();
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(56, 8, 56, 24),
            child: Text(
              "By signing in, you\'re agreeing to our Terms and Privacy Policy",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "Varela",
                fontSize: 14,
                color: FriskyColor.colorTextDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: FAText("Signing you in", 20, FriskyColor.colorTextDark),
            content: Wrap(
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                      FriskyColor.colorPrimary,
                    ),
                  ),
                )
              ],
            ));
      },
      barrierDismissible: false,
    );
  }

  _signInWithGoogle() async {
    try {
      _showProgressDialog();
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route route) => false);
      return user;
    } catch (e) {
      Navigator.pop(context);
    }
  }
}
