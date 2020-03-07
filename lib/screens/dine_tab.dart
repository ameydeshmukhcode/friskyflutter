import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/widgets/text_fa.dart';
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
                  fontFamily: "Varela",
                  fontSize: 20,
                  color: FriskyColor.colorTextLight),
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Consumer<Session>(
                // ignore: non_constant_identifier_names
                builder: (context, Session, child) {
                  return Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          Session.restaurantName,
                          style: TextStyle(
                              fontFamily: "Varela",
                              color: FriskyColor.colorPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        FAText(
                          'Table ' + Session.tableName,
                          14,
                          FriskyColor.colorPrimary,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ));
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
              "Bill Requested. The waiter will collect payment from you.",
              style: TextStyle(
                  fontFamily: "Varela",
                  fontSize: 20,
                  color: FriskyColor.colorTextLight),
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
