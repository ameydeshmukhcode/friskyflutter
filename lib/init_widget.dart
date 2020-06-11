import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'provider_models/session.dart';
import 'screens/visits/visit_summary.dart';

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

    SharedPreferences.getInstance().then((prefs) =>
        prefs.containsKey("slideshow_complete")
            ? Navigator.of(context)
                .pushNamedAndRemoveUntil('sign_in', (Route route) => false)
            : Navigator.of(context)
                .pushNamedAndRemoveUntil('slideshow', (Route route) => false));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
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
          print("Instance ID upload failed: " + error.toString());
        });
      }).catchError((error) {
        print("Error in getUser " + error.toString());
      });

      print("Token refreshed");
    });

    _fcmHandle.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage $message');
        doSomething(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume $message');
        doSomething(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch $message');
        doSomething(message);
      },
    );
  }

  Future doSomething(message) async {
    data = message["data"];
    print("Notification Data " + data.toString());
    if (data.containsKey("end_session") && data["end_session"] == "yes") {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setBool("session_active", false);
      await sharedPreferences.setBool("order_active", false);
      await sharedPreferences.setBool("bill_requested", false);
      _showNotification();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('home', (Route route) => false);
    }
    Provider.of<Session>(context, listen: false).updateSessionStatus();
  }
}
