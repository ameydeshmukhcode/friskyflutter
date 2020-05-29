import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/frisky_colors.dart';

class DineTabDefault extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 32, right: 32),
            child: Text(
              "You haven't ordered anything yet. To get the menu and start ordering. Scan the QR code on the table.",
              style: TextStyle(
                  fontFamily: "Varela",
                  fontSize: 20,
                  color: FriskyColor.colorTextLight),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 32, top: 8, right: 32),
            child: AspectRatio(
              aspectRatio: 1,
              child: SvgPicture.asset(
                'images/state_graphics/state_scan_qr.svg',
              ),
            ),
          ),
        ],
      ),
    );
  }
}