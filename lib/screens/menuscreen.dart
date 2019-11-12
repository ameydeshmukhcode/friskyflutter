import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friskyflutter/provider_models/cart.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/screens/cartscreen.dart';
import 'package:friskyflutter/size_config.dart';
import 'package:friskyflutter/structures/diet_type.dart';
import 'package:friskyflutter/structures/menu_category.dart';
import 'package:friskyflutter/structures/menu_item.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../frisky_colors.dart';
import 'orders_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();

  MenuScreen(
      this.restaurantName, this.tableName, this.sessionID, this.restaurantID)
      : super();
  final String restaurantName, tableName, sessionID, restaurantID;
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuCategory> mCategories = List<MenuCategory>();
  HashMap<String, List<MenuItem>> mItems =
      new HashMap<String, List<MenuItem>>();
  List<dynamic> mMenu = List<dynamic>();
  Firestore firestore = Firestore.instance;
  HashMap<String, int> mCategoryOrderMap = HashMap<String, int>();
  bool isLoading = true;
  ScrollController _scrollController;

  Future getMenuData() async {
    print("INSIDE GET MENU DATA");
    await firestore
        .collection("restaurants")
        .document(widget.restaurantID)
        .collection("categories")
        .orderBy("order")
        .getDocuments()
        .then((categoryDoc) async {
      print("INSIDE GET MENU DATA after getting Catagory doc");
      mCategories.clear();
      for (int i = 0; i <= categoryDoc.documents.length - 1; i++) {
        print("INSIDE Catagory doc FOR LOOP time " + i.toString());
        MenuCategory menuCategory = new MenuCategory(
            categoryDoc.documents[i].documentID,
            await categoryDoc.documents[i].data["name"]);
        mCategories.add(menuCategory);
        print(
            "INSIDE Catagory doc loop after adding data time " + i.toString());
      }
      for (int i = 0; i < mCategories.length; i++)
        print("Printing Catagory list\t" + mCategories[i].getName());
      await getItems();
    });
  }

  Future getItems() async {
    print("INSIDE GET ITEMS ");
    await firestore
        .collection("restaurants")
        .document(widget.restaurantID)
        .collection("items")
        .orderBy("category_id")
        .getDocuments()
        .then((itemDoc) async {
      print("INSIDE ITEM DOCS ");
      String categoryId = "";
      mItems.clear();
      for (int i = 0; i <= itemDoc.documents.length - 1; i++) {
        print("INSIDE GET ITEMS FOR times " + i.toString());
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
        if (!mItems.containsKey(currentCategory)) {
          List<MenuItem> categoryList = new List<MenuItem>();
          categoryList.add(item);
          mItems[currentCategory] = categoryList;
        } else {
          mItems[currentCategory].add(item);
        }
      }

      mItems.forEach((key, value) {
        print("Catagory = " + key);
        for (int i = 0; i < value.length; i++) print(value[i].getName());
      });
      await setupMenu();
    });
  }

  Future setupMenu() async {
    Provider.of<Orders>(context, listen: false).getOrderStatus();
    print("INSIDE SETUP MENU");
    mMenu.clear();
    for (int i = 0; i < mCategories.length; i++) {
      print("INSIDE SETUP MENU FOR times " + i.toString());
      final MenuCategory category = mCategories[i];
      String categoryID = category.getId();
      mMenu.add(category);
      mCategoryOrderMap[category.getName()] = (mMenu.length - 1);
      // categoryMenu.getMenu().add(category.getName());
      mMenu.addAll(mItems[categoryID]);
    }
    for (int i = 0; i < mMenu.length; i++) {
      if (mMenu[i].toString() == "Instance of 'MenuCategory'") {
        MenuCategory m = mMenu[i];
        print(" CATAGORY " + m.name);
        print("   /n");
      } else {
        MenuItem m = mMenu[i];
        print("" + m.name);
      }
    }

    return mMenu;
  }

  Future _finalmenulist;
  @override
  void initState() {
    _finalmenulist = getMenuData().whenComplete(() {
      setState(() {
        isLoading = false;
      });
    });
    _scrollController = new ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //cartProvider = Provider.of<Cart>(context,listen: true);
    print("UI REBUILDED");
    SizeConfig().init(context);
    return WillPopScope(
      onWillPop: () {
        Navigator.pop(context);
        return Provider.of<Cart>(context, listen: true).clearList();
      },
      child: !isLoading
          ? Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          iconTheme: IconThemeData(color: FriskyColor().colorTextDark),
          title: Text(
            "you're at",
            style: TextStyle(
              fontWeight: FontWeight.w300,
              color: FriskyColor().colorTextDark,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.clear_all),
                onPressed: () {
                  Provider.of<Cart>(context, listen: true).clearList();
                })
          ],
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              color: Colors.white,
              height: SizeConfig.safeBlockVertical * 10,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text(
                        widget.restaurantName,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: FriskyColor().colorTextLight,
                          fontSize: SizeConfig.safeBlockVertical * 3,
                        ),
                      ),
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
                      )
                    ],
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Text(
                    "Menu",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: FriskyColor().colorTextLight,
                      fontSize: SizeConfig.safeBlockVertical * 2.5,
                    ),
                  ),
                ],
              ),
            ),
            menuList(),
          ],
        ),
        floatingActionButton: _simplePopup(),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerFloat,
      )
          : SafeArea(
        child: Scaffold(
          body: Container(
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 60, right: 20),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: SizeConfig.safeBlockVertical * 2,
                        width: SizeConfig.safeBlockHorizontal * 30,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300],
                          highlightColor: Colors.white24,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(20))),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: SizeConfig.safeBlockHorizontal * 16),
                      Container(
                        height: SizeConfig.safeBlockVertical * 6,
                        width: SizeConfig.safeBlockHorizontal * 24,
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[200],
                          highlightColor: Colors.white24,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(12))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 6),
                Container(
                  height: SizeConfig.safeBlockVertical * 1.3,
                  width: SizeConfig.safeBlockHorizontal * 24,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.white24,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius:
                          BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 6),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: SizeConfig.safeBlockVertical * 6,
                        width: SizeConfig.safeBlockHorizontal * 40,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey[400],
                            highlightColor: Colors.white24,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 40,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 15,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(width: SizeConfig.safeBlockHorizontal * 20),
                      Container(
                        height: SizeConfig.safeBlockVertical * 4,
                        width: SizeConfig.safeBlockHorizontal * 24,
                        child: Shimmer.fromColors(
                          baseColor: Colors.green[200],
                          highlightColor: Colors.white24,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(24))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: SizeConfig.safeBlockVertical * 6,
                        width: SizeConfig.safeBlockHorizontal * 40,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey[400],
                            highlightColor: Colors.white24,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 40,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 15,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(width: SizeConfig.safeBlockHorizontal * 20),
                      Container(
                        height: SizeConfig.safeBlockVertical * 4,
                        width: SizeConfig.safeBlockHorizontal * 24,
                        child: Shimmer.fromColors(
                          baseColor: Colors.green[200],
                          highlightColor: Colors.white24,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(24))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 6),
                Container(
                  height: SizeConfig.safeBlockVertical * 1.3,
                  width: SizeConfig.safeBlockHorizontal * 24,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.white24,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius:
                          BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 6),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: SizeConfig.safeBlockVertical * 6,
                        width: SizeConfig.safeBlockHorizontal * 40,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey[400],
                            highlightColor: Colors.white24,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 40,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 15,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(width: SizeConfig.safeBlockHorizontal * 20),
                      Container(
                        height: SizeConfig.safeBlockVertical * 4,
                        width: SizeConfig.safeBlockHorizontal * 24,
                        child: Shimmer.fromColors(
                          baseColor: Colors.green[200],
                          highlightColor: Colors.white24,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(24))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: SizeConfig.safeBlockVertical * 6,
                        width: SizeConfig.safeBlockHorizontal * 40,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey[400],
                            highlightColor: Colors.white24,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 40,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 15,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(width: SizeConfig.safeBlockHorizontal * 20),
                      Container(
                        height: SizeConfig.safeBlockVertical * 4,
                        width: SizeConfig.safeBlockHorizontal * 24,
                        child: Shimmer.fromColors(
                          baseColor: Colors.green[200],
                          highlightColor: Colors.white24,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(24))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: SizeConfig.safeBlockVertical * 6,
                        width: SizeConfig.safeBlockHorizontal * 40,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey[400],
                            highlightColor: Colors.white24,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 40,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 15,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(width: SizeConfig.safeBlockHorizontal * 20),
                      Container(
                        height: SizeConfig.safeBlockVertical * 4,
                        width: SizeConfig.safeBlockHorizontal * 24,
                        child: Shimmer.fromColors(
                          baseColor: Colors.green[200],
                          highlightColor: Colors.white24,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(24))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 6),
                Container(
                  height: SizeConfig.safeBlockVertical * 1.3,
                  width: SizeConfig.safeBlockHorizontal * 24,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300],
                    highlightColor: Colors.white24,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.yellow,
                          borderRadius:
                          BorderRadius.all(Radius.circular(20))),
                    ),
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 4),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: SizeConfig.safeBlockVertical * 6,
                        width: SizeConfig.safeBlockHorizontal * 40,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey[400],
                            highlightColor: Colors.white24,
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 40,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Container(
                                  width:
                                  SizeConfig.safeBlockHorizontal * 15,
                                  color: Colors.white12,
                                  height: 10,
                                ),
                              ],
                            )),
                      ),
                      SizedBox(width: SizeConfig.safeBlockHorizontal * 20),
                      Container(
                        height: SizeConfig.safeBlockVertical * 4,
                        width: SizeConfig.safeBlockHorizontal * 24,
                        child: Shimmer.fromColors(
                          baseColor: Colors.green[200],
                          highlightColor: Colors.white24,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(24))),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.safeBlockVertical * 0.5,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 34),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: SizeConfig.safeBlockVertical * 4,
                        width: SizeConfig.safeBlockHorizontal * 24,
                        child: Shimmer.fromColors(
                          baseColor: FriskyColor().colorPrimary.withOpacity(
                              0.5),
                          highlightColor: Colors.white24,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: FriskyColor().colorPrimary,
                                    width: 4),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(24))),

                          ),
                        ),
                      ),
                    ],
                  ),
                ),


              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget menuList() {
    return FutureBuilder(
        future: _finalmenulist,
        builder: (context, snapshot) {
          if (isLoading == true) {
            return Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  FriskyColor().colorPrimary,
                ),
              ),
            );
          } else {
            return Flexible(
              child: ListView.builder(
                  padding: (Provider.of<Cart>(context, listen: true)
                              .cartList
                              .isNotEmpty ||
                          Provider.of<Orders>(context, listen: true)
                              .isOrderActive)
                      ? EdgeInsets.only(
                          bottom: SizeConfig.safeBlockVertical * 18,
                        )
                      : EdgeInsets.only(
                          bottom: SizeConfig.safeBlockVertical * 10,
                        ),
                  controller: _scrollController,
                  itemCount: mMenu.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (mMenu[index].toString() ==
                        "Instance of 'MenuCategory'") {
                      MenuCategory mc = mMenu[index];
                      return Container(
                        height: 70,
                        child: Center(
                          child: Text(
                            mc.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: FriskyColor().colorTextLight,
                              fontSize: SizeConfig.safeBlockVertical * 2.7,
                            ),
                          ),
                        ),
                      );
                    }
                    MenuItem mi = mMenu[index];
                    return Container(
                      height: 70,
                      child: ListTile(
                        title: Text(
                          mi.name + "\n\u20B9 " + mi.price.toString(),
                          style: TextStyle(
                              color: FriskyColor().colorTextDark,
                              fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(mi.description),
                        trailing: (Provider.of<Cart>(context, listen: true)
                                .cartList
                                .contains(mi))
                            ? cartButtons(mi)
                            : addButton(mi),
                        leading: Container(
                            margin: EdgeInsets.only(left: 24, bottom: 20),
                            width: SizeConfig.safeBlockHorizontal * 3,
                            child: typeIcon(mi)),
                      ),
                    );
                  }),
            );
          }
        });
  }

  Widget _simplePopup() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        PopupMenuButton<MenuCategory>(
          child: Container(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 16, bottom: 16, right: 16, left: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: SizeConfig.safeBlockVertical * 2.5,
                  ),
                  Text(
                    " Category",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: SizeConfig.safeBlockVertical * 2.5),
                  )
                ],
              ),
            ),
            decoration: BoxDecoration(
              color: FriskyColor().colorPrimary,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          itemBuilder: (BuildContext context) {
            return mCategories.map((MenuCategory m) {
              return PopupMenuItem<MenuCategory>(
                value: m,
                child: Text(m.name),
              );
            }).toList();
          },
          onSelected: (s) {
            print(s);
            MenuCategory menuCategory = s;
            int a = mMenu.indexOf(menuCategory);
            print(a);
            _scrollController.animateTo(a.toDouble() * 70,
                duration: Duration(seconds: 1), curve: Curves.linear);
          },
          offset: Offset(1, -460),
        ),
        Visibility(
          visible:
              (Provider.of<Cart>(context, listen: true).cartList.isNotEmpty),
          child: Container(
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  "You Have items in the Cart  ",
                  style: TextStyle(
                      color: FriskyColor().colorSnackBarText,
                      fontSize: SizeConfig.safeBlockVertical * 2),
                ),
                Container(
                  width: SizeConfig.safeBlockHorizontal * 16,
                  child: FlatButton(
                      color: FriskyColor().colorSnackBarButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(4.0),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    CartScreen(widget.tableName)));
                      },
                      child: Text(
                        "View",
                        style: TextStyle(
                            color: FriskyColor().colorSnackBarText,
                            fontSize: SizeConfig.safeBlockVertical * 2),
                      )),
                ),
              ],
            ),
            decoration: BoxDecoration(
                color: FriskyColor().colorSnackBar,
                borderRadius: BorderRadius.circular(6)),
          ),
        ),
        Visibility(
          visible: (Provider.of<Cart>(context, listen: true).cartList.isEmpty &&
              Provider.of<Orders>(context, listen: true).isOrderActive),
          child: Container(
            padding: EdgeInsets.all(4),
            margin: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  "You Have Orders  ",
                  style: TextStyle(
                      color: FriskyColor().colorSnackBarText,
                      fontSize: SizeConfig.safeBlockVertical * 2),
                ),
                Container(
                  width: SizeConfig.safeBlockHorizontal * 18,
                  child: FlatButton(
                      color: FriskyColor().colorSnackBarButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(4.0),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    OrdersScreen(widget.tableName)));
                      },
                      child: Text(
                        "Show",
                        style: TextStyle(
                            color: FriskyColor().colorSnackBarText,
                            fontSize: SizeConfig.safeBlockVertical * 2),
                      )),
                ),
              ],
            ),
            decoration: BoxDecoration(
                color: FriskyColor().colorSnackBar,
                borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }

  Widget cartButtons(MenuItem mi) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: SizeConfig.safeBlockHorizontal * 9,
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
          width: SizeConfig.safeBlockHorizontal * 9,
          child: Center(
              child: Text(
            Provider.of<Cart>(context, listen: true).getCount(mi),
            style: TextStyle(
                fontSize: SizeConfig.safeBlockVertical * 2.5,
                fontWeight: FontWeight.bold,
                color: FriskyColor().colorTextDark),
          )),
        ),
        Container(
          width: SizeConfig.safeBlockHorizontal * 9,
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
    );
  }

  Widget addButton(MenuItem mi) {
    return Container(
        width: SizeConfig.safeBlockHorizontal * 27,
        padding: EdgeInsets.all(0),
        child: FlatButton(
          padding: EdgeInsets.all(0),
          color: FriskyColor().colorBadge,
          onPressed: () {
            Provider.of<Cart>(context, listen: true).addToCart(mi);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Add  ",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConfig.safeBlockVertical * 2),
              ),
              Icon(
                Icons.add,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ));
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
}
