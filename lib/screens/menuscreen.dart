import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:friskyflutter/size_config.dart';
import 'dart:collection';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friskyflutter/structures/MenuCategory.dart';
import 'package:friskyflutter/structures/DietType.dart';
import 'package:friskyflutter/structures/MenuItem.dart';
import '../frisky_colors.dart';

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
  ScrollController _scrollController;

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
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: FriskyColor().colorTextDark),
        title: Text(
          "You're at",
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
                        'Table ' + widget.tableName,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget menuList() {
    return FutureBuilder(
        future: _finalmenulist,
        builder: (context, snapshot) {
          if (isLoading == true) {
            return Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Shimmer.fromColors(
                      child: Text("hellow"),
                      baseColor: Colors.pink,
                      highlightColor: Colors.green),
                  Shimmer.fromColors(
                      child: Container(
                        height: 20,
                        width: 200,
                        color: Colors.blue,
                      ),
                      baseColor: Colors.teal,
                      highlightColor: Colors.pink),
                  Shimmer.fromColors(
                      child: SizedBox(
                        height: 20,
                        width: 200,
                      ),
                      baseColor: FriskyColor().colorPrimary,
                      highlightColor: Colors.blue),
                  Shimmer.fromColors(
                      child: SizedBox(
                        height: 20,
                        width: 200,
                      ),
                      baseColor: FriskyColor().colorPrimary,
                      highlightColor: Colors.teal),
                  Shimmer.fromColors(
                      child: SizedBox(
                        height: 20,
                        width: 200,
                      ),
                      baseColor: FriskyColor().colorPrimary,
                      highlightColor: Colors.grey),
                ],
              ),
            );
          } else {
            return Flexible(
              child: ListView.builder(
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
                        trailing: FlatButton(
                            color: FriskyColor().colorBadge,
                            onPressed: () {
                              print(mi.name);
                            },
                            child: Text(
                              "ADD +",
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                    );
                  }
                  ),
            );

          }
        });
  }

  Widget _simplePopup() {
    return PopupMenuButton<MenuCategory>(
      child: Container(
        child: Padding(
          padding:
              const EdgeInsets.only(top: 16, bottom: 16, right: 16, left: 16),
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
      onSelected: (s){
        print(s);
           MenuCategory menuCategory = s;
        int a =mMenu.indexOf(menuCategory) ;
        print(a) ;
        _scrollController.animateTo(a.toDouble()*70, duration: Duration(seconds: 1), curve: Curves.easeInToLinear);
        },
      offset: Offset(1,-460),
    );
  }
}

