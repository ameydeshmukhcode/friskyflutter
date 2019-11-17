import 'package:flutter/material.dart';
import 'package:friskyflutter/provider_models/session.dart';
import '../frisky_colors.dart';
import 'package:provider/provider.dart';

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
        iconTheme: IconThemeData(color: FriskyColor().colorTextDark),
        title: Text(
          "You're at",
          style: TextStyle(
            fontFamily: "museoS",
            color: FriskyColor().colorTextDark,
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
                            color: FriskyColor().colorTextLight,
                            fontSize: 20,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Table ' + Session.tableName,
                            style: TextStyle(
                                fontSize: 20,
                                color: FriskyColor().colorTextLight,
                                fontFamily: "museoM"),
                          ),
                          decoration: BoxDecoration(
                            color: FriskyColor().colorTableName,
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
