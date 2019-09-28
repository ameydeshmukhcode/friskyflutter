import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  bool isSignedIn = false;
  String _email;

  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) async {
      if (user == null) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
  }

  signOut() async {
    _auth.signOut();
  }

  getUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (firebaseUser != null) {
      setState(() {
        this._email = firebaseUser.email;
        this.isSignedIn = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    this.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: !isSignedIn
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(height: 40),
                    Text(
                      'User : ' + _email,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54),
                    ),
                    SizedBox(height: 40),
                    RaisedButton(
                      onPressed: signOut,
                      color: Colors.deepPurple,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Sign Out',
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                      ),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
