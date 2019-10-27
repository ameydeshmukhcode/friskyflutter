import 'package:flutter/material.dart';
import 'package:friskyflutter/screens/home.dart';
import 'package:friskyflutter/screens/dine.dart';
import 'package:friskyflutter/screens/visits.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'frisky_colors.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  int _page = 0;
  @override
  void initState() {
    super.initState();
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
          icon: Icon(Icons.restaurant),
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
      body: PageView(
        children: <Widget>[
          HomeTab(),
          DineTab(),
          VisitTab(),
        ],
        onPageChanged: onPageChanged,
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.camera);
          navigateToScan();
        },
        icon: Icon(MdiIcons.qrcode),
        label: Text("Scan QR Code"),
        backgroundColor: FriskyColor().colorPrimary,
      ),
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
