import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/menuscreen.dart';
import 'package:provider/provider.dart';
import 'package:qrcode/qrcode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrCodeScanner extends StatefulWidget {
  @override
  _QrCodeScannerState createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  final CloudFunctions cloudFunctions = CloudFunctions.instance;
  final QRCaptureController _captureController = QRCaptureController();
  final Firestore firestore = Firestore.instance;

  String sessionID, restaurantID, restaurantName, tableID, tableName;
  bool isOccupied = false;

  @override
  void initState() {
    super.initState();
    _captureController.onCapture((data) {
      _captureController.pause();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Start new Session?",
              style: TextStyle(fontFamily: "museoM"),
            ),
            content: Text(
              "Start new session to:\n- Browse the Menu\n- Place Orders\n- Get Order and Bill update",
              style: TextStyle(fontFamily: "museoS"),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  _captureController.resume();
                },
                child: Text(
                  "Cancel",
                  style: TextStyle(fontFamily: "museoS"),
                ),
              ),
              FlatButton(
                  color: FriskyColor().colorPrimary,
                  onPressed: () {
                    _initSessionCreation(data);
                  },
                  child: Text(
                    "Start",
                    style: TextStyle(color: Colors.white, fontFamily: "museoS"),
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
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              "Scan QR Code",
              style: TextStyle(fontFamily: "museoM", fontSize: 20),
            ),
          ),
          body: Center(
            child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: EdgeInsets.only(left: 32, right: 32),
                  child: QRCaptureView(
                    controller: _captureController,
                  ),
                )),
          )),
    );
  }

  _showProgressDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              "Retrieving the Menu",
              style: TextStyle(
                  color: FriskyColor().colorTextDark, fontFamily: "museoM"),
            ),
            content: Wrap(
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                      FriskyColor().colorPrimary,
                    ),
                  ),
                )
              ],
            ));
      },
      barrierDismissible: false,
    );
  }

  _initSessionCreation(data) async {
    _showProgressDialog();
    if (!data.contains("frisky") || (data.split("+").length != 3)) {
      _updateOnSessionStartFail();
      _showInvalidToast();
    } else {
      restaurantID = data.split("+")[1];
      tableID = data.split("+")[2];
      await firestore
          .collection("restaurants")
          .document(restaurantID)
          .get()
          .then((f) {
        if (f == null) {
          Navigator.pop(context);
          _updateOnSessionStartFail();
          _showInvalidToast();
          return null;
        }
        if (f.exists) {
          _checkIfTableOccupied();
        } else {
          Navigator.pop(context);
          _updateOnSessionStartFail();
          _showInvalidToast();
        }
        print("after if  data null hai ");
      });
    }
  }

  _checkIfTableOccupied() async {
    await firestore
        .collection("restaurants")
        .document(restaurantID)
        .collection("tables")
        .document(tableID)
        .get()
        .then(
      (f) async {
        if (f == null) {
          _showInvalidToast();
          return null;
        }
        if (f.exists) {
          if (f.data.containsKey("occupied")) {
            isOccupied = f.data["occupied"];
          }

          if (isOccupied) {
            Fluttertoast.showToast(
                msg: "Table is occupied", toastLength: Toast.LENGTH_LONG);
            _updateOnSessionStartFail();
          } else {
            _createUserSession();
          }
        } else {
          _showInvalidToast();
          _updateOnSessionStartFail();
        }
      },
    );
  }

  _createUserSession() async {
    Map<String, Object> userdata = new HashMap<String, Object>();
    userdata["restaurant"] = restaurantID;
    userdata["table"] = tableID;
    await cloudFunctions
        .getHttpsCallable(functionName: "createUserSession")
        .call(userdata)
        .then((getData) async {
      Map<String, dynamic> resultData = Map<String, dynamic>.from(getData.data);
      restaurantName = resultData["restaurant_name"];
      tableName = resultData["table_name"];
      sessionID = resultData["session_id"];
      await _setPreferences();
      _showMenu(
          restaurantName: restaurantName,
          tableName: tableName,
          sessionID: sessionID);
    }, onError: (error) {
      _popExit();
    });
  }

  _setPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool("session_active", true);
    await sharedPreferences.setString("restaurant_id", restaurantID);
    await sharedPreferences.setString("session_id", sessionID);
    await sharedPreferences.setString("table_id", tableID);
    await sharedPreferences.setString("table_name", tableName);
    await sharedPreferences.setString("restaurant_name", restaurantName);
    Provider.of<Session>(context).getStatus();
    return;
  }

  _showMenu({restaurantName, tableName, sessionID}) {
    Navigator.pop(context);
    _popExit();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MenuScreen(
                restaurantName, tableName, sessionID, restaurantID)));
  }

  _updateOnSessionStartFail() {
    _popExit();
    _captureController.resume();
  }

  _showInvalidToast() {
    Fluttertoast.showToast(
        msg: "Invalid QR Code", toastLength: Toast.LENGTH_SHORT);
  }

  _popExit() {
    Navigator.pop(context);
    Navigator.pop(context);
  }
}