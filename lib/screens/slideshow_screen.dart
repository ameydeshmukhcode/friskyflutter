import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

import '../frisky_colors.dart';

class SlideshowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
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
    );
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
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                title,
                style: TextStyle(fontFamily: "museoM", fontSize: 20),
              ),
            ),
            Text(
              description,
              style: TextStyle(fontFamily: "museoS", fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}
