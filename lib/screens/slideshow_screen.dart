import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';

class SlideshowScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[
        Slide(
            "Scan QR code",
            "Scan QR codes on tables at any restaurant to start your dining experience.",
            'images/state_graphics/state_scan_qr.svg'),
        Slide(
            "Instant Menu",
            "Access the menu and browse your favorite dishes instantly.\nPlace orders without having to wait.",
            'images/state_graphics/state_scan_qr.svg'),
        Slide(
            "Keep Tabs",
            "Get real-time bill and order updates and check your previous orders at anytime.",
            'images/state_graphics/state_scan_qr.svg')
      ],
    );
  }
}

class Slide extends StatelessWidget {
  final String title, description, imagePath;

  Slide(this.title, this.description, this.imagePath);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
      padding: EdgeInsets.only(left: 24, right: 24),
      child: Column(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: SvgPicture.asset(
              imagePath,
            ),
          ),
          Text(title),
          Text(description)
        ],
      ),
    ));
  }
}
