import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/frisky_colors.dart';

import '../size_config.dart';

class EmailSignIn extends StatefulWidget {
  @override
  _EmailSignInState createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
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
      showLoader();
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
      Navigator.pop(context);
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
              padding: const EdgeInsets.only(left: 24, top: 8, right: 24),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _emailController,
                    style: TextStyle(
                        fontFamily: "museo",
                        fontWeight: FontWeight.w100,
                        fontSize: 16),
                    decoration: InputDecoration(
                        //errorText: validateEmail(_emailController.text),
                        labelText: 'Email',
                        border: OutlineInputBorder()),
                    cursorColor: FriskyColor().colorPrimary,
                  ),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  TextField(
                    controller: _passwordController,
                    style: TextStyle(
                        fontFamily: "museo",
                        fontWeight: FontWeight.w100,
                        fontSize: 16),
                    decoration: InputDecoration(
                        errorText: validatePassword(_passwordController.text),
                        labelText: 'Password',
                        focusColor: Colors.black,
                        border: OutlineInputBorder()),
                    obscureText: true,
                    cursorColor: FriskyColor().colorPrimary,
                  ),
                  Container(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        onPressed: resetPassword,
                        child: Text("Forgot password?",
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontFamily: "museo",
                              fontWeight: FontWeight.w300,
                              color: Colors.black,
                              fontSize: 14,
                            )),
                      ),
                    ),
                  ),
                  RaisedButton(
                    padding: EdgeInsets.all(8),
                    shape: StadiumBorder(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Sign In",
                            style: TextStyle(
                                fontFamily: "museo",
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Colors.white)),
                      ],
                    ),
                    onPressed: () {
                      signIn();
                    },
                    elevation: 2,
                    color: FriskyColor().colorPrimary,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
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
                          fontFamily: "museo",
                          fontWeight: FontWeight.w100,
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 4, bottom: 4),
              decoration: new BoxDecoration(color: Color(0xff707070)),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Don't have an account?",
                      style: TextStyle(
                          fontFamily: "museo",
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4),
                    ),
                    FlatButton(
                      onPressed: navigateToSignUp,
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                          fontFamily: "museo",
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: 16,
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
