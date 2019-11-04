import 'package:flutter/material.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/size_config.dart';
import '../frisky_colors.dart';
import 'package:provider/provider.dart';

class DineOrders extends StatefulWidget {
  @override
  _DineOrdersState createState() => _DineOrdersState();
}

class _DineOrdersState extends State<DineOrders> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: FriskyColor().colorTextDark),
        title: Text(
          "You're at",
          style: TextStyle(
            fontWeight: FontWeight.w300,
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
                height: SizeConfig.safeBlockVertical * 10,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(
                          Session.restaurantName,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: FriskyColor().colorTextLight,
                            fontSize: SizeConfig.safeBlockVertical * 3,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Table ' + Session.tableName,
                            style: TextStyle(
                                fontSize: SizeConfig.safeBlockVertical * 3,
                                color: FriskyColor().colorTextLight,
                                fontWeight: FontWeight.w500),
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
