import 'dart:collection';
import 'package:friskyflutter/frisky_colors.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friskyflutter/screens/menuscreen.dart';
import 'package:qrcode/qrcode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
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
                  child: Text("Start",style: TextStyle(color: Colors.white),))
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
            Container(child: QRCaptureView(controller: _captureController,)),
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
        SizedBox(height: 30,),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(color: Colors.white,
              onPressed: () {

              },
              icon: Icon(Icons.center_focus_strong),
            ),
           Text("Scan QR Code",style: TextStyle(color: Colors.white,fontSize: 24),),
            IconButton(color: Colors.white,
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
  }

  continueSessionStart(data) async {
    if (!data.contains("frisky") || (data.split("+").length != 3)) {
      print("data hai = " + data.contains("frisky").toString());
      print("data hai split ka length = " + data.split("+").length.toString());
      print("data hai split = " + data.split("+").toString());
      print("if ka " + data);
      popexit();
      _captureController.resume();
      showInvalidToast();
    } else {
      print("inside else");
      print("QR CODE DATA IS = " + data.toString());
      restaurantID = data.split("+")[1];
      tableID = data.split("+")[2];
      print("resturant ka id " + restaurantID);
      print("table ID " + tableID);
      await firestore
          .collection("restaurants")
          .document(restaurantID)
          .get()
          .then((f) {
        //print(f.data["address"].toString());
        print(f.toString());
        print("before if  data null hai ");
        print("f null hai kya " + (f == null).toString());
        print("f null hai kya " + (f.exists).toString());

        if (f == null) {
          print("inside if  fro data is null");
          _captureController.resume();
          popexit();
          showInvalidToast();
          return null;
        }
        if (f.exists) {
          print("inside if  data exist hai ");
          Fluttertoast.showToast(
              msg: "Valid QR CODE before CTQ", toastLength: Toast.LENGTH_LONG);
          checkForTableOccupied();
        } else {
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

  // ignore: missing_return
  Future getRestaurantAndTableDetails(restaurantID, tableID) async {
    Fluttertoast.showToast(
        msg: "implementation baki hai but qr is 100% valid",
        toastLength: Toast.LENGTH_LONG);

    await firestore.collection("restaurants").document(restaurantID).get().then(
      (resDoc) async {
        if (resDoc == null) {
          return;
        }
        if (resDoc.exists) {
          var resname = await resDoc.data["name"];
          print("RES NAME IS = " + resname.toString());
        } else {
          print("NO Such Doc Exit");
        }
      },
      onError: (e) {
        print(e.toString());
        throw e;
      },
    ).whenComplete(() async {
      await firestore
          .collection("restaurants")
          .document(restaurantID)
          .collection("tables")
          .document(tableID)
          .get()
          .then(
        (resTableDoc) async {
          if (resTableDoc == null) {
            return;
          }
          if (resTableDoc.exists) {
            var tableSerial = "Table " + await resTableDoc.data["number"];
            print("Table Serial IS = " + tableSerial.toString());
          } else {
            print("NO Such Doc Exit");
          }
        },
        onError: (e) {
          print(e.toString());

          throw e;
        },
      );
    });
  }

  Future getUser() async {
    firebaseUser = await _auth.currentUser();
    // print(firebaseUser.uid.toString());
  }

  initUserSession(restaurantID, tableID) async {
    Map<String, Object> sessionDetails = new HashMap<String, Object>();
    sessionDetails.clear();
    print("inside init user session");
    sessionDetails["table_id"] = tableID;
    await getUser();
    if (firebaseUser != null) sessionDetails["created_by"] = firebaseUser.uid;
    sessionDetails["start_time"] =
        DateTime.now().toUtc().millisecondsSinceEpoch;
    sessionDetails["is_active"] = true;
    print("last me sab print \n " + sessionDetails.toString());
    await firestore
        .collection("restaurants")
        .document(restaurantID)
        .collection("sessions")
        .add(sessionDetails)
        .then((data) async {
      final String sessionID = data.documentID;
      Map<String, Object> userSessionDetails = new HashMap<String, Object>();
      userSessionDetails["session_active"] = true;
      userSessionDetails["current_session"] = sessionID;
      userSessionDetails["restaurant"] = restaurantID;
      print("last me sab print \n " + userSessionDetails.toString());
      await firestore
          .collection("users")
          .document(firebaseUser.uid)
          .setData(userSessionDetails, merge: true)
          .then((userdata) async {
        Map<String, Object> tableSessionDetails = new HashMap<String, Object>();
        tableSessionDetails["occupied"] = true;
        tableSessionDetails["session_id"] = sessionID;
        await firestore
            .collection("restaurants")
            .document(restaurantID)
            .collection("tables")
            .document(tableID)
            .setData(tableSessionDetails, merge: true)
            .then((table) {
          popexit();
          popexit();
          showMenu();
        }, onError: (e) {
          e.toString();
          print(e.toString());
        });
      });
    });
  }

  _createUserSession() async {
    Map<String, Object> userdata = new HashMap<String, Object>();

    userdata["restaurant"] = restaurantID;
    userdata["table"] = tableID;
    print("inside create USER SESSION");
    await cloudFunctions
        .getHttpsCallable(functionName: "createUserSession")
        .call(userdata)
        .then((getData) {
             Map<String, dynamic> resultData = Map<String, dynamic>.from (getData.data);
              print("data in cloude Function" + getData.data.toString());
              print("datatype in cloude Function" + getData.data.runtimeType.toString());
            print("data in cloude Function" + resultData.toString());
             String restaurantName = resultData["restaurant_name"];
             String tableName = resultData["table_name"];
             String sessionID = resultData["session_id"];
              showMenu(restaurantName: restaurantName,tableName:tableName,sessionID: sessionID);
    },onError: popexit());
  }

  showMenu({restaurantName, tableName, sessionID}) {
    popexit();
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => MenuScreen(restaurantName,tableName,sessionID,restaurantID)));
  }
  updateOnSessionStartFail() {
    popexit();
    _captureController.resume();
  }
}
