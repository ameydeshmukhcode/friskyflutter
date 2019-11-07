import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friskyflutter/structures/order_status.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../frisky_colors.dart';
import '../size_config.dart';
import 'package:date_format/date_format.dart';
import 'package:friskyflutter/structures/order_header.dart';
import 'package:friskyflutter/structures/order_item.dart';
import 'package:friskyflutter/widgets/card_order_item.dart';

class OrdersScreen extends StatefulWidget {
  final String tableName;
  const OrdersScreen(this.tableName) : super();
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

List<Object> mOrderList = new List<Object>();

class _OrdersScreenState extends State<OrdersScreen> {
  Stream<int> getOrders() async* {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Firestore.instance
        .collection("restaurants")
        .document(sp.getString("restaurant_id"))
        .collection("orders")
        .where("session_id", isEqualTo: sp.getString("session_id"))
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snaps) {
          if(snaps.documentChanges.isNotEmpty)
            {
              updateList(snaps);

            }

          else{
            print("else doc not chnages");
          }
          setState(() {
            print("setting");
          });
    });
  }



     updateList(snaps){

       mOrderList.clear();
       int docRank = snaps.documents.length;
       for (DocumentSnapshot documentSnapshot in snaps.documents) {
         Map<dynamic, dynamic> orderData = documentSnapshot.data["items"];
         String orderTime = formatDate(
             documentSnapshot.data["timestamp"].toDate(),
             [hh, ':', nn, ' ', am]).toString();
         OrderHeader orderHeader = new OrderHeader(orderTime, docRank);
         mOrderList.add(orderHeader);
         for (int i = 0; i < orderData.length; i++) {
           String itemID = orderData.keys.elementAt(i).toString();
           Map<dynamic, dynamic> itemData = orderData.values.elementAt(i);
           String name = itemData["name"];
           int cost = int.parse(itemData["cost"]);
           int quantity = itemData["quantity"];
           OrderItem orderItem =
           OrderItem(itemID, name, quantity, (quantity * cost));
           if (itemData["status"].toString().compareTo("pending") == 0) {
             orderItem.orderStatus = OrderStatus.pending;
           } else if (itemData["status"].toString().compareTo("accepted") == 0) {
             orderItem.orderStatus = OrderStatus.accepted;
           } else if (itemData["status"].toString().compareTo("rejected") == 0) {
             orderItem.orderStatus = OrderStatus.rejected;
           } else if (itemData["status"].toString().compareTo("cancelled") ==
               0) {
             orderItem.orderStatus = OrderStatus.cancelled;
           }
           mOrderList.add(orderItem);
         }
         docRank--;
       }
     }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: FriskyColor().colorTextDark),
        title: Text(
          "Your Order",
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
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              'TABLE ' + widget.tableName,
              style: TextStyle(
                  fontSize: SizeConfig.safeBlockVertical * 3,
                  color: FriskyColor().colorTextLight,
                  fontWeight: FontWeight.w500),
            ),
            decoration: BoxDecoration(
              color: FriskyColor().colorTableName,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Divider(
              thickness: 2,
            ),
          ),
          Flexible(
            child: StreamBuilder(
                initialData: Text("Loading"),
                stream: getOrders(),
                builder: (context, asyncSnapshot) {

                  return ListView.builder(
                      padding: EdgeInsets.all(0),
                      itemCount: mOrderList.length,
                      itemBuilder: (context, index) {
                        if (mOrderList[index].toString() ==
                            "Instance of 'OrderHeader'") {
                          OrderHeader header = mOrderList[index];
                          return Column(
                            children: <Widget>[
                              Text(
                                "Order # " +
                                    header.getRank().toString() +
                                    " - " +
                                    header.getTime(),
                                style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    color: FriskyColor().colorTextDark,
                                    fontSize:
                                        SizeConfig.safeBlockVertical * 2.5),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 8, 20, 0),
                                child: Divider(
                                  thickness: 2,
                                ),
                              )
                            ],
                          );
                        } else {
                          OrderItem item = mOrderList[index];
                          return OrderItemWidget(item.name, item.count,
                              item.total, item.orderStatus);
                        }
                      });

                }),
          ),
          Container(
            height: 10,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
