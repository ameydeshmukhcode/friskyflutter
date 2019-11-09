import 'package:flutter/material.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/dine_billrequested.dart';
import 'package:friskyflutter/screens/dine_orders.dart';
import 'package:friskyflutter/screens/home.dart';
import 'package:friskyflutter/screens/dine.dart';
import 'package:friskyflutter/screens/menuscreen.dart';
import 'package:friskyflutter/screens/visits.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'frisky_colors.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';
import 'provider_models/session.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<Session>(context, listen: false).getStatus();
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      onTap: (index) {
        setState(
          () {
            currentIndex = index;
            _tabController.animateTo(currentIndex, curve: Curves.easeOutBack);
          },
        );
      },
      currentIndex: currentIndex,
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
              badgeColor: FriskyColor().colorBadge,
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
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<Session>(
          // ignore: non_constant_identifier_names
          builder: (context, Session, child) {
        return Stack(
          children: <Widget>[
            TabBarView(
              children: [
                HomeTab(),
                Session.isSessionActive
                    ? (Session.isBillRequested ? BillRequested() : DineOrders())
                    : DineTab(),
                VisitTab(),
              ],
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
            ),
            Visibility(
                visible: Session.isSessionActive,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.white,
                    child: ListTile(
                      title: Text(
                        Session.isBillRequested
                            ? ("Bill Requested")
                            : ("Currently at"),
                        style: TextStyle(
                            fontSize: 14, color: FriskyColor().colorTextLight),
                      ),
                      subtitle: Text(
                          Session.isBillRequested
                              ? ("Bill Amount to Be Paid - " +
                                  Session.totalAmount)
                              : (Session.restaurantName +
                                  " - Table " +
                                  Session.tableName),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      trailing: Session.isBillRequested
                          ? SizedBox(
                              height: 1,
                            )
                          : OutlineButton(
                              color: Colors.lightGreen,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MenuScreen(
                                            Session.restaurantName,
                                            Session.tableName,
                                            Session.sessionID,
                                            Session.restaurantID)));
                              },
                              child: Text(
                                "Menu",
                                style: TextStyle(
                                    color: FriskyColor().colorPrimary),
                              ),
                              borderSide: BorderSide(
                                color: FriskyColor().colorPrimary,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(4.0),
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
              navigateToScan();
            },
            icon: Icon(MdiIcons.qrcode),
            label: Text("Scan QR Code"),
            backgroundColor: FriskyColor().colorPrimary,
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  getPermission() async {
    await PermissionHandler().requestPermissions([PermissionGroup.camera]);
    if (await checkForPermission()) {
      Navigator.pushNamed(context, "/scan");
    }
  }

  navigateToScan() async {
    if (await checkForPermission()) {
      Navigator.pushNamed(context, "/scan");
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
}
