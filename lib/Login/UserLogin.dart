import 'package:flutter/material.dart';
import 'package:friskyflutter/Login/sign_in.dart';
import 'package:friskyflutter/size_config.dart';
import 'package:friskyflutter/FriskyColors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:friskyflutter/HomeScreen.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: FriskyColor().white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                SizedBox(height: SizeConfig.safeBlockVertical * 40),
                svg,
                SizedBox(height: SizeConfig.safeBlockVertical * 30),
                RaisedButton(onPressed: () {
                  signInWithGoogle().whenComplete(() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return HomeScreen();
                        },
                      ),
                    );
                  });
                },shape: StadiumBorder(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(MdiIcons.google,color: FriskyColor().colorCustom,),
                      SizedBox(width: SizeConfig.safeBlockHorizontal * 3 ,),
                      Text("Use Google Account",
                          style: TextStyle(
                            fontSize: SizeConfig.safeBlockVertical * 2.5,
                            color: FriskyColor().colorCustom
                          )),
                    ],
                  ),
                  elevation: 8,
                  color: FriskyColor().white,
                ),
                RaisedButton(onPressed: (){},shape: StadiumBorder(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.mail,color: FriskyColor().white,),
                      SizedBox(width: SizeConfig.safeBlockHorizontal * 3 ,),
                      Text("Use Email Address",
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockVertical * 2.5,
                              color: FriskyColor().white
                          )),
                    ],
                  ),
                  elevation: 8,
                  color: FriskyColor().colorCustom,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FirstScreen {
}
final String assetName = 'img/logo1.svg';
final Widget svg = new SvgPicture.asset(
  assetName,
  height: SizeConfig.safeBlockVertical * 14,
  width: SizeConfig.safeBlockHorizontal * 56,
);


