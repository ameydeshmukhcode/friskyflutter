import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/widgets/text_fa.dart';
import 'package:provider/provider.dart';

import '../frisky_colors.dart';
import 'menu/menu_screen.dart';

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

class DineTabActive extends StatefulWidget {
  @override
  _DineTabActiveState createState() => _DineTabActiveState();
}

class _DineTabActiveState extends State<DineTabActive> {
  @override
  Widget build(BuildContext context) {
    var _ordersProvider = Provider.of<Orders>(context, listen: true);

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<Session>(
            // ignore: non_constant_identifier_names
            builder: (context, Session, child) {
              return Column(
                children: <Widget>[
                  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        FAText(
                          'You\'re at',
                          16,
                          FriskyColor.colorPrimary,
                        ),
                        Text(
                          Session.restaurantName,
                          style: TextStyle(
                              fontFamily: "Varela",
                              color: FriskyColor.colorPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        FAText(
                          'Table ' + Session.tableName,
                          16,
                          FriskyColor.colorPrimary,
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    child: Material(
                      borderRadius: BorderRadius.circular(8),
                      color: FriskyColor.colorBadge,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (!Session.isBillRequested) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuScreen(
                                        Session.restaurantName,
                                        Session.tableName,
                                        Session.sessionID,
                                        Session.restaurantID)));
                          }
                        },
                        child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Icon(
                                  Icons.restaurant_menu,
                                  size: 50,
                                  color: Colors.white,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    FAText(
                                        _ordersProvider.isOrderActive
                                            ? "Order more"
                                            : "Start ordering",
                                        24,
                                        Colors.white),
                                    Container(
                                      padding: EdgeInsets.only(bottom: 8),
                                    ),
                                    FAText("(tap to access menu)", 20,
                                        Colors.white),
                                  ],
                                ),
                              ],
                            )),
                      ),
                    ),
                  ),
                ],
              );
            },
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
