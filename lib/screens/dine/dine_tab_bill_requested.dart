import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/frisky_colors.dart';

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
              "Bill requested. The waiter will collect payment from you.",
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
                'images/state_graphics/state_bill_requested.svg',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
