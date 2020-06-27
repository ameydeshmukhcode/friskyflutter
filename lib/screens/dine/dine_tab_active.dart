import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friskyflutter/structures/order_item.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    var ordersProvider = Provider.of<Orders>(context, listen: true);
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<Session>(
            // ignore: non_constant_identifier_names
            builder: (context, Session, child) {
              return Column(
                children: <Widget>[
                  TableInfoWidget(Session: Session,),
                  ordersProvider.isOrderActive ? LastOrdersWidget(Session: Session):StartOrderWidget(Session: Session,),
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

class LastOrdersWidget extends StatelessWidget {
  final Session;

  const LastOrdersWidget({Key key, this.Session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var ordersProvider = Provider.of<Orders>(context, listen: true);
    return Container(
       padding: const EdgeInsets.all(16.0),
       height: 170,
       width: double.maxFinite,
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         crossAxisAlignment: CrossAxisAlignment.center,
         children: <Widget>[
           Flexible(
             flex: 1,
             child: Column(
               mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: <Widget>[
                 FAText("Last Orderd Item", 20,
                     FriskyColor.colorPrimary),
                 Flexible(
                   child: ListView.builder(itemCount: ordersProvider.ordersList.length,
                     itemBuilder: (BuildContext context, int index) {
                       if (ordersProvider.ordersList[index] is OrderItem){
                         OrderItem item = ordersProvider.ordersList[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item.name,  style: TextStyle(fontFamily: "Varela", fontSize:16, color: FriskyColor.colorTextDark),textAlign: TextAlign.center,maxLines: 1,),
                        );
                       }
                       return Container();
                     },),
                 ),
               ],
             ),
           ),
           Flexible(
             flex: 1,
             child: Container(
               child:  Material(
                 borderRadius: BorderRadius.circular(8),
                 color: FriskyColor.colorBadge,
                 child: InkWell(
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
                     padding: const EdgeInsets.all(16.0),
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
               SvgPicture.asset(
                         'images/icons/ic_menu_dine.svg',
                         width: 75,
               ),
                         Padding(
                           padding: const EdgeInsets.only(top:8.0),
                           child: FAText(
                               "Order More",
                               18,
                               Colors.white),
                         ),
             ],
                     ),
                   ),
                 ),
               ),),
           ),
         ],
       ),
     );
  }
}

class StartOrderWidget extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final Session;
  const StartOrderWidget({Key key,this.Session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                         "Start ordering",
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
    );
  }
}

class TableInfoWidget extends StatelessWidget {

  final Session;
  const TableInfoWidget({Key key, this.Session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
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