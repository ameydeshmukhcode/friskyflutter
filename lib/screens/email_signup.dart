import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/size_config.dart';

import '../frisky_colors.dart';

class EmailSignUp extends StatefulWidget {
  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {


  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _cpasswordController = new TextEditingController();
  String _errorMessage = " ";

  showLoader() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Signing you Up",
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
      case "ERROR_EMAIL_ALREADY_IN_USE":
        {
          customError(
              "Account with this email already exists.\nTry Signing In.");
        }
        break;
      case "ERROR_WEAK_PASSWORD":
        {
          customError(
              "Weak password.\nPassword length should be more than 6 characters.");
        }
        break;
    }
  }

//  checkAuthentication() async {
//    _auth.onAuthStateChanged.listen((user) async {
//      if (user != null) {
//        Navigator.pushReplacementNamed(context, "/esingin");
//      }
//    });
//  }
  String validatePassword(String value) {
    if (!(value.length >= 6) && value.isNotEmpty) {
      return "Password should contains more then 6 character";
    }
    return null;
  }

  signUp() async {
    try {
      showLoader();
      print("inside catch of signup");
      await _auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _cpasswordController.text);
      var u = await _auth.currentUser();
      await u.sendEmailVerification();
      await _auth.signOut();
      Navigator.pop(context);
      navigateToSignIn();
    } catch (e) {
      Navigator.pop(context);
      showError(e);
    }
  }

  navigateToSignIn() {
    _auth.signOut();
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // this.checkAuthentication();
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
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      focusColor: Colors.black,
                      border: OutlineInputBorder(),
                    ),
                    controller: _emailController,
                    cursorColor: FriskyColor().colorPrimary,
                  ),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  TextField(
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                        errorText: validatePassword(_passwordController.text),
                        labelText: 'Password',
                        focusColor: Colors.black,
                        border: OutlineInputBorder()),
                    obscureText: true,
                    controller: _passwordController,
                    cursorColor: FriskyColor().colorPrimary,
                  ),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  TextField(
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      errorText: validatePassword(_passwordController.text),
                      labelText: 'Confirm Password',
                      focusColor: Colors.black,
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    controller: _cpasswordController,
                    cursorColor: FriskyColor().colorPrimary,
                  ),
                  Padding(padding: EdgeInsets.only(top: 16)),
                  RaisedButton(
                    padding: EdgeInsets.all(10),
                    shape: StadiumBorder(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Sign Up",
                            style:
                            TextStyle(fontSize: 20, color: Colors.white)),
                      ],
                    ),
                    onPressed: () {
                      signUp();
                    },
                    elevation: 2,
                    color: FriskyColor().colorPrimary,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: InkWell(
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
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
