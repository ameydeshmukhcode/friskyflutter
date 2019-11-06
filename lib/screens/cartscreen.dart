import 'dart:collection';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/structures/diet_type.dart';
import 'package:friskyflutter/structures/menu_item.dart';
import 'package:provider/provider.dart';
import 'package:friskyflutter/provider_models/cart.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../frisky_colors.dart';
import '../size_config.dart';
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
    if (Provider.of<Cart>(context, listen: true).cartList.isEmpty)
    {
      if(orderPlaced)
     {
       orderPlaced=false;

       Navigator.pushReplacement(
           context,
           MaterialPageRoute(
               builder: (context) => OrdersScreen(widget.tableName)));
     }
    else {
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
        iconTheme: IconThemeData(color: FriskyColor().colorTextDark),
        title: Text(
          "Your Cart",
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
        children: [
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
            padding: const EdgeInsets.all(16),
            child: Divider(
              thickness: 2,
            ),
          ),
          Flexible(
            child: ListView.builder(
                itemCount:
                    Provider.of<Cart>(context, listen: true).cartList.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: ListTile(
                      title: Text(
                        Provider.of<Cart>(context, listen: true)
                                .cartList[index]
                                .getName() +
                            "\n\u20B9 " +
                            Provider.of<Cart>(context, listen: true)
                                .cartList[index]
                                .getPrice()
                                .toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: FriskyColor().colorTextDark,
                        ),
                      ),
                      subtitle: RichText(
                          text: TextSpan(children: <TextSpan>[
                        TextSpan(
                          text: "item total  ",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: FriskyColor().colorTextLight,
                          ),
                        ),
                        TextSpan(
                          text: "\u20B9 " +
                              (Provider.of<Cart>(context, listen: true)
                                          .cartList[index]
                                          .getCount() *
                                      Provider.of<Cart>(context, listen: true)
                                          .cartList[index]
                                          .getPrice())
                                  .toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        )
                      ])),
                      trailing: cartButtons(
                          Provider.of<Cart>(context, listen: false)
                              .cartList[index]),
                      leading: Container(
                          margin: EdgeInsets.only(left: 24, bottom: 20),
                          width: SizeConfig.safeBlockHorizontal * 3,
                          child: typeIcon(
                              Provider.of<Cart>(context, listen: true)
                                  .cartList[index])),
                    ),
                  );
                }),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
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
                      fontSize: SizeConfig.safeBlockVertical * 3),
                ),
                Text(
                  "\u20B9" +
                      Provider.of<Cart>(context, listen: true).total.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: SizeConfig.safeBlockVertical * 3),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 16),
            child: Container(
              height: SizeConfig.safeBlockVertical * 6.5,
              width: SizeConfig.screenWidth,
              padding: EdgeInsets.all(0),
              child: FlatButton(
                padding: EdgeInsets.all(0),
                color: FriskyColor().colorBadge,
                onPressed: () {
                  showConfirmAlert();
                },
                child: Text(
                  "Place Order",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConfig.safeBlockVertical * 3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  typeIcon(MenuItem mi) {
    if (mi.dietType == DietType.NONE) {
      return Text("");
    }
    if (mi.dietType == DietType.VEG) {
      return SvgPicture.asset("img/veg.svg");
    }
    if (mi.dietType == DietType.NON_VEG) {
      return SvgPicture.asset("img/nonveg.svg");
    }
    if (mi.dietType == DietType.EGG) {
      return SvgPicture.asset("img/egg.svg");
    }
  }

  Widget cartButtons(MenuItem mi) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: SizeConfig.safeBlockHorizontal * 6,
              width: SizeConfig.safeBlockHorizontal * 6,
              child: FlatButton(
                padding: EdgeInsets.all(0),
                color: FriskyColor().colorBadge,
                onPressed: () {
                  Provider.of<Cart>(context, listen: true).removeFromCart(mi);
                },
                child: Icon(
                  Icons.remove,
                  size: 20,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0),
                ),
              ),
            ),
            Container(
              height: SizeConfig.safeBlockHorizontal * 6,
              width: SizeConfig.safeBlockHorizontal * 6,
              child: Center(
                  child: Text(
                Provider.of<Cart>(context, listen: true).getCount(mi),
                style: TextStyle(
                    fontSize: SizeConfig.safeBlockVertical * 2.5,
                    fontWeight: FontWeight.bold,
                    color: FriskyColor().colorTextLight),
              )),
            ),
            Container(
              height: SizeConfig.safeBlockHorizontal * 6,
              width: SizeConfig.safeBlockHorizontal * 6,
              child: FlatButton(
                padding: EdgeInsets.all(0),
                color: FriskyColor().colorBadge,
                onPressed: () {
                  Provider.of<Cart>(context, listen: true).addToCart(mi);
                },
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(8.0),
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
                  size: SizeConfig.safeBlockVertical * 2.5,
                  color: FriskyColor().colorTextLight),
              Text(
                " In cart",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: FriskyColor().colorTextLight,
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
            style: TextStyle(
                color: FriskyColor().colorTextDark,
                fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Send order to kitchen for prepration ?",
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
                  placeOrder();
                },
                child: Text(
                  "OK",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
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
            "Place Your Order",
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

  placeOrder() async {
    Navigator.pop(context);
    showOrderPlacing();
    HashMap<String, int> orderlist = new HashMap<String, int>();
    Map<String, Object> data = new HashMap<String, Object>();
    for (int i = 0;
        i < Provider.of<Cart>(context, listen: true).cartList.length;
        i++) {
      MenuItem item = Provider.of<Cart>(context, listen: true).cartList[i];
      orderlist[item.getId()] = item.getCount();
    }
     data["order"] = orderlist;
      await cloudFunctions.getHttpsCallable(functionName: "placeOrder").call(data)
          .then((result) async {
        SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setBool("order_active", true);
         Provider.of<Cart>(context, listen: false).clearCart();
         Provider.of<Orders>(context, listen: false).getOrderStatus();
         orderPlaced=true;
         Navigator.pop(context);

      }).catchError((error){
        Navigator.pop(context);
        print(error.toString());
      });

  }
}
