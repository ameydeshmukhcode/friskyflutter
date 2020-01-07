import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friskyflutter/screens/home_screen.dart';
import 'package:friskyflutter/screens/sign_up_email.dart';

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
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                      labelText: 'Email', border: OutlineInputBorder()),
                  cursorColor: FriskyColor.colorPrimary,
                ),
                Padding(padding: EdgeInsets.only(top: 8)),
                TextField(
                  controller: _passwordController,
                  style: TextStyle(fontSize: 16),
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
                      onPressed: _resetPassword,
                      child: Text("Forgot password?",
                          textAlign: TextAlign.end,
                          style: TextStyle(
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
                          style: TextStyle(fontSize: 20, color: Colors.white)),
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
                  Text(
                    "Don't have an account?",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                  ),
                  FlatButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpEmail()),
                      );
                    },
                    child: Text(
                      "Sign up",
                      style: TextStyle(
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
    );
  }

  _showProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              "Signing you in",
              style: TextStyle(
                color: FriskyColor.colorTextDark,
              ),
            ),
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
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route route) => false);
      } else {
        Navigator.pop(context);
        _setErrorMessage(_verifyEmailMessage);
      }
    } catch (e) {
      print(e.toString());
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
        _setErrorMessage("Incorrect password entered");
        break;
      case "ERROR_USER_NOT_FOUND":
        _setErrorMessage(
            "Account with this email doesn\'t exist. Sign up first.");
        break;
      default:
        _setErrorMessage("Something went wrong.\nTry again.");
        break;
    }
  }

  _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);
      Fluttertoast.showToast(
          msg: "Password reset link sent to your email.",
          toastLength: Toast.LENGTH_LONG);
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
          msg: "Verification link send to your email.",
          toastLength: Toast.LENGTH_LONG);
      return _authResult.user.uid;
    } catch (e) {
      _setErrorMessage(
          "An error occured while trying to send verification email.");
    }
  }
}
