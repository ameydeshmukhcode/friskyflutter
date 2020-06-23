import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../menu/menu_screen.dart';
import '../../frisky_colors.dart';
import '../../provider_models/session.dart';
import '../../provider_models/orders.dart';
import '../../widgets/text_fa.dart';

class DineTabActive extends StatefulWidget {
  @override
  _DineTabActiveState createState() => _DineTabActiveState();
}

class _DineTabActiveState extends State<DineTabActive> {
  String restaurantID;

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
                                  height: 75,
                                  width: 75,
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
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FAText("The restaurant recommends...", 20,
                            FriskyColor.colorPrimary),
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                        ),
                        Container(
                            decoration: BoxDecoration(color: Colors.black12),
                            height: 160,
                            child: FutureBuilder(
                                future: _getRecommendedItems(),
                                builder: (context, snapshot) {
                                  // ignore: missing_return
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                        new AlwaysStoppedAnimation<Color>(
                                          FriskyColor.colorPrimary,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return ListView.builder(
                                        itemCount: snapshot.data.length,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return MenuItemTile(
                                              snapshot.data[index].data['name'],
                                              snapshot
                                                  .data[index].data['cost']);
                                        });
                                  }
                                })
                          // ListView(
//                            scrollDirection: Axis.horizontal,
//                            //shrinkWrap: true,
//                            children: <Widget>[
//                              MenuItemTile(),
//                              MenuItemTile(),
//                              MenuItemTile(),
//                              MenuItemTile(),
//                              MenuItemTile(),
//                              MenuItemTile()
//                            ],
//                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ));
  }

  Future _getRecommendedItems() async {
    var firestore = Firestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection("restaurants")
        .document(await SharedPreferences.getInstance()
        .then((prefs) => prefs.getString("restaurant_id")))
        .collection("items")
        .where('recommended', isEqualTo: true)
        .orderBy('name')
        .getDocuments();
    return querySnapshot.documents;
  }
}

class MenuItemTile extends StatelessWidget {
  final String name;
  final String cost;

  MenuItemTile(this.name, this.cost);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: 116,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 96,
                width: 96,
                child: Center(
                  child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: "Varela"),
                          ),
                          Text(
                            "\u20B9 " + cost,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: "Varela"),
                          )
                        ],
                      )),
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            Container(
              height: 26,
              width: 80,
              child: MaterialButton(
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                color: FriskyColor.colorBadge,
                onPressed: () {},
                child: Center(
                  child: FAText("Add", 14, Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}