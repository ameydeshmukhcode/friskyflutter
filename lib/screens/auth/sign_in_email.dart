import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../frisky_colors.dart';
import '../../widgets/text_fa.dart';

class SignInEmail extends StatefulWidget {
  @override
  _SignInEmailState createState() => _SignInEmailState();
}

class _SignInEmailState extends State<SignInEmail> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AuthResult _authResult;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _errorMessage = "";
  String _verifyEmailMessage =
      "You need to verify your email.\nClick here to send verification link.";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 8, right: 24),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _emailController,
                  style: TextStyle(fontFamily: "Varela", fontSize: 16),
                  decoration: InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                  cursorColor: FriskyColor.colorPrimary,
                ),
                Padding(padding: EdgeInsets.only(top: 8)),
                TextField(
                  controller: _passwordController,
                  style: TextStyle(fontFamily: "Varela", fontSize: 16),
                  decoration: InputDecoration(
                      labelText: 'Password',
                      focusColor: Colors.black,
                      border: OutlineInputBorder()),
                  obscureText: true,
                  cursorColor: FriskyColor.colorPrimary,
                ),
                Container(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: FlatButton(
                      onPressed: () {
                        if (_emailController.text.compareTo("") == 0) {
                          Fluttertoast.showToast(
                              msg: "Enter email",
                              toastLength: Toast.LENGTH_SHORT);
                        } else {
                          _resetPassword();
                        }
                      },
                      child: Text("Forgot password?",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontFamily: "Varela",
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
                      FAText("Sign In", 20, Colors.white),
                    ],
                  ),
                  onPressed: () {
                    if (_validateForm()) {
                      _signIn();
                    }
                  },
                  elevation: 2,
                  color: FriskyColor.colorPrimary,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
                  child: InkWell(
                      splashColor: Colors.black12,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        if (_errorMessage.compareTo(_verifyEmailMessage) == 0) {
                          _sendVerificationLink();
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Varela",
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      )),
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
                  FAText("Don't have an account?", 16, Colors.white),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('sign_up_email');
                    },
                    child: FAText("Sign up", 16, Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  _validateForm() {
    setState(() {
      _errorMessage = "";
    });

    if (_emailController.text.compareTo("") == 0) {
      Fluttertoast.showToast(
          msg: "Enter email", toastLength: Toast.LENGTH_SHORT);
      return false;
    }

    if (_passwordController.text.compareTo("") == 0) {
      Fluttertoast.showToast(
          msg: "Enter password", toastLength: Toast.LENGTH_SHORT);
      return false;
    }

    return true;
  }

  _setErrorMessage(String errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
    });
  }

  _signIn() async {
    try {
      _showProgressDialog();
      _authResult = await _auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      if (_authResult.user.isEmailVerified) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('home', (Route route) => false);
      } else {
        Navigator.pop(context);
        _setErrorMessage(_verifyEmailMessage);
      }
    } catch (e) {
      print("Error _signIn" + e.toString());
      Navigator.pop(context);
      _showError(e);
    }
  }

  _showError(var e) {
    switch (e.code) {
      case "ERROR_INVALID_EMAIL":
        _setErrorMessage("Invalid email entered.\nEnter a valid email.");
        break;
      case "ERROR_WRONG_PASSWORD":
        _setErrorMessage("Incorrect password entered.");
        break;
      case "ERROR_USER_NOT_FOUND":
        _setErrorMessage(
            "Account with this email doesn\'t exist.\nSign up first.");
        break;
      default:
        _setErrorMessage("Something went wrong.\nTry again.");
        break;
    }
  }

  _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      _setErrorMessage("Password reset link sent to your email.");
    } catch (e) {
      _showError(e);
    }
  }

  _sendVerificationLink() async {
    try {
      await _authResult.user.sendEmailVerification();
      setState(() {
        _errorMessage = "";
      });
      Fluttertoast.showToast(
          msg: "Verification Email Sent", toastLength: Toast.LENGTH_LONG);
      return _authResult.user.uid;
    } catch (e) {
      _setErrorMessage(
          "An error occured while trying to send verification email.");
    }
  }
}
