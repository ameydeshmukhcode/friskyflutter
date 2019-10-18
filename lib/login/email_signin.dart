import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friskyflutter/frisky_colors.dart';
import '../size_config.dart';

class EmailSignIn extends StatefulWidget {
  @override
  _EmailSignInState createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  AuthResult user;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _errorMessage = " ";

//  checkAuthentication() async {
//    _auth.onAuthStateChanged.listen((user) async {
//      if (user != null) {
//        Navigator.pushReplacementNamed(context, "/");
//      }
//    });
//  }

  navigateToSignUp() {
    Navigator.pushNamed(context, "/esingup");
  }

  signIn() async {
    try {
      user = await _auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      print("ye hai user " + user.user.email);
      if (user.user.isEmailVerified) {
        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, "/homepage");
      } else {
        customError(
            "You need to verify your email.\nClick here to send verification link.");
      }
    } catch (e) {
      print(e.toString());
      showError(e);
    }
  }

  customError(String customMsg) {
    setState(() {
      _errorMessage = customMsg;
    });
  }

  showError(var e) {
    switch (e.code) {
      case "ERROR_INVALID_EMAIL":
        {
          customError("Invalid email entered. Enter a valid email.");
        }
        break;
      case "ERROR_WRONG_PASSWORD":
        {
          customError("Incorrect password entered");
        }
        break;
      case "ERROR_USER_NOT_FOUND":
        {
          customError(
              "Account with this email doesn\'t exist.\nSign up first.");
        }
        break;
      case "ERROR_USER_DISABLED":
        {
          customError(e.message);
        }
        break;
      case "ERROR_TOO_MANY_REQUESTS":
        {
          customError(e.message);
        }
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        {
          customError(e.message);
        }
        break;
    }
  }

  resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      customError("Password reset link sent to your email.");
    } catch (e) {
      showError(e);
    }
  }

  sendVerifactionLink() async {
    try {
      await user.user.sendEmailVerification();
      customError("Link Sent To Your Email ");
      return user.user.uid;
    } catch (e) {
      print("An error occured while trying to send email verification");
      customError(e.message);
    }
  }

  String validatePassword(String value) {
    if (!(value.length >= 6) && value.isNotEmpty) {
      return "Password should contains more then 6 character";
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 22, right: 22),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    controller: _emailController,
                    style: TextStyle(
                      fontSize: SizeConfig.safeBlockVertical * 2,
                    ),
                    decoration: InputDecoration(
                        //errorText: validateEmail(_emailController.text),
                        labelText: 'Email',
                        border: OutlineInputBorder()),
                    cursorColor: FriskyColor().colorCustom,
                  ),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 2,
                  ),
                  TextField(
                    controller: _passwordController,
                    style:
                        TextStyle(fontSize: SizeConfig.safeBlockVertical * 2),
                    decoration: InputDecoration(
                        errorText: validatePassword(_passwordController.text),
                        labelText: 'Password',
                        focusColor: Colors.black,
                        border: OutlineInputBorder()),
                    obscureText: true,
                    cursorColor: FriskyColor().colorCustom,
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 0.5),
                  Container(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        onPressed: resetPassword,
                        child: Text("Forgot password?",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontFamily: 'MuseoSans',
                              color: Color(0xff707070),
                              fontSize: 15,
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.normal,
                            )),
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 1),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 6,
                    child: RaisedButton(
                      onPressed: () {
                        signIn();
                      },
                      shape: StadiumBorder(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal * 3,
                          ),
                          Text(
                            "Sign In",
                            style: TextStyle(
                                fontSize: SizeConfig.safeBlockVertical * 2.5,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      color: FriskyColor().colorCustom,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        if (_errorMessage ==
                            "You need to verify your email.\nClick here to send verification link.") {
                          sendVerifactionLink();
                          print(" inside if of link");
                        }
                      },
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: SizeConfig.safeBlockVertical * 2.5,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: SizeConfig.safeBlockVertical * 10,
              decoration: new BoxDecoration(color: Color(0xff707070)),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RichText(
                        text: new TextSpan(children: [
                      new TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            fontFamily: 'MuseoSans',
                            color: Color(0xffffffff),
                            fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.normal,
                          )),
                    ])),
                    FlatButton(
                      padding: EdgeInsets.all(0),
                      onPressed: navigateToSignUp,
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          fontFamily: 'MuseoSans',
                          color: Color(0xffffffff),
                          fontSize: SizeConfig.safeBlockHorizontal * 5.5,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
