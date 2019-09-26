import 'package:flutter/material.dart';
import 'package:friskyflutter/size_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../FriskyColors.dart';

class EmailSignUp extends StatefulWidget {
  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
  TextEditingController _cpasswordController = new TextEditingController();

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

  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) async {
      if (user != null) {
        Navigator.pushReplacementNamed(context, "/esingin");
      }
    });
  }

  signUp() async {
    try {
      // ignore: unused_local_variable
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _cpasswordController.text)) as FirebaseUser;
    } catch (e) {
      showError(e.message);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.checkAuthentication();
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
                  TextField(
                    style:
                        TextStyle(fontSize: SizeConfig.safeBlockVertical * 2),
                    decoration: InputDecoration(
                        hintText: 'Email',
                        focusColor: Colors.black,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)))),
                    controller: _emailController,
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  TextField(
                    style:
                        TextStyle(fontSize: SizeConfig.safeBlockVertical * 2),
                    decoration: InputDecoration(
                        hintText: 'Password',
                        focusColor: Colors.black,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)))),
                    obscureText: true,
                    controller: _passwordController,
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  TextField(
                    style:
                        TextStyle(fontSize: SizeConfig.safeBlockVertical * 2),
                    decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        focusColor: Colors.black,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)))),
                    obscureText: true,
                    controller: _cpasswordController,
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  SizedBox(
                    height: SizeConfig.safeBlockVertical * 6,
                    child: RaisedButton(
                      onPressed: () {
                        signUp();
                      },
                      shape: StadiumBorder(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: SizeConfig.safeBlockHorizontal * 3,
                          ),
                          Text("Sign Up",
                              style: TextStyle(
                                  fontSize: SizeConfig.safeBlockVertical * 2.5,
                                  color: FriskyColor().white)),
                        ],
                      ),
                      color: FriskyColor().colorCustom,
                    ),
                  ),
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
