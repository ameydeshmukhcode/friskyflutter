import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/menuscreen.dart';
import 'package:provider/provider.dart';
import 'package:qrcode/qrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../size_config.dart';

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  String sessionID, tableName, restaurantName;
  // SharedPreferences sharedPreferences;
  FirebaseUser firebaseUser;
  var firestore = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  QRCaptureController _captureController = QRCaptureController();
  bool _isTorchOn = false;
  var restaurantID;
  var flashicon = Icons.flash_on;
  var tableID;
  var isOccupied = false;
  CloudFunctions cloudFunctions = CloudFunctions.instance;
  @override
  void initState() {
    super.initState();
    _captureController.onCapture((data) {
      print('onCapture----data');
      _captureController.pause();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Start new Session ?"),
            content: Text(
                "Start new session to:\n- Browse the Menu\n- Place Orders\n- Get Order and Bill update"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _captureController.resume();
                },
                child: Text("cancel"),
              ),
              FlatButton(
                  color: FriskyColor().colorPrimary,
                  onPressed: () {
                    continueSessionStart(data);
                  },
                  child: Text(
                    "Start",
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          );
        },
        barrierDismissible: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(
                child: QRCaptureView(
              controller: _captureController,
            )),
            Container(
                // color: Colors.orange.withOpacity(0.2),
                ),
            Align(
              alignment: Alignment.topCenter,
              child: _buildToolBar(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildToolBar() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 30,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              color: Colors.white,
              onPressed: () {},
              icon: Icon(Icons.center_focus_strong),
            ),
            Text(
              "Scan QR Code",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            IconButton(
              color: Colors.white,
              onPressed: () {
                if (_isTorchOn) {
                  _captureController.torchMode = CaptureTorchMode.off;
                  setState(() {
                    flashicon = Icons.flash_on;
                  });
                } else {
                  _captureController.torchMode = CaptureTorchMode.on;
                  setState(() {
                    flashicon = Icons.flash_off;
                  });
                }
                _isTorchOn = !_isTorchOn;
              },
              icon: Icon(flashicon),
            ),
          ],
        ),
      ],
    );
  }

  showInvalidToast() {
    Fluttertoast.showToast(
        msg: "Invalid QR Code", toastLength: Toast.LENGTH_LONG);
  }

  popexit() {
    Navigator.pop(context);
    Navigator.pop(context);
  }

  showLoader() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Retrieving the Menu",
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

  continueSessionStart(data) async {
    showLoader();
    if (!data.contains("frisky") || (data.split("+").length != 3)) {
      //Navigator.pop(context);
      popexit();
      _captureController.resume();
      showInvalidToast();
    } else {
      restaurantID = data.split("+")[1];
      tableID = data.split("+")[2];
      await firestore
          .collection("restaurants")
          .document(restaurantID)
          .get()
          .then((f) {
        if (f == null) {
          _captureController.resume();
          Navigator.pop(context);
          popexit();
          showInvalidToast();
          return null;
        }
        if (f.exists) {
          checkForTableOccupied();
        } else {
          Navigator.pop(context);
          popexit();
          _captureController.resume();
          showInvalidToast();
        }
        print("after if  data null hai ");
      });
    }
  }

  checkForTableOccupied() async {
    await firestore
        .collection("restaurants")
        .document(restaurantID)
        .collection("tables")
        .document(tableID)
        .get()
        .then(
      (f) async {
        if (f == null) {
          showInvalidToast();
          return null;
        }
        if (f.exists) {
          if (f.data.containsKey("occupied")) {
            isOccupied = f.data["occupied"];
          }

          if (isOccupied) {
            Fluttertoast.showToast(
                msg: "Table is occupied", toastLength: Toast.LENGTH_LONG);
            popexit();
            _captureController.resume();
          } else {
            print("get res call");
            //await getRestaurantAndTableDetails(restaurantID, tableID);
            _createUserSession();
            print("init user call");
            //await initUserSession(restaurantID, tableID);
          }
        } else {
          showInvalidToast();
          updateOnSessionStartFail();
        }
      },
    );
  }

  Future getUser() async {
    firebaseUser = await _auth.currentUser();
    // print(firebaseUser.uid.toString());
  }



  _createUserSession() async {
    Map<String, Object> userdata = new HashMap<String, Object>();
    userdata["restaurant"] = restaurantID;
    userdata["table"] = tableID;
    print("inside create USER SESSION");
    await cloudFunctions
        .getHttpsCallable(functionName: "createUserSession")
        .call(userdata)
        .then((getData) async {
      Map<String, dynamic> resultData = Map<String, dynamic>.from(getData.data);
      print("data in cloude Function" + getData.data.toString());
      print(
          "datatype in cloude Function" + getData.data.runtimeType.toString());
      print("data in cloude Function" + resultData.toString());
      restaurantName = resultData["restaurant_name"];
      tableName = resultData["table_name"];
      sessionID = resultData["session_id"];
      await setPreferences();
      showMenu(
          restaurantName: restaurantName,
          tableName: tableName,
          sessionID: sessionID);
    }, onError: (error) {
      popexit();
    });
  }
  setPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool("session_active", true);
    await sharedPreferences.setString("restaurant_id", restaurantID);
    await sharedPreferences.setString("session_id", sessionID);
    await sharedPreferences.setString("table_id", tableID);
    await sharedPreferences.setString("table_name", tableName);
    await sharedPreferences.setString("restaurant_name", restaurantName);
    Provider.of<Session>(context).getStatus();
    return null;
  }
  showMenu({restaurantName, tableName, sessionID}) {
    Navigator.pop(context);
    popexit();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MenuScreen(
                restaurantName, tableName, sessionID, restaurantID)));
  }
  updateOnSessionStartFail() {
    popexit();
    _captureController.resume();
  }
}
