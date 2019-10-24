import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../frisky_colors.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../size_config.dart';




class Visits {
  String restaurantImage;
  String restaurantName;
  Timestamp endTime;
  String totalAmount;
  Visits(
      [String restaurantImage,
      String restaurantName,
      Timestamp endTime,
      String totalAmount]) {
    this.restaurantImage = restaurantImage;

    this.restaurantName = restaurantName;
    this.endTime = endTime;
    this.totalAmount = totalAmount;
  }
}

// ignore: non_constant_identifier_names
List<Visits> VisitsList = List<Visits>();

class VisitTab extends StatefulWidget {
  @override
  _VisitTabState createState() => _VisitTabState();
}

class _VisitTabState extends State<VisitTab>with AutomaticKeepAliveClientMixin<VisitTab>{
  bool get wantKeepAlive => true;
  FirebaseUser _firebaseUser;
  FirebaseAuth _auth = FirebaseAuth.instance;
  var resname;
  var endtime;
  var totalamount;
  var imgurl;
  Future _visitslist;
  bool isLoading = true;
  bool isEmpty = false;
  getUser() async {
    _firebaseUser = await _auth.currentUser();
  }

  @override
  void initState() {
    super.initState();
    getUser();
    _visitslist = this.getVisits().whenComplete(() {
      setState(() {
        if (VisitsList.isNotEmpty) {
          isLoading = false;
        } else {
          isLoading = false;
          isEmpty = true;
        }
      });
    });
  }

  Future getVisits() async {
    var firestore = Firestore.instance;
    await firestore
        .collectionGroup("sessions")
        .where("created_by", isEqualTo: _firebaseUser.uid)
        .orderBy("end_time", descending: true)
        .getDocuments()
        .then((data) async {
      int i;
      VisitsList.clear();
      for (i = 0; i < data.documents.length; i++) {
        if (data.documents[i].data.containsKey("amount_payable")) {
          endtime = await data.documents[i]["end_time"];
          totalamount = await data.documents[i]["amount_payable"];
          var img = data.documents[i].reference.parent().parent();
          await img.get().then((f) async {
            imgurl = await f.data["image"];
            resname = await f.data["name"];
          }).then((f) async {
            VisitsList.add(Visits(imgurl, resname, endtime, totalamount));
          });
        }
      }
    });

    return VisitsList;
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // body: //_visitsList(),
      body: Center(
          child: _visitsList(),
      )
    );
  }

  Widget _visitsList() {
    return FutureBuilder(
        future: _visitslist,
        builder: (context, snapshot) {
          // ignore: missing_return
          if (isLoading == true) {
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
            if (isLoading == false && isEmpty == true) {
              return Container(child:
              Center(
                child: Column( mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("You Do Not Have Any Visits Yet!",style: TextStyle(
                      fontSize: 20,
                        color: FriskyColor().colorTextLight),),
                    SizedBox(height: 30,),
                   Container(
                      child: SvgPicture.asset(
                        'img/no_visits.svg',
                        height: SizeConfig.safeBlockVertical * 30,
                        width: SizeConfig.safeBlockHorizontal * 56,
                      ),
                    ),
                  ],
                ),
              ),
              );
            } else {
              return ListView.builder(
                  itemCount: VisitsList.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                      child: Card(
                          margin: EdgeInsets.all(0),
                          elevation: 1,
                          child: InkWell(
                            onTap: () {
                                   },
                            child: Container(
                              height: SizeConfig.safeBlockVertical * 14.5,
                              width: SizeConfig.safeBlockHorizontal * 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Image.network(
                                    VisitsList[index].restaurantImage,
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
                                            VisitsList[index].restaurantName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: FriskyColor().colorTextLight,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Divider(),
                                          Text("Visited On ",
                                            maxLines: 1,

                                            style: TextStyle(
                                                color: FriskyColor().colorTextLight,
                                                fontWeight: FontWeight.w300,
                                                fontSize: 15),
                                          ),
                                          Text(formatDate(VisitsList[index].endTime.toDate(), [dd, ' ', M, ' ', yyyy,' ', hh,':', nn, '', am]),
                                            maxLines: 1,
                                            style: TextStyle(fontSize: 15,
                                                color: FriskyColor().colorTextLight,

                                                fontWeight: FontWeight.bold
                                            ),
                                          ),

                                          SizedBox(height: SizeConfig.blockSizeVertical * 0.5,),
                                          Text("Total Amount",

                                            maxLines: 1,
                                            style: TextStyle(fontSize: 15,
                                                color: FriskyColor().colorTextLight,

                                                fontWeight: FontWeight.w300),

                                          ),
                                          Text(
                                               "\u20B9 "+VisitsList[index].totalAmount,
                                            style: TextStyle(fontSize: 15,
                                                color: FriskyColor().colorTextLight,

                                                fontWeight: FontWeight.bold),
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
          }
        });
  }
}
