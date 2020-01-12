import 'dart:collection';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/dine_tab.dart';
import 'package:friskyflutter/screens/qr_scan.dart';
import 'package:friskyflutter/screens/restaurants_tab.dart';
import 'package:friskyflutter/screens/menu_screen.dart';
import 'package:friskyflutter/screens/visits_tab.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../frisky_colors.dart';
import '../provider_models/session.dart';
import 'sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  String sessionID, restaurantID, restaurantName, tableID, tableName;
  List<Widget> _pages = [RestaurantsTab(), DineTab(), VisitsTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEdgeDragWidth: 0,
      endDrawer: Container(
        color: Colors.white,
        child: Column(
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
                            child: Text(
                              "Name",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  NavigationDrawerButton("Location"),
                  NavigationDrawerButton("Payments"),
                  NavigationDrawerButton("Order History"),
                  NavigationDrawerButton("Settings"),
                  NavigationDrawerButton("About"),
                  Visibility(
                    visible: !kReleaseMode,
                    child: FlatButton(
                      onPressed: _createUserSession,
                      child: Container(
                        width: 200,
                        padding: EdgeInsets.fromLTRB(8, 16, 8, 16),
                        child: Text(
                          "Enable Dummy Session",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              FlatButton(
                color: FriskyColor.colorPrimary,
                child: Container(
                  width: 200,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Center(
                    child: Text(
                      "Logout",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
                onPressed: _signOut,
              ),
            ]),
      ),
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MenuScreen(
                                    session.restaurantName,
                                    session.tableName,
                                    session.sessionID,
                                    session.restaurantID)));
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
                                      ? ("Bill Requested")
                                      : (session.restaurantName),
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    session.isBillRequested
                                        ? ("Bill Amount to Be Paid - " +
                                            session.totalAmount)
                                        : ("Table " + session.tableName),
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                            Visibility(
                              visible: !session.isBillRequested,
                              child: FlatButton(
                                color: Colors.white,
                                onPressed: () {},
                                child: Text("Menu"),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
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
              // PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
              _startScanner();
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
            ),
            backgroundColor: FriskyColor.colorPrimary,
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
          ),
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
          title: Text(
            "Dine",
          ),
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.receipt,
          ),
          title: Text(
            "Visits",
          ),
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

  _showNeedCameraAlertiOS() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Allow Camera",
            style: TextStyle(color: FriskyColor.colorTextDark),
          ),
          content: Text(
            "Enable 'Camera' for Frisky under Settings to be able to scan QR codes.",
            style: TextStyle(color: FriskyColor.colorTextLight),
          ),
          actions: <Widget>[
            FlatButton(
                color: FriskyColor.colorPrimary,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ))
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
          title: Text(
            "Camera Needed",
            style: TextStyle(color: FriskyColor.colorTextDark),
          ),
          content: Text(
            "Allow camera permission to be able to scan QR codes.",
            style: TextStyle(color: FriskyColor.colorTextLight),
          ),
          actions: <Widget>[
            FlatButton(
                color: FriskyColor.colorPrimary,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ))
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

  _createUserSession() async {
    Map<String, Object> userdata = new HashMap<String, Object>();
    userdata["restaurant"] = "6mB4DZdwKHC5xe0sBZ0V";
    userdata["table"] = "SIZYb4BOoCfwHEt8fMck";
    await CloudFunctions.instance
        .getHttpsCallable(functionName: "createUserSession")
        .call(userdata)
        .then((getData) async {
      Map<String, dynamic> resultData = Map<String, dynamic>.from(getData.data);
      restaurantName = resultData["restaurant_name"];
      tableName = resultData["table_name"];
      sessionID = resultData["session_id"];
      await _setPreferences();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MenuScreen(
                  restaurantName, tableName, sessionID, restaurantID)));
    }, onError: (error) {});
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
        child: Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
