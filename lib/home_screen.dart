import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:friskyflutter/size_config.dart';
import 'frisky_colors.dart';
import 'restaurants_details_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  bool isSignedIn = false;



  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) async {
      if (user == null) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    });
  }

  navigateToDetails(DocumentSnapshot restaurant)
  {
     Navigator.push(context,MaterialPageRoute(builder: (context)=>DetailsPage(resturant: restaurant,)));

  }

  signOut() async {
    _auth.signOut();
  }

  getUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    if (firebaseUser != null && firebaseUser.isEmailVerified==true){
      setState(() {
        this.isSignedIn = true;
      });
    }
    else{
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    this.getUser();

  }

  Future getRestaurants() async {
    var firestore = Firestore.instance;
    QuerySnapshot querySnapshot = await firestore
        .collection("restaurants")
        .where('status_listing', isEqualTo: 'complete')
        .getDocuments();
    print(querySnapshot.documents.length.toString());
    return querySnapshot.documents;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.all(5.0),
          child: SvgPicture.asset('img/logo1.svg'),
        ),
        backgroundColor: FriskyColor().white,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              color: FriskyColor().colorCustom,
              onPressed: () {
                signOut();
              })
        ],
        elevation: 0.0,
      ),
      backgroundColor: FriskyColor().white,
      body: !isSignedIn
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              color: FriskyColor().white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(child: beta_msg_card()),
                  resturants_list_view(),
                ],
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(MdiIcons.qrcode),
        label: Text("Scan QR Code"),
        backgroundColor: FriskyColor().colorCustom,
      ),
      bottomNavigationBar: bottomnavbar(),
    );
  }

  Widget beta_msg_card() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: Card(
        elevation: 5,
        child: Container(
          height: SizeConfig.safeBlockVertical * 8.5,
          width: SizeConfig.safeBlockHorizontal * 100,
          child: Center(
            child: Text(
              "Welcome to frisky Beta!\nHelp us get better",
              style: TextStyle(
                fontSize: SizeConfig.safeBlockVertical * 2.5,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }



  Widget resturants_list_view() {
    return FutureBuilder(
        future: getRestaurants(),
        builder: (context, snapshot) {
          // ignore: missing_return
          if (snapshot.connectionState == ConnectionState.waiting) {
            // ignore: missing_return
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  print(snapshot.data[index].data['status_listing'].toString());
                  // if(snapshot.data[index].data['status_listing'] == 'debug') {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                        margin: EdgeInsets.all(0),
                        elevation: 2,
                        child: InkWell(
                          onTap: (){
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
                                  width: SizeConfig.safeBlockHorizontal * 50 - 8,
                                ),
                                Container(
                                  width: SizeConfig.safeBlockHorizontal * 50 - 8,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          snapshot.data[index].data['name'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontSize:
                                                SizeConfig.safeBlockVertical *
                                                    2.2,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          snapshot.data[index].data['address'],
                                          maxLines: 1,
                                        ),
                                        Text(snapshot.data[index].data['cuisine']
                                                [0] +
                                            ", " +
                                            snapshot.data[index].data['cuisine']
                                                [1]),
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

Widget bottomnavbar() {
  return BottomNavigationBar(
    items: <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: Text(
          "HOME",
        ),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.restaurant),
        title: Text(
          "restaurants",
        ),
      ),
      BottomNavigationBarItem(
        icon: Icon(
          Icons.receipt,
        ),
        title: Text(
          "Bills",
        ),
      ),
    ],
    backgroundColor: FriskyColor().white,
    elevation: 4,
  );
}
