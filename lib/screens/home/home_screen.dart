import 'dart:collection';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/dine_tab.dart';
import 'package:friskyflutter/screens/qr_scan.dart';
import 'package:friskyflutter/screens/restaurants/restaurants_tab.dart';
import 'package:friskyflutter/screens/menu/menu_screen.dart';
import 'package:friskyflutter/screens/visits/visits_tab.dart';
import 'package:friskyflutter/widgets/text_fa.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../frisky_colors.dart';
import '../../provider_models/session.dart';
import '../auth/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String sessionID, restaurantID, restaurantName, tableID, tableName;
  List<Widget> _pages = [RestaurantsTab(), DineTab(), VisitsTab()];
  GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Provider.of<Session>(context, listen: false).updateSessionStatus();
    _checkForProfileSetup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _drawerKey,
      drawerEdgeDragWidth: 0,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              tooltip: "Options",
              icon: Icon(Icons.settings),
              color: FriskyColor.colorTextDark,
              onPressed: () {
                _drawerKey.currentState.openEndDrawer();
              })
        ],
      ),
      endDrawer: _endDrawer(),
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
                  color: FriskyColor.colorPrimary,
                  child: InkWell(
                    splashColor: Colors.black12,
                    onTap: () {
                      if (!session.isBillRequested) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MenuScreen(
                                    session.restaurantName,
                                    session.tableName,
                                    session.sessionID,
                                    session.restaurantID)));
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                session.isBillRequested
                                    ? ("Bill requested")
                                    : (session.restaurantName),
                                style: TextStyle(
                                    fontFamily: "Varela",
                                    fontSize: 16,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              FAText(
                                  session.isBillRequested
                                      ? ("Bill amount to be paid: \u20B9" +
                                          session.totalAmount)
                                      : ("Table " + session.tableName),
                                  14,
                                  Colors.white),
                            ],
                          ),
                          Visibility(
                            visible: !session.isBillRequested,
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "Menu",
                                  style: TextStyle(
                                    fontFamily: "Varela",
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
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
              if (kReleaseMode) {
                _startScanner();
              } else {
                _startDummySession();
              }
            },
            icon: SvgPicture.asset(
              'images/icons/ic_scan_qr.svg',
              height: 20,
              width: 20,
              color: Colors.white,
            ),
            label: FAText("Scan QR code", 14, Colors.white),
            backgroundColor: FriskyColor.colorPrimary,
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _bottomNavBar(),
    );
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
          title: FAText("Home", 14, FriskyColor.colorPrimary),
        ),
        BottomNavigationBarItem(
          icon: Consumer<Session>(builder: (context, session, child) {
            return Badge(
              child: Icon(Icons.restaurant),
              badgeColor: FriskyColor.colorBadge,
              elevation: 0,
              position: BadgePosition.topRight(right: -7, top: -6),
              showBadge: session.isSessionActive,
            );
          }),
          title: FAText("Dine", 14, FriskyColor.colorPrimary),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.receipt,
          ),
          title: FAText("Visits", 14, FriskyColor.colorPrimary),
        ),
      ],
      backgroundColor: Colors.white,
    );
  }

  _startScanner() async {
    Map<PermissionGroup, PermissionStatus> permissionMap;
    PermissionStatus status =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);

    switch (status) {
      case PermissionStatus.granted:
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => QrCodeScanner()));
        break;
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        permissionMap = await PermissionHandler()
            .requestPermissions([PermissionGroup.camera]);
        if (permissionMap[PermissionGroup.camera] == PermissionStatus.granted) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => QrCodeScanner()));
        } else if (Platform.isIOS) {
          _showNeedCameraAlertiOS();
        } else if (Platform.isAndroid) {
          _showNeedCameraAlertAndroid();
        }
        break;
    }
  }

  _startDummySession() async {
    Map<String, Object> userdata = new HashMap<String, Object>();
    userdata["restaurant"] = "6mB4DZdwKHC5xe0sBZ0V";
    userdata["table"] = "RQGAzjaLXYSMsR5Kbs63";
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "createUserSession")
        .call(userdata)
        .then((getData) async {
      Map<String, dynamic> resultData = Map<String, dynamic>.from(getData.data);
      await _setPreferences(
          restaurantName: resultData["restaurant_name"],
          tableName: resultData["table_name"],
          sessionID: resultData["session_id"]);
      _showMenu(
          restaurantName: resultData["restaurant_name"],
          tableName: resultData["table_name"],
          sessionID: resultData["session_id"]);
    }, onError: (error) {
      print(error);
    });
  }

  _setPreferences({restaurantName, tableName, sessionID}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool("session_active", true);
    await sharedPreferences.setString("restaurant_id", "6mB4DZdwKHC5xe0sBZ0V");
    await sharedPreferences.setString("table_id", "RQGAzjaLXYSMsR5Kbs63");
    await sharedPreferences.setString("session_id", sessionID);
    await sharedPreferences.setString("table_name", tableName);
    await sharedPreferences.setString("restaurant_name", restaurantName);
    Provider.of<Session>(context).updateSessionStatus();
    return;
  }

  _showMenu({restaurantName, tableName, sessionID}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MenuScreen(
                restaurantName, tableName, sessionID, "6mB4DZdwKHC5xe0sBZ0V")));
  }

  _showNeedCameraAlertiOS() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: FAText("Allow camera", 20, FriskyColor.colorTextDark),
          content: FAText(
              "Enable 'Camera' for Frisky under Settings to be able to scan QR codes.",
              14,
              FriskyColor.colorTextLight),
          actions: <Widget>[
            FlatButton(
              color: FriskyColor.colorPrimary,
              onPressed: () {
                Navigator.pop(context);
              },
              child: FAText("OK", 14, Colors.white),
            )
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  _showNeedCameraAlertAndroid() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: FAText("Camera needed", 20, FriskyColor.colorTextDark),
          content: FAText(
              "Allow camera permission to be able to scan QR codes.",
              14,
              FriskyColor.colorTextLight),
          actions: <Widget>[
            FlatButton(
              color: FriskyColor.colorPrimary,
              onPressed: () {
                Navigator.pop(context);
              },
              child: FAText("OK", 14, Colors.white),
            )
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  _signOut() async {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(builder: (context) => SignInMain()),
        (Route route) => false);
  }

  _checkForProfileSetup() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    bool profileSetup = false;
    FirebaseAuth.instance.currentUser().then((user) async {
      await Firestore.instance
          .collection("users")
          .document(user.uid)
          .get()
          .then((userDoc) async {
        if (userDoc.exists) {
          if (userDoc.data.containsKey("profile_setup_complete")) {
            profileSetup = userDoc.data["profile_setup_complete"];
            if (profileSetup) {
              sharedPreferences.setString("u_name", userDoc.data["name"]);
              sharedPreferences.setString("u_bio", userDoc.data["bio"]);
              StorageReference storage = FirebaseStorage.instance.ref();
              storage
                  .child("profile_images")
                  .child(user.uid)
                  .getDownloadURL()
                  .then((url) {
                print(url);
                sharedPreferences.setString("u_image", url);
              });
            }
          }
          sharedPreferences.setBool("profile_setup_complete", profileSetup);
        }
      });
    });
  }

  _endDrawer() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8))),
      child: Consumer<Session>(builder: (context, session, child) {
        return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton(
                    onPressed: () {},
                    child: Container(
                      width: 200,
                      padding: EdgeInsets.only(
                          left: 8, top: 64, right: 8, bottom: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.person),
                          Padding(
                            padding: EdgeInsets.only(left: 16),
                            child:
                                FAText("Name", 18, FriskyColor.colorTextDark),
                          )
                        ],
                      ),
                    ),
                  ),
                  NavigationDrawerButton("Settings"),
                  NavigationDrawerButton("About"),
                ],
              ),
              FlatButton(
                color: FriskyColor.colorPrimary,
                child: Container(
                  width: 200,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Center(
                    child: FAText("Logout", 16, Colors.white),
                  ),
                ),
                onPressed: _signOut,
              ),
            ]);
      }),
    );
  }
}

class NavigationDrawerButton extends StatelessWidget {
  final String text;

  NavigationDrawerButton(this.text);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {},
      child: Container(
        width: 200,
        padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
        child: FAText(text, 16, FriskyColor.colorTextDark),
      ),
    );
  }
}
