import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/auth_checker.dart';
import 'package:friskyflutter/screens/slideshow_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/visit_summary.dart';

class InitWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _InitWidgetState();
}

class _InitWidgetState extends State<InitWidget> {
  final FirebaseMessaging _fcmHandle = FirebaseMessaging();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Map<dynamic, dynamic> data;

  @override
  void initState() {
    super.initState();
    _fcmListeners();

    var android = new AndroidInitializationSettings('icon_notif');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android, iOS);
    _flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: onSelectNotification);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _checkSlideshowComplete(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.data == false) {
            return SlideshowScreen();
          } else {
            return AuthChecker();
          }
        });
  }

  Future<bool> _checkSlideshowComplete() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("slideshow_complete")) {
      return true;
    } else {
      return false;
    }
  }

  _showNotification() async {
    var android = new AndroidNotificationDetails('Sessions', 'Visit Updates',
        'Updates related to your restaurant visits',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await _flutterLocalNotificationsPlugin.show(0, "You're done dining!",
        "Click here to check your visit summary", platform,
        payload: 'Frisky');
  }

  // ignore: missing_return
  Future onSelectNotification(String payload) {
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

  _iOSPermissionRequest() {
    _fcmHandle.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcmHandle.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

  Future<FirebaseUser> getUser() async {
    return await FirebaseAuth.instance.currentUser();
  }

  Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    return Future<void>.value();
  }

  void _fcmListeners() {
    if (Platform.isIOS) _iOSPermissionRequest();

    _fcmHandle.onTokenRefresh.listen((token) {
      getUser().then((user) {
        Map<String, Object> userDetails = HashMap<String, Object>();
        userDetails["firebase_instance_id"] = token;
        Firestore.instance
            .collection("users")
            .document(user.uid)
            .setData(userDetails, merge: true)
            .then((update) {})
            .catchError((error) {
          print("instance ID upload failed");
        });
      }).catchError((error) {
        print("error in getting User");
      });

      print("Token refreshed");
    });

    _fcmHandle.configure(
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
      _showNotification();
      Navigator.popUntil(
        context,
        ModalRoute.withName(Navigator.defaultRouteName),
      );
      print("Session ENDED");
    } else {
      print("Session not ENDED");
    }
    Provider.of<Session>(context, listen: false).updateSessionStatus();
  }
}
