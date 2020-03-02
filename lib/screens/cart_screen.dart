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
    var _cartProvider = Provider.of<Cart>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Your Cart",
                style: TextStyle(
                    color: FriskyColor.colorPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Table ' + widget.tableName,
                style: TextStyle(
                  color: FriskyColor.colorPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: ListView.builder(
                padding: EdgeInsets.only(top: 16),
                itemCount: _cartProvider.cartList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
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
                                      child: Text(
                                          _cartProvider.cartList[index].name,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "\u20B9" +
                                    _cartProvider.cartList[index].price
                                        .toString(),
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 2, right: 4, bottom: 2),
                                child: Row(
                                  children: <Widget>[
                                    Text("Item Total: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400)),
                                    Text(
                                        "\u20B9" +
                                            (_cartProvider
                                                        .cartList[index].price *
                                                    _cartProvider
                                                        .cartList[index].count)
                                                .toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.red))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: cartButtons(_cartProvider.cartList[index]),
                        )
                      ],
                    ),
                  );
                }),
          ),
          Container(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Material(
              borderRadius: BorderRadius.circular(8),
              color: FriskyColor.colorPrimary,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
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
                                style:
                                    TextStyle(color: FriskyColor.colorPrimary)),
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
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                      child: Text(
                        "Cart Total: \u20B9" + _cartProvider.total.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
                      child: Row(
                        children: <Widget>[
                          Text(
                            "Send to kitchen",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
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
    var _cartProvider = Provider.of<Cart>(context, listen: true);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 26,
              width: 26,
              child: MaterialButton(
                elevation: 1,
                padding: EdgeInsets.all(0),
                color: FriskyColor.colorBadge,
                onPressed: () {
                  _cartProvider.removeFromCart(menuItem);
                },
                child: Icon(
                  Icons.remove,
                  size: 20,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8)),
                ),
              ),
            ),
            Container(
              height: 26,
              width: 26,
              child: Material(
                color: Colors.white,
                elevation: 1,
                child: Center(
                  child: Text(
                    _cartProvider.getItemCount(menuItem).toString(),
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: FriskyColor.colorTextDark),
                  ),
                ),
              ),
            ),
            Container(
              height: 26,
              width: 26,
              child: MaterialButton(
                elevation: 1,
                padding: EdgeInsets.all(0),
                color: FriskyColor.colorBadge,
                onPressed: () {
                  _cartProvider.addToCart(menuItem);
                },
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
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

    // TODO: find why this doesn't work (causes error code 429 in placeOrder)
    //  HashMap<String, int> orderList = new HashMap<String, int>();
    //  Map<String, Object> data = new HashMap<String, Object>();
    //  for (int i = 0;
    //      i < Provider.of<Cart>(context, listen: true).cartList.length;
    //      i++) {
    //    MenuItem item = Provider.of<Cart>(context, listen: true).cartList[i];
    //    orderList[item.id] = item.count;
    //  }

    var cartProvider = Provider.of<Cart>(context, listen: true);

    Map<String, Object> data = new HashMap<String, Object>();
    data["order"] = cartProvider.orderList;

    await cloudFunctions
        .getHttpsCallable(functionName: "placeOrder")
        .call(data)
        .then((result) async {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      await sharedPreferences.setBool("order_active", true);
      Provider.of<Cart>(context, listen: false).clearCartAndOrders();
      Provider.of<Orders>(context, listen: false).getOrderStatus();
      orderPlaced = true;
      Navigator.pop(context);
    }).catchError((error) {
      Navigator.pop(context);
      print(error.toString());
    });
  }
}
