import 'dart:collection';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'card_order_item.dart';
import '../../frisky_colors.dart';
import '../../provider_models/orders.dart';
import '../../provider_models/session.dart';
import '../../structures/order_header.dart';
import '../../structures/order_item.dart';
import '../../widgets/text_fa.dart';

class OrdersScreen extends StatefulWidget {
  final String tableName;
  const OrdersScreen(this.tableName) : super();
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<Object> mOrderList = new List<Object>();

  getListLength() {
    var _ordersProvider = Provider.of<Orders>(context, listen: true);
    if (_ordersProvider.ordersList.length == 0) {
      _ordersProvider.fetchData();
      return 0;
    } else {
      return _ordersProvider.ordersList.length;
    }
  }

  @override
  Widget build(BuildContext context) {
    var _ordersProvider = Provider.of<Orders>(context, listen: true);
    return WillPopScope(
      onWillPop: () async {
        _ordersProvider.resetOrdersList();
        _ordersProvider.resetBill();
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Your Orders",
                  style: TextStyle(
                      fontFamily: "Varela",
                      color: FriskyColor.colorPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                FAText(
                  'Table ' + widget.tableName,
                  14,
                  FriskyColor.colorPrimary,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 14, right: 16, bottom: 14),
              child: Material(
                borderRadius: BorderRadius.circular(2),
                color: FriskyColor.colorBadge,
                child: InkWell(
                  borderRadius: BorderRadius.circular(2),
                  onTap: () {
                    showConfirmAlert();
                  },
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: FAText("Bill", 14, Colors.white),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 2, right: 2),
                        child: Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            Flexible(
              child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: getListLength(),
                  itemBuilder: (context, index) {
                    if (_ordersProvider.ordersList[index] is OrderHeader) {
                      OrderHeader header = _ordersProvider.ordersList[index] ??
                          OrderHeader(" ", 0);
                      return Padding(
                        padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: FAText(
                            "Order #" +
                                header.rank.toString() +
                                " - " +
                                header.time,
                            12,
                            FriskyColor.colorTextLight),
                      );
                    } else {
                      OrderItem item = _ordersProvider.ordersList[index] ??
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
                  FAText("Item total", 14, FriskyColor.colorTextLight),
                  FAText("\u20B9" + _ordersProvider.billAmount, 14,
                      FriskyColor.colorTextLight),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 2, 24, 2),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FAText("Taxes", 14, FriskyColor.colorTextLight),
                  FAText("\u20B9" + _ordersProvider.gst, 14,
                      FriskyColor.colorTextLight),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 2, 24, 32),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FAText("Total", 16, FriskyColor.colorTextDark),
                  FAText("\u20B9" + _ordersProvider.amountPayable, 16,
                      FriskyColor.colorTextDark),
                ],
              ),
            ),
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
          title: FAText("Clear bill", 20, FriskyColor.colorTextDark),
          content: FAText(
              "You are about to request the bill and end your session. You won\'t be able to order anymore items after you confirm.",
              14,
              FriskyColor.colorTextLight),
          actions: <Widget>[
            FlatButton(
              splashColor: Colors.black12,
              onPressed: () {
                Navigator.pop(context);
              },
              child: FAText("Cancel", 14, FriskyColor.colorPrimary),
            ),
            FlatButton(
              color: FriskyColor.colorPrimary,
              onPressed: () {
                _requestBill();
              },
              child: FAText("Clear", 14, Colors.white),
            )
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
            title: FAText("Requesting the Bill", 20, FriskyColor.colorTextDark),
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

  _requestBill() async {
    var _ordersProvider = Provider.of<Orders>(context, listen: false);
    var _sessionProvider = Provider.of<Session>(context, listen: false);
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
          _ordersProvider.amountPayable.isEmpty
              ? "0"
              : _ordersProvider.amountPayable);
      _ordersProvider.resetOrdersList();
      _ordersProvider.resetBill();
      _sessionProvider.isBillRequested = true;
      _sessionProvider.updateSessionStatus();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('home', (Route route) => false);
    }).catchError((error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Something went wrong.\nTry again.");
      print("Error _requestBill" + error.toString());
    });
  }
}
