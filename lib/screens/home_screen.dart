import 'dart:io';

import 'package:badges/badges.dart';
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

import '../frisky_colors.dart';
import '../provider_models/session.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  List<Widget> _pages = [RestaurantsTab(), DineTab(), VisitsTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Visibility(
        visible: !kReleaseMode,
        child: ListView(
          children: <Widget>[
            FlatButton(
              onPressed: null,
              child: Text("Enable Dummy Session"),
            )
          ],
        ),
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
                          ? SizedBox()
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
            style: TextStyle(
                color: FriskyColor().colorTextDark, fontFamily: "museoM"),
          ),
          content: Text(
            "Enable 'Camera' for Frisky under Settings to be able to scan QR codes.",
            style: TextStyle(
                color: FriskyColor().colorTextLight, fontFamily: "museoS"),
          ),
          actions: <Widget>[
            FlatButton(
                color: FriskyColor().colorPrimary,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontFamily: "museoM"),
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
            style: TextStyle(
                color: FriskyColor().colorTextDark, fontFamily: "museoM"),
          ),
          content: Text(
            "Allow camera permission to be able to scan QR codes.",
            style: TextStyle(
                color: FriskyColor().colorTextLight, fontFamily: "museoS"),
          ),
          actions: <Widget>[
            FlatButton(
                color: FriskyColor().colorPrimary,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontFamily: "museoM"),
                ))
          ],
        );
      },
      barrierDismissible: false,
    );
  }
}
