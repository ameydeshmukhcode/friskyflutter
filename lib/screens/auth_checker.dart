import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:friskyflutter/screens/home_screen.dart';
import 'package:friskyflutter/screens/sign_in_screen.dart';

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _checkAuthStatus(),
        builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.data == null) {
            return SignInMain();
          } else {
            return HomeScreen();
          }
        }
    );
  }

  Future<FirebaseUser> _checkAuthStatus() async {
    return await FirebaseAuth.instance.currentUser();
  }
}