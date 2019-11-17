import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../frisky_colors.dart';

class DineTabBillRequested extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: Text(
              "Bill Requested. The waiter will\ncollect payment from you.",
              style: TextStyle(
                  fontSize: 20,
                  color: FriskyColor().colorTextLight,
                  fontFamily: "museoS"),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 32, top: 16, right: 32),
            child: AspectRatio(
              aspectRatio: 1,
              child: SvgPicture.asset(
                'images/state_graphics/state_bill_requested.svg',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
