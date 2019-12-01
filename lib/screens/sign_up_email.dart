import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../frisky_colors.dart';

class SignUpEmail extends StatefulWidget {
  @override
  _SignUpEmailState createState() => _SignUpEmailState();
}

class _SignUpEmailState extends State<SignUpEmail> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _cpasswordController = new TextEditingController();
  String _errorMessage = "";

  @override
  Widget build(BuildContext context) {
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
                    style: TextStyle(fontFamily: "museoS", fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      focusColor: Colors.black,
                      border: OutlineInputBorder(),
                    ),
                    controller: _emailController,
                    cursorColor: FriskyColor.colorPrimary,
                  ),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  TextField(
                    style: TextStyle(fontFamily: "museoS", fontSize: 16),
                    decoration: InputDecoration(
                        labelText: 'Password',
                        focusColor: Colors.black,
                        border: OutlineInputBorder()),
                    obscureText: true,
                    controller: _passwordController,
                    cursorColor: FriskyColor.colorPrimary,
                  ),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  TextField(
                    style: TextStyle(fontFamily: "museoS", fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      focusColor: Colors.black,
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    controller: _cpasswordController,
                    cursorColor: FriskyColor.colorPrimary,
                  ),
                  Padding(padding: EdgeInsets.only(top: 8)),
                  RaisedButton(
                    padding: EdgeInsets.all(8),
                    shape: StadiumBorder(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Sign Up",
                            style: TextStyle(
                                fontFamily: "museoM",
                                fontSize: 20,
                                color: Colors.white)),
                      ],
                    ),
                    onPressed: () {
                      if (_validateForm()) {
                        _signUp();
                      }
                    },
                    elevation: 2,
                    color: FriskyColor.colorPrimary,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: InkWell(
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "museoS",
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }

  _showProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              "Signing you up",
              style: TextStyle(
                  color: FriskyColor.colorTextDark, fontFamily: "museoL"),
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

    String passwordText = _passwordController.text;
    String cpasswordText = _cpasswordController.text;

    if (_emailController.text.compareTo("") == 0) {
      Fluttertoast.showToast(
          msg: "Enter email", toastLength: Toast.LENGTH_SHORT);
      return false;
    }

    if (passwordText.compareTo("") == 0) {
      Fluttertoast.showToast(
          msg: "Enter password", toastLength: Toast.LENGTH_SHORT);
      return false;
    }

    if (cpasswordText.compareTo(passwordText) != 0) {
      Fluttertoast.showToast(
          msg: "Passwords don't match", toastLength: Toast.LENGTH_SHORT);
      return false;
    }

    return true;
  }

  _setErrorMessage(String customMsg) {
    setState(() {
      _errorMessage = customMsg;
    });
  }

  _showError(var e) {
    switch (e.code) {
      case "ERROR_INVALID_EMAIL":
        _setErrorMessage("Invalid email entered.\nEnter a valid email.");
        break;
      case "ERROR_EMAIL_ALREADY_IN_USE":
        _setErrorMessage(
            "Account with this email already exists.\nTry Signing In.");
        break;
      case "ERROR_WEAK_PASSWORD":
        _setErrorMessage(
            "Weak password.\nPassword length should be more than 6 characters.");
        break;
      default:
        _setErrorMessage("Something went wrong.\nTry again.");
        break;
    }
  }

  _signUp() async {
    try {
      _showProgressDialog();
      await _auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _cpasswordController.text);
      var u = await _auth.currentUser();
      await u.sendEmailVerification();
      await _auth.signOut();
      Navigator.pop(context);
      _navigateBackToSignIn();
    } catch (e) {
      Navigator.pop(context);
      _showError(e);
    }
  }

  _navigateBackToSignIn() {
    _auth.signOut();
    Navigator.pop(context);
  }
}
