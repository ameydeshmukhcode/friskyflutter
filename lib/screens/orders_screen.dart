import 'dart:collection';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../frisky_colors.dart';
import 'package:friskyflutter/structures/order_header.dart';
import 'package:friskyflutter/structures/order_item.dart';
import 'package:friskyflutter/widgets/card_order_item.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  final String tableName;
  const OrdersScreen(this.tableName) : super();
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Object> mOrderList = new List<Object>();
  getListLength() {
    if (Provider.of<Orders>(context, listen: true).mOrderList.length == 0) {
      Provider.of<Orders>(context, listen: true).fetchData();
      return 0;
    } else {
      return Provider.of<Orders>(context, listen: true).mOrderList.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);

        Provider.of<Orders>(context, listen: true).resetOrdersList();
        return Provider.of<Orders>(context, listen: true).resetBill();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: FriskyColor.colorTextDark),
          title: Text(
            "Your Order",
            style: TextStyle(
              color: FriskyColor.colorTextDark,
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
                'Table ' + widget.tableName,
                style:
                    TextStyle(fontSize: 20, color: FriskyColor.colorTextLight),
              ),
              decoration: BoxDecoration(
                color: FriskyColor.colorTableName,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Divider(
                thickness: 1,
              ),
            ),
            Flexible(
              child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: getListLength(),
                  itemBuilder: (context, index) {
                    if (Provider.of<Orders>(context, listen: true)
                            .mOrderList[index]
                            .toString() ==
                        "Instance of 'OrderHeader'") {
                      OrderHeader header =
                          Provider.of<Orders>(context, listen: true)
                                  .mOrderList[index] ??
                              OrderHeader(" ", 0);
                      return Column(
                        children: <Widget>[
                          Text(
                            "Order # " +
                                header.rank.toString() +
                                " - " +
                                header.time,
                            style: TextStyle(
                                color: FriskyColor.colorTextDark, fontSize: 14),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 32, right: 32),
                            child: Divider(
                              thickness: 1,
                            ),
                          )
                        ],
                      );
                    } else {
                      OrderItem item =
                          Provider.of<Orders>(context, listen: true)
                                  .mOrderList[index] ??
                              OrderItem("", "", 0, 0);
                      return OrderItemWidget(
                          item.name, item.count, item.total, item.orderStatus);
                    }
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Divider(
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 2, 24, 2),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Cart Total",
                    style: TextStyle(
                        color: FriskyColor.colorTextDark, fontSize: 14),
                  ),
                  Text(
                    "\u20B9" +
                        Provider.of<Orders>(context, listen: true).billAmount,
                    style: TextStyle(
                        color: FriskyColor.colorTextDark, fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 2, 24, 2),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "GST",
                    style: TextStyle(
                        color: FriskyColor.colorTextDark, fontSize: 14),
                  ),
                  Text(
                    "\u20B9" + Provider.of<Orders>(context, listen: true).gst,
                    style: TextStyle(
                        color: FriskyColor.colorTextDark, fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 2, 24, 2),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Final Total",
                    style: TextStyle(
                        color: FriskyColor.colorTextDark, fontSize: 16),
                  ),
                  Text(
                    "\u20B9" +
                        Provider.of<Orders>(context, listen: true)
                            .amountPayable,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 24, right: 24, bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      padding: EdgeInsets.all(8),
                      color: FriskyColor.colorBadge,
                      onPressed: () {
                        showConfirmAlert();
                      },
                      child: Text(
                        "Clear Bill",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 8),
                  ),
                  Expanded(
                    child: OutlineButton(
                      padding: EdgeInsets.all(8),
                      highlightedBorderColor: FriskyColor.colorPrimary,
                      color: Colors.lightGreen,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Order More",
                        style: TextStyle(
                            color: FriskyColor.colorPrimary, fontSize: 20),
                      ),
                      borderSide: BorderSide(
                        color: FriskyColor.colorPrimary,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  showConfirmAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Clear Bill?",
            style: TextStyle(color: FriskyColor.colorTextDark),
          ),
          content: Text(
            "You are about to request the bill and end your session. You won\'t be able to order anymore items after you confirm.",
            style: TextStyle(color: FriskyColor.colorTextLight),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel",
                  style: TextStyle(color: FriskyColor.colorPrimary)),
            ),
            FlatButton(
                color: FriskyColor.colorPrimary,
                onPressed: () {
                  requestBill();
                },
                child: Text(
                  "Clear",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  showBillClearing() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              "Requesting the Bill",
              style: TextStyle(color: FriskyColor.colorTextDark),
            ),
            content: Wrap(
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                      FriskyColor.colorPrimary,
                    ),
                  ),
                )
              ],
            ));
      },
      barrierDismissible: false,
    );
  }

  requestBill() async {
    Navigator.pop(context);
    showBillClearing();
    CloudFunctions cloudFunctions = CloudFunctions.instance;
    SharedPreferences sp = await SharedPreferences.getInstance();
    Map<String, Object> data = new HashMap<String, Object>();
    data["restaurant"] = sp.getString("restaurant_id");
    data["table"] = sp.getString("table_id");
    data["session"] = sp.getString("session_id");
    await cloudFunctions
        .getHttpsCallable(functionName: "requestBill")
        .call(data)
        .then((result) {
      sp.setBool("bill_requested", true);
      sp.setString(
          "total_Amount",
          Provider.of<Orders>(context, listen: true).amountPayable.isEmpty
              ? "0"
              : Provider.of<Orders>(context, listen: true).amountPayable);
      Provider.of<Orders>(context, listen: true).resetOrdersList();
      Provider.of<Orders>(context, listen: true).resetBill();
      Navigator.popUntil(
        context,
        ModalRoute.withName(Navigator.defaultRouteName),
      );
      Provider.of<Session>(context, listen: true).isBillRequested = true;
    }).catchError((error) {
      Navigator.pop(context);
      print(error.toString());
    });
  }
}
