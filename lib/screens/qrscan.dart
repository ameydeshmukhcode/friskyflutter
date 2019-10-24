import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qrcode/qrcode.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  var tableID;
  var isOccupied = false;

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
                  onPressed: () {
                    continueSessionStart(data);
                  },
                  child: Text("cancel"))
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
            Container(child: QRCaptureView(controller: _captureController)),
            Container(
                // color: Colors.orange.withOpacity(0.2),
                ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildToolBar(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildToolBar() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        FlatButton(
          onPressed: () {
            _captureController.pause();
          },
          child: Text('pause'),
        ),
        FlatButton(
          onPressed: () {
            if (_isTorchOn) {
              _captureController.torchMode = CaptureTorchMode.off;
            } else {
              _captureController.torchMode = CaptureTorchMode.on;
            }
            _isTorchOn = !_isTorchOn;
          },
          child: Text('torch'),
        ),
        FlatButton(
          onPressed: () {
            _captureController.resume();
          },
          child: Text('resume'),
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
      restaurantID = data.split("+")[1];
      tableID = data.split("+")[2];
      print("resturant ka id " + restaurantID);
      print("table ID " + tableID);
      popexit();
      popexit();
      Fluttertoast.showToast(
          msg: "Valid QR CODE", toastLength: Toast.LENGTH_LONG);
      var restaurantRef = await firestore
          .collection("restaurants")
          .document(restaurantID)
          .get()
          .then((f) {
        print(f.data["address"].toString());
        print(f.toString());
        print("before if  data null hai ");
        print("f null hai kya " + (f == null).toString());
        print("f null hai kya " + (f.exists).toString());

        if (f == null) {
          showInvalidToast();

          return null;
        }
        if (f.exists) {
          print("inside if  data null hai ");
          checkForTableOccupied();
        } else {
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
      (f) {
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
          } else {
            getRestaurantAndTableDetails(restaurantID, tableID);
          }
        } else {
          showInvalidToast();
          updateOnSessionStartFail();
        }
      },
    );
  }

  getRestaurantAndTableDetails(restaurantID, tableID) {

    Fluttertoast.showToast(
        msg: "getresandtable implementation baki hai", toastLength: Toast.LENGTH_LONG);
  }

  updateOnSessionStartFail() {
    popexit();
    _captureController.resume();
  }
}
