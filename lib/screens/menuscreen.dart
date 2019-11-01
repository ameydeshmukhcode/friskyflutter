import 'dart:collection';

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
  HashMap<String, List<MenuItem>> mItems = new HashMap<String , List<MenuItem>>();
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
      for (int i = 0; i <= categoryDoc.documents.length-1; i++) {
        print("INSIDE Catagory doc FOR LOOP time "+ i.toString());
        MenuCategory menuCategory = new MenuCategory(
           categoryDoc.documents[i].documentID,
           await categoryDoc.documents[i].data["name"]);
        mCategories.add(menuCategory);
        print("INSIDE Catagory doc loop after adding data time "+ i.toString());
      }
      for(int i = 0 ; i< mCategories.length;i++)
        print("Printing Catagory list\t"+mCategories[i].getName());
      await getItems();
    });
  }
  Future getItems() async{
    print("INSIDE GET ITEMS ");
    await firestore.collection("restaurants")
          .document(widget.restaurantID)
          .collection("items")
          .orderBy("category_id")
          .getDocuments()
          .then((itemDoc) async {
      print("INSIDE ITEM DOCS ");
        String categoryId = "";
        mItems.clear();
        for (int i = 0; i <= itemDoc.documents.length-1; i++) {
          print("INSIDE GET ITEMS FOR times "+i.toString());
          bool available = true;
          String currentCategory = await itemDoc.documents[i].data["category_id"];
          if (!(categoryId == currentCategory))
            categoryId =  await  itemDoc.documents[i].data["category_id"];
          String name = await  itemDoc.documents[i].data["name"];
          if (itemDoc.documents[i].data.containsKey("is_available")){
            if (!itemDoc.documents[i].data["is_available"]) {
              available = false;
            }
          }
          String description = "";
          if (itemDoc.documents[i].data.containsKey("description")) {
            description =  await itemDoc.documents[i].data["description"];
          }
          DietType type = DietType.NONE;
          if (itemDoc.documents[i].data.containsKey("type")) {
            type = getDietTypeFromString( await itemDoc.documents[i].data["type"]);
          }
          int cost = int.parse( await itemDoc.documents[i].data["cost"]);
          MenuItem item = new MenuItem(itemDoc.documents[i].documentID, name, description,
              currentCategory, cost, available, type);
          if(!mItems.containsKey(currentCategory))
            {
              List<MenuItem> categoryList = new List<MenuItem>();
              categoryList.add(item);
              mItems[currentCategory] =categoryList;
            }
          else{
            mItems[currentCategory].add(item);
          }
        }

      mItems.forEach((key, value) {
        print("Catagory = " + key);
        for(int i =0 ; i< value.length;i++)
          print(value[i].getName());
      });
       await setupMenu();
      });
  }
  Future setupMenu() async {
  print("INSIDE SETUP MENU");
    mMenu.clear();
    for (int i = 0; i < mCategories.length; i++) {
      print("INSIDE SETUP MENU FOR times "+i.toString());
      final MenuCategory category = mCategories[i];
      String categoryID = category.getId();
      mMenu.add(category);
      mCategoryOrderMap[category.getName()] = (mMenu.length- 1);
     // categoryMenu.getMenu().add(category.getName());
      mMenu.addAll(mItems[categoryID]);
    }
   for(int i=0;i<mMenu.length;i++) {

     if (mMenu[i].toString() == "Instance of 'MenuCategory'")
       {
        MenuCategory m = mMenu[i];
       print(" CATAGORY " + m.name);
       print("   /n");
   }
     else{
       MenuItem m = mMenu[i];
       print("" + m.name);
     }

   }

   return mMenu;
  }
  Future _finalmenulist;
  @override
  void initState() {
    _finalmenulist = getMenuData().whenComplete((){
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Menu Screen"),
      ),
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              FlatButton(onPressed: getMenuData, child: Text("GET MENU")),
              Text(
                "Resturant name = " + widget.restaurantName,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "Table name = " + widget.tableName,
                style: TextStyle(fontSize: 20),
              ),
              Text(
                "session ID = " + widget.sessionID,
                style: TextStyle(fontSize: 20),
              ),
              menuList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget menuList()  {
    return FutureBuilder(
        future: _finalmenulist,
        builder: (context, snapshot) {
          if (isLoading == true) {
            return Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                        FriskyColor().colorPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          else{
            return Column(
              children: <Widget>[
                ListView.builder(
                    itemCount: mMenu.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      if(mMenu[index].toString()=="Instance of 'MenuCategory'")
                        {
                          MenuCategory m = mMenu[index];
                          return ListTile(title: Text(m.name),);
                        }
                      return Text("heloow");
                    }),
              ],
            );
          }
        }
    );
  }
}


