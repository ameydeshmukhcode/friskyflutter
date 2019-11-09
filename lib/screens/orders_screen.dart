import 'dart:collection';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../frisky_colors.dart';
import '../size_config.dart';
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
      //
      Provider.of<Orders>(context, listen: true).fetchData();
      print("insde get len if");

      return 0;
    } else {
      print("insde get len else");

      // Provider.of<Orders>(context, listen: true).getOrders();
      // Provider.of<Bill>(context, listen: true).getBillDetails();
      return Provider.of<Orders>(context, listen: true).mOrderList.length;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
                                header.getRank().toString() +
                                " - " +
                                header.getTime(),
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: FriskyColor().colorTextDark,
                                fontSize: SizeConfig.safeBlockVertical * 2.5),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                            child: Divider(
                              thickness: 2,
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
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
              child: Divider(
                thickness: 2,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 30, right: 30, top: 8, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Cart Total",
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: FriskyColor().colorTextDark,
                        fontSize: SizeConfig.safeBlockVertical * 2.2),
                  ),
                  Text(
                    "\u20B9" +
                        Provider.of<Orders>(context, listen: true).billAmount,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: FriskyColor().colorTextDark,
                        fontSize: SizeConfig.safeBlockVertical * 2.2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "GST",
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: FriskyColor().colorTextDark,
                        fontSize: SizeConfig.safeBlockVertical * 2.2),
                  ),
                  Text(
                    "\u20B9" + Provider.of<Orders>(context, listen: true).gst,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: FriskyColor().colorTextDark,
                        fontSize: SizeConfig.safeBlockVertical * 2.2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, right: 30, bottom: 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Final Total",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: FriskyColor().colorTextDark,
                        fontSize: SizeConfig.safeBlockVertical * 3),
                  ),
                  Text(
                    "\u20B9" +
                        Provider.of<Orders>(context, listen: true)
                            .amountPayable,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: SizeConfig.safeBlockVertical * 3),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    height: SizeConfig.safeBlockHorizontal * 12,
                    width: SizeConfig.safeBlockVertical * 22,
                    padding: EdgeInsets.all(0),
                    child: FlatButton(
                      padding: EdgeInsets.all(0),
                      color: FriskyColor().colorBadge,
                      onPressed: () {
                        showConfirmAlert();
                      },
                      child: Text(
                        "Clear Bill",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConfig.safeBlockVertical * 3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                  Container(
                    height: SizeConfig.safeBlockHorizontal * 12,
                    width: SizeConfig.safeBlockVertical * 22,
                    child: OutlineButton(
                      color: Colors.lightGreen,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Order More",
                        style: TextStyle(
                            color: FriskyColor().colorPrimary,
                            fontSize: SizeConfig.safeBlockVertical * 3),
                      ),
                      borderSide: BorderSide(
                        color: FriskyColor().colorPrimary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(4.0),
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
            "Clear Bill",
            style: TextStyle(
                color: FriskyColor().colorTextDark,
                fontWeight: FontWeight.bold),
          ),
          content: Text(
            "You are about to request the bill and end your session. You won\'t be able to order anymore items after you confirm.",
            style: TextStyle(
                color: FriskyColor().colorTextLight,
                fontWeight: FontWeight.w400),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel",
                  style: TextStyle(
                      color: FriskyColor().colorPrimary,
                      fontWeight: FontWeight.bold)),
            ),
            FlatButton(
                color: FriskyColor().colorPrimary,
                onPressed: () {
                  requestBill();
                },
                child: Text(
                  "Clear",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
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
            style: TextStyle(
                color: FriskyColor().colorTextDark,
                fontWeight: FontWeight.bold),
          ),
          content: Container(
            height: SizeConfig.safeBlockVertical * 10,
            width: SizeConfig.safeBlockVertical * 10,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  FriskyColor().colorPrimary,
                ),
              ),
            ),
          ),
        );
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
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      // Navigator.popUntil(context,ModalRoute.withName('/homepage'));
      print("BILL CLEARD");
    }).catchError((error) {
      Navigator.pop(context);
      print(error.toString());
    });
  }
}
