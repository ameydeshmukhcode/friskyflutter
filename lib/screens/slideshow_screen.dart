import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/screens/auth/auth_checker.dart';
import 'package:friskyflutter/widgets/text_fa.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../frisky_colors.dart';

class SlideshowScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SlideshowScreenState();
}

class _SlideshowScreenState extends State<SlideshowScreen> {
  int _currentPage;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page.toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        PageView(
          controller: _pageController,
          children: <Widget>[
            Slide(
                "Scan QR code",
                "Scan QR codes on tables at any restaurant to start your dining experience.",
                'images/state_graphics/slide_scan.svg'),
            Slide(
                "Instant Menu",
                "Access the menu and browse your favorite dishes instantly.\nPlace orders without having to wait.",
                'images/state_graphics/slide_menu.svg'),
            Slide(
                "Keep Tabs",
                "Get real-time bill and order updates and check your previous orders at anytime.",
                'images/state_graphics/slide_summary.svg')
          ],
        ),
        Visibility(
          visible: _currentPage < 2,
          child: Positioned(
            left: 24,
            bottom: 16,
            child: FlatButton(
              onPressed: () {
                _endSlideshowAndGo();
              },
              child: FAText("Skip", 18, FriskyColor.colorPrimary),
            ),
          ),
        ),
        Positioned(
          right: 24,
          bottom: 16,
          child: FlatButton(
            onPressed: () {
              if (_currentPage == 2) {
                _endSlideshowAndGo();
              } else {
                _pageController.animateToPage(_currentPage + 1,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOutQuint);
              }
            },
            child: Row(
              children: <Widget>[
                FAText(_currentPage == 2 ? "Continue" : "Next", 18,
                    FriskyColor.colorPrimary),
                Icon(
                  Icons.chevron_right,
                  color: FriskyColor.colorPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _endSlideshowAndGo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool("slideshow_complete", true);
    Navigator.pushAndRemoveUntil(
        context,
        new MaterialPageRoute(builder: (context) => AuthChecker()),
        (Route route) => false);
  }
}

class Slide extends StatelessWidget {
  final String title, description, imagePath;

  Slide(this.title, this.description, this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.only(left: 24, right: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1,
              child: SvgPicture.asset(imagePath),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8),
              child: FAText(title, 20, FriskyColor.colorTextDark),
            ),
            FAText(description, 18, FriskyColor.colorTextLight)
          ],
        ),
      ),
    );
  }
}
