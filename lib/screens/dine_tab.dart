import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:provider/provider.dart';

import '../frisky_colors.dart';

class DineTab extends StatefulWidget {
  @override
  _DineTabState createState() => _DineTabState();
}

class _DineTabState extends State<DineTab> {
  @override
  Widget build(BuildContext context) {
    // ignore: missing_return
    return Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<Session>(builder: (context, session, child) {
          if (!session.isSessionActive) {
            return DineTabDefault();
          } else {
            if (session.isBillRequested) {
              return DineTabBillRequested();
            } else {
              return DineTabActive();
            }
          }
        }));
  }
}

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
                  fontSize: 20,
                  color: FriskyColor.colorTextLight,
                  fontFamily: "museoS"),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 32, top: 16, right: 32),
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

class DineTabActive extends StatefulWidget {
  @override
  _DineTabActiveState createState() => _DineTabActiveState();
}

class _DineTabActiveState extends State<DineTabActive> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: FriskyColor.colorTextDark),
        title: Text(
          "You're at",
          style: TextStyle(
            fontFamily: "museoS",
            color: FriskyColor.colorTextDark,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Consumer<Session>(
            // ignore: non_constant_identifier_names
            builder: (context, Session, child) {
              return Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                color: Colors.white,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          Session.restaurantName,
                          style: TextStyle(
                            fontFamily: "museoM",
                            color: FriskyColor.colorTextLight,
                            fontSize: 20,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Table ' + Session.tableName,
                            style: TextStyle(
                                fontSize: 20,
                                color: FriskyColor.colorTextLight,
                                fontFamily: "museoM"),
                          ),
                          decoration: BoxDecoration(
                            color: FriskyColor.colorTableName,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

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
                  color: FriskyColor.colorTextLight,
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
