import 'package:flutter/material.dart';
import 'package:friskyflutter/screens/dine_orders.dart';
import 'package:friskyflutter/screens/home.dart';
import 'package:friskyflutter/screens/dine.dart';
import 'package:friskyflutter/screens/menuscreen.dart';
import 'package:friskyflutter/screens/visits.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'frisky_colors.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart';
import 'package:friskyflutter/provider_models/session.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  int _page = 0;
  //bool session=false;
  // SharedPreferences sharedPreferences;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<Session>(context, listen: false).getStatus();
  }

  @override
  void initState() {
    super.initState();
    //getSession();
    //Provider.of<Session>(context).getStatus();
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  void navigationTapped(int page) {
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  Widget _bottomNavBar() {
    return BottomNavigationBar(
      onTap: navigationTapped,
      currentIndex: _page,
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
            return PageView(
              children: <Widget>[
                HomeTab(),
                Session.isSessionActive ? DineOrders() : DineTab(),
                VisitTab(),
              ],
              onPageChanged: onPageChanged,
              controller: _pageController,
            );
          }),
      bottomSheet: Consumer<Session>(
        builder: (context, session, child) {
          return Visibility(
              visible: session.isSessionActive,
              child: ListTile(
                title: Text(
                  "Currently at",
                  style: TextStyle(
                      fontSize: 14, color: FriskyColor().colorTextLight),
                ),
                subtitle: Text(
                    session.restaurantName + " - Table " + session.tableName,
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                trailing: OutlineButton(
                  color: Colors.lightGreen,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MenuScreen(
                                session.restaurantName,
                                session.tableName,
                                session.tableName,
                                session.restaurantName)));
                  },
                  child: Text(
                    "Menu",
                    style: TextStyle(color: FriskyColor().colorPrimary),
                  ),
                  borderSide: BorderSide(
                    color: FriskyColor().colorPrimary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(4.0),
                  ),
                ),
              ));
        },
      ),
      floatingActionButton: Consumer<Session>(
        // ignore: non_constant_identifier_names
          builder: (context, Session, child) {
            return Visibility(
              visible: !Session.isSessionActive,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pushNamed(context, "/scan");
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
}
