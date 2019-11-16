import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/screens/options.dart';
import 'package:friskyflutter/size_config.dart';
import 'package:shimmer/shimmer.dart';

import '../frisky_colors.dart';
import '../restaurants_details_screen.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin<HomeTab> {
  @override
  bool get wantKeepAlive => true;
  FirebaseUser user;
  bool isSignedIn = false;
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

  changeStatus() async {}

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.all(5.0),
          child: SvgPicture.asset('images/logo_text.svg'),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              color: FriskyColor().colorPrimary,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => OptionsScreen()));
              })
        ],
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(child: _restaurantsList()),
          ],
        ),
      ),
    );
  }

  Widget _restaurantsList() {
    return FutureBuilder(
        future: _restaurantList,
        builder: (context, snapshot) {
          // ignore: missing_return
          if (snapshot.connectionState == ConnectionState.waiting) {
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
                                          SizeConfig.safeBlockHorizontal * 30,
                                      color: Colors.white12,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 30,
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
                                          SizeConfig.safeBlockHorizontal * 30,
                                      color: Colors.white12,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 30,
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
                                          SizeConfig.safeBlockHorizontal * 30,
                                      color: Colors.white12,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 30,
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
                                          SizeConfig.safeBlockHorizontal * 30,
                                      color: Colors.white12,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 30,
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
                                          SizeConfig.safeBlockHorizontal * 30,
                                      color: Colors.white12,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 30,
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
                                          SizeConfig.safeBlockHorizontal * 30,
                                      color: Colors.white12,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 30,
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
                                          SizeConfig.safeBlockHorizontal * 30,
                                      color: Colors.white12,
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 4,
                                    ),
                                    Container(
                                      width:
                                          SizeConfig.safeBlockHorizontal * 30,
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
          } else {
            return Flexible(
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                      child: Card(
                          margin: EdgeInsets.all(0),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              navigateToDetails(snapshot.data[index]);
                            },
                            child: Container(
                              height: SizeConfig.safeBlockVertical * 12,
                              width: SizeConfig.safeBlockHorizontal * 100,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Image.network(
                                    snapshot.data[index].data['image'],
                                    fit: BoxFit.cover,
                                    width:
                                        SizeConfig.safeBlockHorizontal * 50 - 8,
                                  ),
                                  Container(
                                    width:
                                        SizeConfig.safeBlockHorizontal * 50 - 8,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
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
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            snapshot
                                                .data[index].data['address'],
                                            maxLines: 1,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          Text(
                                            snapshot.data[index].data['cuisine']
                                                    [0] +
                                                ", " +
                                                snapshot.data[index]
                                                    .data['cuisine'][1],
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
                    );
                  }),
            );
          }
        });
  }
}
