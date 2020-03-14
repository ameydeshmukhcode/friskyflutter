import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friskyflutter/provider_models/cart.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/screens/cart_screen.dart';
import 'package:friskyflutter/structures/diet_type.dart';
import 'package:friskyflutter/structures/menu_category.dart';
import 'package:friskyflutter/structures/menu_item.dart';
import 'package:friskyflutter/widgets/text_fa.dart';
import 'package:provider/provider.dart';

import '../frisky_colors.dart';
import 'orders_screen.dart';

class MenuScreen extends StatefulWidget {
  final String restaurantName, tableName, sessionID, restaurantID;

  MenuScreen(
      this.restaurantName, this.tableName, this.sessionID, this.restaurantID);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final Firestore firestore = Firestore.instance;

  List<MenuCategory> _categoryList = List<MenuCategory>();
  HashMap<String, List<MenuItem>> _categoryItemListMap =
      new HashMap<String, List<MenuItem>>();
  List<dynamic> _menuList = List<dynamic>();
  HashMap<String, int> _categoryOrderMap = HashMap<String, int>();
  bool _isLoading = true;
  ScrollController _scrollController;
  Future _finalMenuList;

  Future getMenuData() async {
    await firestore
        .collection("restaurants")
        .document(widget.restaurantID)
        .collection("categories")
        .orderBy("order")
        .getDocuments()
        .then((categoryDoc) async {
      _categoryList.clear();
      for (int i = 0; i <= categoryDoc.documents.length - 1; i++) {
        MenuCategory menuCategory = new MenuCategory(
            categoryDoc.documents[i].documentID,
            await categoryDoc.documents[i].data["name"]);
        _categoryList.add(menuCategory);
      }
      await getItems();
    });
  }

  Future getItems() async {
    await firestore
        .collection("restaurants")
        .document(widget.restaurantID)
        .collection("items")
        .orderBy("category_id")
        .getDocuments()
        .then((itemDoc) async {
      String categoryId = "";
      _categoryItemListMap.clear();
      for (int i = 0; i <= itemDoc.documents.length - 1; i++) {
        bool available = true;
        String currentCategory = await itemDoc.documents[i].data["category_id"];
        if (!(categoryId == currentCategory))
          categoryId = await itemDoc.documents[i].data["category_id"];
        String name = await itemDoc.documents[i].data["name"];
        if (itemDoc.documents[i].data.containsKey("is_available")) {
          if (!itemDoc.documents[i].data["is_available"]) {
            available = false;
          }
        }
        String description = "";
        if (itemDoc.documents[i].data.containsKey("description")) {
          description = await itemDoc.documents[i].data["description"];
        }
        DietType type = DietType.NONE;
        if (itemDoc.documents[i].data.containsKey("type")) {
          type = getDietTypeFromString(await itemDoc.documents[i].data["type"]);
        }
        int cost = int.parse(await itemDoc.documents[i].data["cost"]);
        MenuItem item = new MenuItem(itemDoc.documents[i].documentID, name,
            description, currentCategory, cost, available, type);
        if (!_categoryItemListMap.containsKey(currentCategory)) {
          List<MenuItem> categoryList = new List<MenuItem>();
          categoryList.add(item);
          _categoryItemListMap[currentCategory] = categoryList;
        } else {
          _categoryItemListMap[currentCategory].add(item);
        }
      }

      await setupMenu();
    });
  }

  Future setupMenu() async {
    Provider.of<Orders>(context, listen: false).getOrderStatus();
    _menuList.clear();
    for (int i = 0; i < _categoryList.length; i++) {
      final MenuCategory category = _categoryList[i];
      String categoryID = category.categoryId;
      _menuList.add(category);
      _categoryOrderMap[category.name] = (_menuList.length - 1);
      _menuList.addAll(_categoryItemListMap[categoryID]);
    }

    return _menuList;
  }

  @override
  void initState() {
    _finalMenuList = getMenuData().whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
    _scrollController = new ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Provider.of<Cart>(context, listen: true).clearCartAndOrders();
      },
      child: !_isLoading
          ? Scaffold(
              appBar: AppBar(
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black),
                title: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.restaurantName,
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
                backgroundColor: Colors.white,
                actions: <Widget>[
                  IconButton(
                      tooltip: "Search Menu",
                      icon: Icon(Icons.search),
                      color: FriskyColor.colorTextDark,
                      onPressed: () {})
                ],
              ),
              backgroundColor: Colors.white,
              body: Flex(
                direction: Axis.vertical,
                children: <Widget>[
                  Center(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      margin: EdgeInsets.only(bottom: 8),
                      child: FAText("Menu", 14, FriskyColor.colorTextDark),
                    ),
                  ),
                  _menuItemsList()
                ],
              ),
              floatingActionButton: _simplePopup(),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            )
          : Scaffold(
              body: SafeArea(
                child: SvgPicture.asset(
                  'images/state_graphics/state_dummy_menu.svg',
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
    );
  }

  Widget _menuItemsList() {
    var _cartProvider = Provider.of<Cart>(context, listen: true);
    var _ordersProvider = Provider.of<Orders>(context, listen: true);

    return FutureBuilder(
        future: _finalMenuList,
        builder: (context, snapshot) {
          if (_isLoading == true) {
            return Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  FriskyColor.colorPrimary,
                ),
              ),
            );
          } else {
            return Flexible(
              child: ListView.builder(
                  padding: (_cartProvider.cartList.isNotEmpty ||
                          _ordersProvider.isOrderActive)
                      ? EdgeInsets.only(bottom: 50, top: 8)
                      : EdgeInsets.only(bottom: 20, top: 8),
                  controller: _scrollController,
                  itemCount: _menuList.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (_menuList[index] is MenuCategory) {
                      MenuCategory menuCategory = _menuList[index];
                      return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(24, 4, 8, 4),
                            child: Text(
                              menuCategory.name,
                              style: TextStyle(
                                  fontFamily: "Varela",
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ));
                    }
                    MenuItem menuItem = _menuList[index];
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
                                      child: _typeIcon(menuItem),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(4, 2, 4, 2),
                                        child: FAText(menuItem.name, 14,
                                            FriskyColor.colorTextDark),
                                      ),
                                    )
                                  ],
                                ),
                                FAText("\u20B9 " + menuItem.price.toString(),
                                    14, FriskyColor.colorTextDark),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 2, right: 4, bottom: 2),
                                  child: FAText(menuItem.description, 12,
                                      FriskyColor.colorTextLight),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: _cartProvider.cartList.contains(menuItem)
                                ? _cartButtons(menuItem)
                                : _addButton(menuItem),
                          )
                        ],
                      ),
                    );
                  }),
            );
          }
        });
  }

  Widget _simplePopup() {
    var _cartProvider = Provider.of<Cart>(context, listen: true);
    var _ordersProvider = Provider.of<Orders>(context, listen: true);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
//        PopupMenuButton<MenuCategory>(
//          child: FloatingActionButton.extended(
//            icon: Icon(
//              Icons.restaurant,
//              color: Colors.white,
//              size: 20,
//            ),
//            label: Text(
//              "Category",
//              style: TextStyle(color: Colors.white),
//            ),
//            onPressed: null,
//          ),
//          itemBuilder: (BuildContext context) {
//            return _categoryList.map((MenuCategory menuCategory) {
//              return PopupMenuItem<MenuCategory>(
//                value: menuCategory,
//                child: Text(
//                  menuCategory.name,
//                ),
//              );
//            }).toList();
//          },
//          onSelected: (category) {
//            MenuCategory menuCategory = category;
//            int a = _menuList.indexOf(menuCategory);
//            _scrollController.animateTo(a.toDouble() * 65,
//                duration: Duration(milliseconds: 300), curve: Curves.easeIn);
//          },
//        ),
        Visibility(
          visible: _cartProvider.cartList.isNotEmpty,
          child: Container(
              margin: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
              child: Material(
                borderRadius: BorderRadius.circular(8),
                color: FriskyColor.colorPrimary,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CartScreen(widget.tableName)));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text(
                          _cartProvider.itemCount.toString() +
                              " Items | \u20B9" +
                              _cartProvider.total.toString(),
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
                              "View cart",
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
              )),
        ),
        Visibility(
          visible:
              _cartProvider.cartList.isEmpty && _ordersProvider.isOrderActive,
          child: Container(
              margin: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
              child: Material(
                borderRadius: BorderRadius.circular(8),
                color: FriskyColor.colorPrimary,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                OrdersScreen(widget.tableName)));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                        child: Text(
                          "You have orders",
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
                              "Show",
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
              )),
        ),
      ],
    );
  }

  Widget _cartButtons(MenuItem menuItem) {
    var _cartProvider = Provider.of<Cart>(context, listen: true);

    return Center(
      child: Row(
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
    );
  }

  Widget _addButton(MenuItem menuItem) {
    return Center(
      child: Container(
        height: 26,
        width: 78,
        child: MaterialButton(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: FriskyColor.colorBadge,
          onPressed: () {
            Provider.of<Cart>(context, listen: true).addToCart(menuItem);
          },
          child: Center(
            child: FAText("Add", 14, Colors.white),
          ),
        ),
      ),
    );
  }

  _typeIcon(MenuItem menuItem) {
    if (menuItem.dietType == DietType.NONE) {
      return SvgPicture.asset("images/icons/veg.svg");
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
}
