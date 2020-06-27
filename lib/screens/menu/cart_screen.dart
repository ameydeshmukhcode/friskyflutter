import 'dart:collection';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'orders_screen.dart';
import '../../frisky_colors.dart';
import '../../provider_models/cart.dart';
import '../../provider_models/orders.dart';
import '../../structures/diet_type.dart';
import '../../structures/menu_item.dart';
import '../../widgets/text_fa.dart';

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
//        Navigator.pushReplacement(
//            context,
//            MaterialPageRoute(
//                builder: (context) => OrdersScreen(widget.tableName)));
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    fontFamily: "Varela",
                    color: FriskyColor.colorPrimary,
                    fontSize: 24,
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
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: _cartList(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _sendToKitchenLayout(),
    );
  }

  _cartList() {
    var _cartProvider = Provider.of<Cart>(context, listen: true);
    return Column(
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
                                    child: FAText(
                                        _cartProvider.cartList[index].name,
                                        14,
                                        FriskyColor.colorTextDark),
                                  ),
                                )
                              ],
                            ),
                            FAText(
                                "\u20B9" +
                                    _cartProvider.cartList[index].price
                                        .toString(),
                                12,
                                FriskyColor.colorTextLight),
                            Padding(
                              padding:
                                  EdgeInsets.only(top: 2, right: 4, bottom: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  FAText("Item total: ", 12,
                                      FriskyColor.colorTextLight),
                                  FAText(
                                      "\u20B9" +
                                          (_cartProvider.cartList[index].price *
                                                  _cartProvider
                                                      .cartList[index].count)
                                              .toString(),
                                      14,
                                      Colors.red),
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
      ],
    );
  }

  _sendToKitchenLayout() {
    var _cartProvider = Provider.of<Cart>(context, listen: true);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: TextField(
            minLines: 1,
            maxLines: 5,
            style: TextStyle(fontFamily: "Varela", fontSize: 14),
            decoration: InputDecoration(
                labelText: 'Add cooking instructions here',
                border: OutlineInputBorder()),
            cursorColor: FriskyColor.colorPrimary,
          ),
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
                      title:
                          FAText("Place order", 20, FriskyColor.colorTextDark),
                      content: FAText("Send order to kitchen for preparation?",
                          14, FriskyColor.colorTextLight),
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
                            _placeOrder();
                          },
                          child: FAText("OK", 14, Colors.white),
                        )
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
                      "Cart total: \u20B9" + _cartProvider.total.toString(),
                      style: TextStyle(
                          fontFamily: "Varela",
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Send to kitchen",
                          style: TextStyle(
                            fontFamily: "Varela",
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
                  child: FAText(_cartProvider.getItemCount(menuItem).toString(),
                      14, FriskyColor.colorTextDark),
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
                  size: 12, color: FriskyColor.colorTextLight),
              Padding(
                padding: EdgeInsets.only(left: 2),
              ),
              FAText("In cart", 12, FriskyColor.colorTextLight),
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
            title: FAText("Placing your order", 20, FriskyColor.colorTextDark),
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

  _placeOrder() async {
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

    var _cartProvider = Provider.of<Cart>(context, listen: false);
    Map<String, Object> data = new HashMap<String, Object>();
    data["order"] = _cartProvider.orderList;
    await cloudFunctions
        .getHttpsCallable(functionName: "placeOrder")
        .call(data)
        .then((result) async {
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      await sharedPreferences.setBool("order_active", true);
      _cartProvider.clearCartAndOrders();
      Provider.of<Orders>(context, listen: false).isOrderActive = true;
      orderPlaced = true;
      Future.delayed(Duration.zero, () => Navigator.pop(context));
      Future.delayed(
          Duration.zero,
          () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => OrdersScreen(widget.tableName))));
    }).catchError((error) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Something went wrong.\nTry again.");
      print("Error _placeOrder " + error.toString());
    });
  }
}
