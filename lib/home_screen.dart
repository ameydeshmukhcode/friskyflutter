import 'dart:collection';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/dine_tab.dart';
import 'package:friskyflutter/screens/qr_scan.dart';
import 'package:friskyflutter/screens/restaurants_tab.dart';
import 'package:friskyflutter/screens/menu_screen.dart';
import 'package:friskyflutter/screens/visit_summary.dart';
import 'package:friskyflutter/screens/visits_tab.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'frisky_colors.dart';
import 'provider_models/session.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  FirebaseAuth _auth = FirebaseAuth.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  Map<dynamic, dynamic> data;

  List<Widget> _pages = [RestaurantsTab(), DineTab(), VisitsTab()];

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
    return Scaffold(
      body: Consumer<Session>(builder: (context, session, child) {
        return Stack(
          children: <Widget>[
            _pages[_currentIndex],
            Visibility(
                visible: session.isSessionActive,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Material(
                    elevation: 4,
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        session.isBillRequested
                            ? ("Bill Requested")
                            : ("Currently at"),
                        style: TextStyle(
                            fontSize: 14,
                            color: FriskyColor().colorTextLight,
                            fontFamily: "museoS"),
                      ),
                      subtitle: Text(
                          session.isBillRequested
                              ? ("Bill Amount to Be Paid - " +
                                  session.totalAmount)
                              : (session.restaurantName +
                                  " - Table " +
                                  session.tableName),
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: "museoM")),
                      trailing: session.isBillRequested
                          ? SizedBox(
                              height: 1,
                            )
                          : OutlineButton(
                              highlightedBorderColor:
                                  FriskyColor().colorPrimary,
                              color: Colors.lightGreen,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MenuScreen(
                                            session.restaurantName,
                                            session.tableName,
                                            session.sessionID,
                                            session.restaurantID)));
                              },
                              child: Text(
                                "Menu",
                                style: TextStyle(
                                    color: FriskyColor().colorPrimary,
                                    fontFamily: "museoM"),
                              ),
                              borderSide: BorderSide(
                                color: FriskyColor().colorPrimary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(4),
                              ),
                            ),
                    ),
                  ),
                ))
          ],
        );
      }),
      floatingActionButton: Consumer<Session>(
          // ignore: non_constant_identifier_names
          builder: (context, Session, child) {
        return Visibility(
          visible: !Session.isSessionActive,
          child: FloatingActionButton.extended(
            onPressed: () async {
              // PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
              _openScanner();
              // showNotification();
            },
            icon: SvgPicture.asset(
              'images/icons/ic_scan_qr.svg',
              height: 20,
              width: 20,
              color: Colors.white,
            ),
            label: Text(
              "Scan QR Code",
              style: TextStyle(fontFamily: "museoM"),
            ),
            backgroundColor: FriskyColor().colorPrimary,
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<Session>(context, listen: false).getStatus();
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      elevation: 4,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      currentIndex: _currentIndex,
      showUnselectedLabels: false,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text(
            "Home",
            style: TextStyle(fontFamily: "museoL"),
          ),
        ),
        BottomNavigationBarItem(
          icon: Consumer<Session>(builder: (context, session, child) {
            return Badge(
              child: Icon(Icons.restaurant),
              badgeColor: FriskyColor().colorBadge,
              elevation: 0,
              position: BadgePosition.topRight(right: -7, top: -6),
              showBadge: session.isSessionActive,
            );
          }),
          title: Text(
            "Dine",
            style: TextStyle(fontFamily: "museoL"),
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.receipt,
          ),
          title: Text(
            "Visits",
            style: TextStyle(fontFamily: "museoL"),
          ),
        ),
      ],
      backgroundColor: Colors.white,
    );
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

  getPermission() async {
    await PermissionHandler().requestPermissions([PermissionGroup.camera]);
    if (await checkForPermission()) {
      Navigator.pushNamed(context, "/scan");
    }
  }

  _openScanner() async {
    if (await checkForPermission()) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => QrCodeScanner()));
    } else {
      getPermission();
    }
  }

  Future<bool> checkForPermission() async {
    PermissionStatus permission =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
    if (permission.toString() == "PermissionStatus.granted")
      return true;
    else
      return false;
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
