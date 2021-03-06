import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

import '../menu/card_order_item.dart';
import '../../frisky_colors.dart';
import '../../widgets/text_fa.dart';
import '../../structures/order_item.dart';

class VisitSummary extends StatefulWidget {
  final String sessionID;
  final String restaurantID;
  final String restaurantName;
  VisitSummary(
      {Key key,
      @required this.sessionID,
      @required this.restaurantID,
      @required this.restaurantName})
      : super(key: key);

  @override
  _VisitSummaryState createState() => _VisitSummaryState();
}

class _VisitSummaryState extends State<VisitSummary> {
  bool isLoading = true;

  List<OrderItem> _orderItems = List<OrderItem>();
  Future _orderItemsList;
  Timestamp endTime;
  String amountPayable;
  String gst;
  String billAmount;

  @override
  void initState() {
    super.initState();
    _getVisitSummary().whenComplete(() {
      _orderItemsList = _getOrders().whenComplete(() {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FAText("Visit Summary", 20, Colors.black),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      // body: //_visitsList(),
      body: _orderSummary(),
    );
  }

  Widget _orderSummary() {
    return FutureBuilder(
      future: _orderItemsList,
      builder: (context, snapshot) {
        if (isLoading) {
          return Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                      FriskyColor.colorPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return CustomScrollView(
            slivers: <Widget>[
              SliverFillRemaining(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      widget.restaurantName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Varela",
                          color: Colors.black,
                          fontSize: 20),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                    ),
                    Text(
                      formatDate(endTime.toDate(),
                          [dd, ' ', M, ' ', yyyy, ' ', hh, ':', nn, ' ', am]),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Varela",
                          color: Colors.black,
                          fontSize: 14),
                    ),
                    Divider(
                      indent: 8,
                      endIndent: 8,
                    ),
                    ListView.builder(
                        padding: EdgeInsets.only(bottom: 0),
                        itemCount: _orderItems.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return OrderItemWidget(
                              _orderItems[index].name,
                              _orderItems[index].count,
                              _orderItems[index].total,
                              _orderItems[index].orderStatus);
                        }),
                    Divider(
                      indent: 8,
                      endIndent: 8,
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FAText("Item total", 16, FriskyColor.colorTextLight),
                          FAText("\u20B9 " + billAmount, 16,
                              FriskyColor.colorTextLight)
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FAText("Taxes", 16, FriskyColor.colorTextLight),
                          FAText(
                              "\u20B9 " + gst, 16, FriskyColor.colorTextLight)
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          FAText("Total", 20, FriskyColor.colorTextDark),
                          FAText("\u20B9 " + amountPayable, 20,
                              FriskyColor.colorTextDark)
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        }
      },
    );
  }

  Future _getVisitSummary() async {
    await Firestore.instance
        .collection("restaurants")
        .document(widget.restaurantID)
        .collection("sessions")
        .document(widget.sessionID)
        .get()
        .then((data) async {
      endTime = data["end_time"];
      amountPayable = data["amount_payable"];
      gst = data["gst"];
      billAmount = data["bill_amount"];
    });
  }

  Future _getOrders() async {
    await Firestore.instance
        .collection("restaurants")
        .document(widget.restaurantID)
        .collection("orders")
        .where("session_id", isEqualTo: widget.sessionID)
        .getDocuments()
        .then((data) async {
      for (DocumentSnapshot documentSnapshot in data.documents) {
        Map<dynamic, dynamic> items = documentSnapshot.data["items"];
        for (int i = 0; i < items.length; i++) {
          String itemID = items.keys.elementAt(i).toString();
          Map<dynamic, dynamic> itemData = items.values.elementAt(i);
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

          if (orderItem.orderStatus != OrderStatus.pending) {
            _orderItems.add(orderItem);
          }
        }
      }
    });

    return _orderItems;
  }
}
