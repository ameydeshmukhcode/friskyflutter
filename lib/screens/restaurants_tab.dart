import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/widgets/bottom_sheet_restaurant.dart';
import 'package:friskyflutter/widgets/card_restaurant.dart';

import '../frisky_colors.dart';

class RestaurantsTab extends StatefulWidget {
  @override
  _RestaurantsTabState createState() => _RestaurantsTabState();
}

class _RestaurantsTabState extends State<RestaurantsTab>
    with AutomaticKeepAliveClientMixin<RestaurantsTab> {
  @override
  bool get wantKeepAlive => true;
  Future _restaurantList;

  _showRestaurantDetails(DocumentSnapshot restaurant) {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16))),
            child: RestaurantDetails(
                restaurant.data["image"],
                restaurant.data['name'],
                restaurant.data['address'],
                restaurant.data['cuisine'][0] +
                    ", " +
                    restaurant.data['cuisine'][1]),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _restaurantList = this.getRestaurants();
  }

  Future getRestaurants() async {
    var firestore = Firestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection("restaurants")
        .where('status_listing', isEqualTo: 'complete')
        .getDocuments();
    return querySnapshot.documents;
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              tooltip: "Options",
              icon: Icon(Icons.settings),
              color: FriskyColor.colorTextDark,
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              })
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(child: _restaurantsList()),
        ],
      ),
    );
  }

  _restaurantsList() {
    return FutureBuilder(
        future: _restaurantList,
        builder: (context, snapshot) {
          // ignore: missing_return
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  FriskyColor.colorPrimary,
                ),
              ),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {
                        _showRestaurantDetails(snapshot.data[index]);
                      },
                      child: RestaurantCard(
                          snapshot.data[index].data['image'],
                          snapshot.data[index].data['name'],
                          snapshot.data[index].data['address'],
                          snapshot.data[index].data['cuisine'][0] +
                              ", " +
                              snapshot.data[index].data['cuisine'][1]));
                });
          }
        });
  }
}
