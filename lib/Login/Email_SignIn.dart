
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:friskyflutter/FriskyColors.dart';
import '../size_config.dart';

class EmailSignIn extends StatefulWidget {
  @override
  _EmailSignInState createState() => _EmailSignInState();

}





class _EmailSignInState extends State<EmailSignIn> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();
final  FirebaseAuth _auth = FirebaseAuth.instance;


  checkAuthentication() async{

    _auth.onAuthStateChanged.listen((user) async{
         if(user!=null)
           {
             Navigator.pushReplacementNamed(context,"/");
           }

    });

  }

  navigateToSignUp(){
    Navigator.pushReplacementNamed(context, "/esingup");
  }

  signIn() async
   {
      try{
         AuthResult user = await _auth.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
         print("ye hai user "+ user.user.email);
         Navigator.pop(context);
         Navigator.pushReplacementNamed(context,"/homepage");

      }
      catch(e){
        showError(e.message);
      }
   }


   showError(String errorMessage){

    showDialog(context: context,
    builder: (BuildContext context){
      return AlertDialog(

        title: Text('Error'),
        content: Text(errorMessage),
        actions: <Widget>[
          FlatButton(
            child: Text('OK'),
            onPressed: (){
              Navigator.of(context).pop();
            },
          )
        ],
      );
    }

    );


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
                  SizedBox(height: 5,),
                  TextField(
                    controller: _emailController,
                    style:
                        TextStyle(fontSize: SizeConfig.safeBlockVertical * 2),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                      )
                    ),
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  TextField(
                    controller: _passwordController,
                    style:
                        TextStyle(fontSize: SizeConfig.safeBlockVertical * 2),
                    decoration: InputDecoration(
                        labelText: 'Password',
                        focusColor: Colors.black,
                        border: OutlineInputBorder(
                            )),
                    obscureText: true,
                  ),
                  SizedBox(height: SizeConfig.safeBlockVertical * 1),
           Container(
             child: Align(
               alignment: Alignment.centerRight,
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
                          Text("Sign In",
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
            InkWell(
              onTap: navigateToSignUp,
              child: new Container(
                height: SizeConfig.safeBlockVertical * 10,
                decoration: new BoxDecoration(color: Color(0xff707070)),
                child: Center(
                  child: RichText(
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
                    new TextSpan(
                        text: "Sign up",
                        style: TextStyle(
                          fontFamily: 'MuseoSans',
                          color: Color(0xffffffff),
                          fontSize: SizeConfig.safeBlockHorizontal * 4.6,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.normal,
                        )),
                  ])),
                ),
              ),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
