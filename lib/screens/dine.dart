import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/size_config.dart';

import '../frisky_colors.dart';

class DineTab extends StatefulWidget {
  @override
  _DineTabState createState() => _DineTabState();
}

class _DineTabState extends State<DineTab>
    with AutomaticKeepAliveClientMixin<DineTab> {




  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "You Haven't ordered anything yet.\nTo get the menu and start ordering.\nscan the QR code on the table.",
                style: TextStyle(
                    fontSize: 20, color: FriskyColor().colorTextLight),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                child: SvgPicture.asset(
                  'img/scanstateempty.svg',
                  height: SizeConfig.safeBlockVertical * 35,
                  width: SizeConfig.safeBlockHorizontal * 56,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
