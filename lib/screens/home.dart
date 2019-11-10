import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:friskyflutter/login/user_login.dart';
import 'package:friskyflutter/provider_models/orders.dart';
import 'package:friskyflutter/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../frisky_colors.dart';
import 'package:provider/provider.dart';
import 'package:friskyflutter/provider_models/session.dart';
import '../restaurants_details_screen.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab>
    with AutomaticKeepAliveClientMixin<HomeTab> {
  @override
  bool get wantKeepAlive => true;
  FirebaseAuth _auth = FirebaseAuth.instance;
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

  signOut() async {
    _auth.signOut();
    Navigator.pushReplacement(
        context, new MaterialPageRoute(builder: (context) => UserLogin()));
  }

  getUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (firebaseUser != null && firebaseUser.isEmailVerified == true) {
      print("ye hai USer Id " + firebaseUser.uid);
      setState(() {
        this.isSignedIn = true;
      });
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void initState() {
    super.initState();
    this.getUser();
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

  changeStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool("session_active")) {
      await sharedPreferences.setBool("session_active", false);
      await sharedPreferences.setBool("order_active", false);
      await sharedPreferences.setBool("bill_requested", false);
      Provider.of<Orders>(context).mOrderList.clear();

    } else {
      await sharedPreferences.setBool("session_active", true);
      await sharedPreferences.setBool("bill_requested", true);
      Provider.of<Orders>(context).mOrderList.clear();
    }
    Provider.of<Session>(context).getStatus();
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.all(5.0),
          child: SvgPicture.asset('img/logo1.svg'),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              color: FriskyColor().colorPrimary,
              onPressed: () {
                changeStatus();
              })
        ],
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: !isSignedIn
          ? Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                ],
              ),
            )
          : Container(
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
            return Align(
              alignment: Alignment.center,
              child: Column(
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
          } else {
            return ListView.builder(
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                          snapshot.data[index].data['address'],
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
                });
          }
        });
  }
}
