import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:friskyflutter/home_screen.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/visit_summary.dart';

class InitWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InitWidgetState();
}

class _InitWidgetState extends State<InitWidget> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Map<dynamic, dynamic> data;


  @override
  void initState() {
    super.initState();
    firebaseCloudMessagingListeners();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('icon_first_logo');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }

  showNotification() async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, "Session Ended", "Click here to check your visit summary", platform,
        payload: 'FRiSKY APP');
  }

  // ignore: missing_return
  Future onSelectNotification(String payload) {
    print(data.toString());
    print(data["session_id"]);
    print(data["restaurant_id"]);
    print(data["restaurant_name"]);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => VisitSummary(
            sessionID: data["session_id"],
            restaurantID: data["restaurant_id"],
            restaurantName: data["restaurant_name"],
          )),
    );
  }

  void iOSPermission() {
    firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future<FirebaseUser> getUser() async {
    return await _auth.currentUser();
  }

  Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    return Future<void>.value();
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();
    getUser().then((user) {
      Map<String, Object> userDetails = HashMap<String, Object>();
      print(user.uid + " ye hai ID");
      firebaseMessaging.getToken().then((token) {
        userDetails["firebase_instance_id"] = token;
        Firestore.instance
            .collection("users")
            .document(user.uid)
            .setData(userDetails, merge: true)
            .then((update) {
          print("TOKEN IS  = " + token);
          print("instace ID UPDATED ");
        }).catchError((error) {
          print("instace ID Update Failed");
        });
      }).catchError((error) {
        print("error in getting token");
      });
    }).catchError((error) {
      print("error in getting User");
    });
    firebaseMessaging.configure(
      //onBackgroundMessage: myBackgroundMessageHandler,
      onMessage: (Map<String, dynamic> message) async {
        doSomething(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        doSomething(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        doSomething(message);
      },
    );
  }

  Future doSomething(message) async {
    print('on message $message');
    //print("in mess " + message["data"]);
    data = message["data"];
    print(data.toString());
    if (data.containsKey("end_session") && data["end_session"] == "yes") {
      // print(data.toString());
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      await sharedPreferences.setBool("session_active", false);
      await sharedPreferences.setBool("order_active", false);
      await sharedPreferences.setBool("bill_requested", false);
      print("RAJ");
      showNotification();
      Navigator.popUntil(
        context,
        ModalRoute.withName(Navigator.defaultRouteName),
      );
      print("Session ENDED");
    } else {
      print("Session not ENDED");
    }
    Provider.of<Session>(context, listen: false).getStatus();
  }
}