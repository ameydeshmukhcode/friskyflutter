import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../frisky_colors.dart';
import '../size_config.dart';

class BillRequested extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Bill Requested. The waiter will\ncollect payment from you.",
              style:
                  TextStyle(fontSize: 20, color: FriskyColor().colorTextLight),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              child: SvgPicture.asset(
                'img/state_graphics/state_scan_qr.svg',
                height: SizeConfig.safeBlockVertical * 35,
                width: SizeConfig.safeBlockHorizontal * 56,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
