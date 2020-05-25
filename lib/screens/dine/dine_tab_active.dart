import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/menu/menu_screen.dart';
import 'package:friskyflutter/widgets/text_fa.dart';
import 'package:provider/provider.dart';

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
                                SvgPicture.asset(
                                  'images/icons/ic_menu_dine.svg',
                                  height: 50,
                                  width: 50,
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
