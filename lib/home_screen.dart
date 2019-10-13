import 'package:flutter/material.dart';
import 'package:friskyflutter/screens/Home.dart';
import 'package:friskyflutter/screens/Restaurants.dart';
import 'package:friskyflutter/screens/visits.dart';
import 'commonwidgets/fab.dart';
import 'frisky_colors.dart';

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
            "Restaurants",
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
      backgroundColor: FriskyColor().white,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(children: <Widget>[
        HomeTab(),
        RestautantsTab(),
        VisitTab(),
      ], onPageChanged: onPageChanged, controller: _pageController),
      floatingActionButton: FriskyFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _bottomNavBar(),
    );
  }
}
