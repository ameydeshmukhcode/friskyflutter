import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/screens/options.dart';
import 'package:shimmer/shimmer.dart';

import '../frisky_colors.dart';
import '../restaurants_details_screen.dart';

class RestaurantsTab extends StatefulWidget {
  @override
  _RestaurantsTabState createState() => _RestaurantsTabState();
}

class _RestaurantsTabState extends State<RestaurantsTab>
    with AutomaticKeepAliveClientMixin<RestaurantsTab> {
  @override
  bool get wantKeepAlive => true;
  Future _restaurantList;

  navigateToDetails(DocumentSnapshot restaurant) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailsPage(
                  resturant: restaurant,
                )));
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
        title: Padding(
          padding: EdgeInsets.only(top: 8, bottom: 8),
          child: SvgPicture.asset('images/logo_text.svg'),
        ),
        actions: <Widget>[
          IconButton(
              tooltip: "Options",
              icon: Icon(Icons.settings),
              color: FriskyColor().colorPrimary,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OptionsScreen()));
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
                  FriskyColor().colorPrimary,
                ),
              ),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                    child: Card(
                        margin: EdgeInsets.all(0),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            navigateToDetails(snapshot.data[index]);
                          },
                          child: Wrap(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Image.network(
                                      snapshot.data[index].data['image'],
                                      fit: BoxFit.fitWidth,
                                      height: 80,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            snapshot.data[index].data['name'],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: "museoM"),
                                          ),
                                          Text(
                                            snapshot
                                                .data[index].data['address'],
                                            maxLines: 1,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: "museoS"),
                                          ),
                                          Text(
                                            snapshot.data[index].data['cuisine']
                                                    [0] +
                                                ", " +
                                                snapshot.data[index]
                                                    .data['cuisine'][1],
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontFamily: "museoS"),
                                          ),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  color: Colors.green),
                                              child: Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                  "4.5",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontFamily: "museoL"),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        )),
                  );
                });
          }
        });
  }

  /*_shimmerLoader() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: SizeConfig.safeBlockVertical * 10,
                width: SizeConfig.safeBlockHorizontal * 100,
                child: Shimmer.fromColors(
                    enabled: true,
                    baseColor: Colors.grey,
                    highlightColor: Colors.white10,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.safeBlockHorizontal * 50,
                          color: Colors.white12,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: SizeConfig.safeBlockVertical * 10,
                width: SizeConfig.safeBlockHorizontal * 100,
                child: Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white10,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.safeBlockHorizontal * 50,
                          color: Colors.white12,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: SizeConfig.safeBlockVertical * 10,
                width: SizeConfig.safeBlockHorizontal * 100,
                child: Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white10,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.safeBlockHorizontal * 50,
                          color: Colors.white12,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: SizeConfig.safeBlockVertical * 10,
                width: SizeConfig.safeBlockHorizontal * 100,
                child: Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white10,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.safeBlockHorizontal * 50,
                          color: Colors.white12,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: SizeConfig.safeBlockVertical * 10,
                width: SizeConfig.safeBlockHorizontal * 100,
                child: Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white10,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.safeBlockHorizontal * 50,
                          color: Colors.white12,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: SizeConfig.safeBlockVertical * 10,
                width: SizeConfig.safeBlockHorizontal * 100,
                child: Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white10,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.safeBlockHorizontal * 50,
                          color: Colors.white12,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: SizeConfig.safeBlockVertical * 10,
                width: SizeConfig.safeBlockHorizontal * 100,
                child: Shimmer.fromColors(
                    baseColor: Colors.grey,
                    highlightColor: Colors.white10,
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: SizeConfig.safeBlockHorizontal * 50,
                          color: Colors.white12,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 40,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Container(
                              width: SizeConfig.safeBlockHorizontal * 30,
                              color: Colors.white12,
                              height: 10,
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }*/
}
