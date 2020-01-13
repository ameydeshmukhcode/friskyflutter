import 'dart:collection';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/provider_models/cart.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/structures/diet_type.dart';
import 'package:friskyflutter/structures/menu_item.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../frisky_colors.dart';
import 'orders_screen.dart';

class CartScreen extends StatefulWidget {
  final String tableName;
  CartScreen(this.tableName) : super();
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool orderPlaced = false;
  CloudFunctions cloudFunctions = CloudFunctions.instance;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this.cartExit();
  }

  cartExit() {
    if (Provider.of<Cart>(context, listen: true).cartList.isEmpty) {
      if (orderPlaced) {
        orderPlaced = false;

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => OrdersScreen(widget.tableName)));
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: FriskyColor.colorTextDark),
        title: Text(
          "Your Cart",
          style: TextStyle(
            color: FriskyColor.colorTextDark,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
              child: Container(
            padding: EdgeInsets.all(8),
            child: Text(
              'Table ' + widget.tableName,
              style: TextStyle(
                fontSize: 20,
                color: FriskyColor.colorTextDark,
              ),
            ),
            decoration: BoxDecoration(
              color: FriskyColor.colorTableName,
              borderRadius: BorderRadius.circular(8),
            ),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Divider(
              thickness: 1,
            ),
          ),
          Flexible(
            child: ListView.builder(
                itemCount:
                    Provider.of<Cart>(context, listen: true).cartList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(24, 4, 24, 4),
                    child: Row(
                      children: <Widget>[
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 10,
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                                      child: Text(Provider.of<Cart>(context,
                                              listen: true)
                                          .cartList[index]
                                          .name),
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "\u20B9 " +
                                    Provider.of<Cart>(context, listen: true)
                                        .cartList[index]
                                        .price
                                        .toString(),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 2, right: 4, bottom: 2),
                                  child: Text(
                                      "Item Total: \u20B9 " +
                                          (Provider.of<Cart>(context,
                                                          listen: true)
                                                      .cartList[index]
                                                      .price *
                                                  Provider.of<Cart>(context,
                                                          listen: true)
                                                      .cartList[index]
                                                      .count)
                                              .toString(),
                                      style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                        Center(
                          child: cartButtons(
                              Provider.of<Cart>(context, listen: false)
                                  .cartList[index]),
                        )
                      ],
                    ),
                  );
                }),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Divider(
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Cart Total",
                  style:
                      TextStyle(color: FriskyColor.colorTextDark, fontSize: 16),
                ),
                Text(
                  "\u20B9" +
                      Provider.of<Cart>(context, listen: true).total.toString(),
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.only(left: 24, right: 24, bottom: 8),
              child: FlatButton(
                padding: EdgeInsets.all(8),
                onPressed: showConfirmAlert,
                color: FriskyColor.colorBadge,
                child: Text(
                  "Place Order",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8),
                ),
              ))
        ],
      ),
    );
  }

  typeIcon(MenuItem menuItem) {
    if (menuItem.dietType == DietType.NONE) {
      return SizedBox();
    }
    if (menuItem.dietType == DietType.VEG) {
      return SvgPicture.asset("images/icons/veg.svg");
    }
    if (menuItem.dietType == DietType.NON_VEG) {
      return SvgPicture.asset("images/icons/non_veg.svg");
    }
    if (menuItem.dietType == DietType.EGG) {
      return SvgPicture.asset("images/icons/egg.svg");
    }
  }

  Widget cartButtons(MenuItem menuItem) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 30,
              width: 30,
              child: FlatButton(
                padding: EdgeInsets.all(0),
                color: FriskyColor.colorBadge,
                onPressed: () {
                  Provider.of<Cart>(context, listen: true)
                      .removeFromCart(menuItem);
                },
                child: Icon(
                  Icons.remove,
                  size: 20,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(50),
                ),
              ),
            ),
            Container(
              height: 30,
              width: 30,
              child: Center(
                  child: Text(
                Provider.of<Cart>(context, listen: true).getCount(menuItem),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: FriskyColor.colorTextLight),
              )),
            ),
            Container(
              height: 30,
              width: 30,
              child: FlatButton(
                padding: EdgeInsets.all(0),
                color: FriskyColor.colorBadge,
                onPressed: () {
                  Provider.of<Cart>(context, listen: true).addToCart(menuItem);
                },
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(50),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.shopping_cart,
                  size: 14, color: FriskyColor.colorTextLight),
              Padding(
                padding: EdgeInsets.only(left: 2),
              ),
              Text(
                "In cart",
                style: TextStyle(
                  color: FriskyColor.colorTextLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  showConfirmAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Place Order",
            style: TextStyle(color: FriskyColor.colorTextDark),
          ),
          content: Text(
            "Send order to kitchen for prepration?",
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
                  placeOrder();
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        );
      },
      barrierDismissible: false,
    );
  }

  showOrderPlacing() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              "Placing Your Order",
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

  placeOrder() async {
    Navigator.pop(context);
    showOrderPlacing();
    HashMap<String, int> orderlist = new HashMap<String, int>();
    Map<String, Object> data = new HashMap<String, Object>();
    for (int i = 0;
        i < Provider.of<Cart>(context, listen: true).cartList.length;
        i++) {
      MenuItem item = Provider.of<Cart>(context, listen: true).cartList[i];
      orderlist[item.id] = item.count;
    }
    data["order"] = orderlist;
    await cloudFunctions
        .getHttpsCallable(functionName: "placeOrder")
        .call(data)
        .then((result) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setBool("order_active", true);
      Provider.of<Cart>(context, listen: false).clearList();
      Provider.of<Orders>(context, listen: false).getOrderStatus();
      orderPlaced = true;
      Navigator.pop(context);
    }).catchError((error) {
      Navigator.pop(context);
      print(error.toString());
    });
  }
}
