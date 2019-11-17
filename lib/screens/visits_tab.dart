import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friskyflutter/structures/visit.dart';
import 'package:shimmer/shimmer.dart';

import '../frisky_colors.dart';
import 'visit_summary.dart';

// ignore: non_constant_identifier_names
List<Visit> VisitsList = List<Visit>();

class VisitsTab extends StatefulWidget {
  @override
  _VisitsTabState createState() => _VisitsTabState();
}

class _VisitsTabState extends State<VisitsTab>
    with AutomaticKeepAliveClientMixin<VisitsTab> {
  bool get wantKeepAlive => true;
  FirebaseUser firebaseUser;
  FirebaseAuth _auth = FirebaseAuth.instance;

  var sessionId;
  var resname;
  var endtime;
  var totalamount;
  var imgurl;
  var resid;

  Future _visitslist;
  bool isLoading = true;
  bool isEmpty = false;

  Future getUser() async {
    firebaseUser = await _auth.currentUser();
    print(firebaseUser.uid.toString());
  }

  @override
  void initState() {
    this.getUser().whenComplete(() {
      _visitslist = this.getVisits().whenComplete(() {
        setState(() {
          print("inside set state");
          if (VisitsList.isNotEmpty) {
            print("inside set state if");
            isLoading = false;
          } else {
            print("inside set state else");
            isLoading = false;
            isEmpty = true;
            print("length  = " + VisitsList.length.toString());
          }
        });
      });
    });

    super.initState();
  }

  Future getVisits() async {
    var firestore = Firestore.instance;
    await firestore
        .collectionGroup("sessions")
        .where("created_by", isEqualTo: firebaseUser.uid)
        .orderBy("end_time", descending: true)
        .getDocuments()
        .then((data) async {
      int i;
      VisitsList.clear();
      for (i = 0; i < data.documents.length; i++) {
        if (data.documents[i].data.containsKey("amount_payable")) {
          sessionId = data.documents[i].documentID;
          endtime = await data.documents[i]["end_time"];
          totalamount = await data.documents[i]["amount_payable"];
          var img = data.documents[i].reference.parent().parent();
          await img.get().then((f) async {
            imgurl = await f.data["image"];
            resname = await f.data["name"];
            resid = f.documentID;
          }).then((f) async {
            VisitsList.add(Visit(
                sessionId, resid, imgurl, resname, endtime, totalamount));
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
      body: SafeArea(child: _visitsList()),
    );
  }

  Widget _visitsList() {
    return FutureBuilder(
        future: _visitslist,
        builder: (context, snapshot) {
          if (isLoading == true) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  FriskyColor().colorPrimary,
                ),
              ),
            );
          } else {
            if (isEmpty == true) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 16),
                      child: Text(
                        "You do not have any visits yet!",
                        style: TextStyle(
                            fontSize: 20,
                            color: FriskyColor().colorTextLight,
                            fontFamily: "museoS"),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 64, top: 16, right: 64),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: SvgPicture.asset(
                          'images/state_graphics/state_no_visits.svg',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                  itemCount: VisitsList.length,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Container(
                        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                        child: Card(
                          margin: EdgeInsets.all(0),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VisitSummary(
                                          sessionID:
                                              VisitsList[index].sessionID,
                                          restaurantID:
                                              VisitsList[index].restaurantID,
                                          restaurantName:
                                              VisitsList[index].restaurantName,
                                        )),
                              );
                            },
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Image.network(
                                      VisitsList[index].restaurantImage,
                                      fit: BoxFit.fitWidth,
                                      height: 90),
                                ),
                                Expanded(
                                    child: Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
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
                                              color:
                                                  FriskyColor().colorTextLight,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "museoM"),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 4),
                                        ),
                                        Text(
                                          "Visited On ",
                                          maxLines: 1,
                                          style: TextStyle(
                                              color:
                                                  FriskyColor().colorTextLight,
                                              fontSize: 12,
                                              fontFamily: "museoS"),
                                        ),
                                        Text(
                                          _getFormattedTimestamp(
                                              VisitsList[index].endTime),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  FriskyColor().colorTextLight,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "museoS"),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(top: 4),
                                        ),
                                        Text(
                                          "Total Amount",
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  FriskyColor().colorTextLight,
                                              fontFamily: "museoS"),
                                        ),
                                        Text(
                                          "\u20B9 " +
                                              VisitsList[index].totalAmount,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  FriskyColor().colorTextLight,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "museoS"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ));
                  });
            }
          }
        });
  }

  _getFormattedTimestamp(Timestamp timestamp) {
    return formatDate(
        timestamp.toDate(), [dd, ' ', M, ' ', yyyy, ' ', hh, ':', nn, '', am]);
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
                                  color: Colors.white12,),
                                SizedBox(width: 8,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          40,
                                      color: Colors.white12,
                                      height: 16,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      child: Text(
                                        "\u20B9 \u20B9 \u20B9 \u20B9 \u20B9",
                                        style: TextStyle(color: Colors.black),),
                                      width: SizeConfig.safeBlockHorizontal *
                                          30, height: 10,),
                                    // Text("\u20B9" ,style: TextStyle(color: Colors.white12),)

                                  ],
                                )

                              ],
                            )
                        ),
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
                            enabled: true,
                            baseColor: Colors.grey,
                            highlightColor: Colors.white10,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: SizeConfig.safeBlockHorizontal * 50,
                                  color: Colors.white12,),
                                SizedBox(width: 8,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          40,
                                      color: Colors.white12,
                                      height: 16,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      child: Text(
                                        "\u20B9 \u20B9 \u20B9 \u20B9 \u20B9",
                                        style: TextStyle(color: Colors.black),),
                                      width: SizeConfig.safeBlockHorizontal *
                                          30, height: 10,),
                                    // Text("\u20B9" ,style: TextStyle(color: Colors.white12),)

                                  ],
                                )

                              ],
                            )
                        ),
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
                            enabled: true,
                            baseColor: Colors.grey,
                            highlightColor: Colors.white10,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: SizeConfig.safeBlockHorizontal * 50,
                                  color: Colors.white12,),
                                SizedBox(width: 8,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          40,
                                      color: Colors.white12,
                                      height: 16,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      child: Text(
                                        "\u20B9 \u20B9 \u20B9 \u20B9 \u20B9",
                                        style: TextStyle(color: Colors.black),),
                                      width: SizeConfig.safeBlockHorizontal *
                                          30, height: 10,),
                                    // Text("\u20B9" ,style: TextStyle(color: Colors.white12),)

                                  ],
                                )

                              ],
                            )
                        ),
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
                            enabled: true,
                            baseColor: Colors.grey,
                            highlightColor: Colors.white10,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: SizeConfig.safeBlockHorizontal * 50,
                                  color: Colors.white12,),
                                SizedBox(width: 8,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          40,
                                      color: Colors.white12,
                                      height: 16,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      child: Text(
                                        "\u20B9 \u20B9 \u20B9 \u20B9 \u20B9",
                                        style: TextStyle(color: Colors.black),),
                                      width: SizeConfig.safeBlockHorizontal *
                                          30, height: 10,),
                                    // Text("\u20B9" ,style: TextStyle(color: Colors.white12),)

                                  ],
                                )

                              ],
                            )
                        ),
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
                            enabled: true,
                            baseColor: Colors.grey,
                            highlightColor: Colors.white10,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: SizeConfig.safeBlockHorizontal * 50,
                                  color: Colors.white12,),
                                SizedBox(width: 8,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          40,
                                      color: Colors.white12,
                                      height: 16,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      child: Text(
                                        "\u20B9 \u20B9 \u20B9 \u20B9 \u20B9",
                                        style: TextStyle(color: Colors.black),),
                                      width: SizeConfig.safeBlockHorizontal *
                                          30, height: 10,),
                                    // Text("\u20B9" ,style: TextStyle(color: Colors.white12),)

                                  ],
                                )

                              ],
                            )
                        ),
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
                            enabled: true,
                            baseColor: Colors.grey,
                            highlightColor: Colors.white10,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: SizeConfig.safeBlockHorizontal * 50,
                                  color: Colors.white12,),
                                SizedBox(width: 8,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          40,
                                      color: Colors.white12,
                                      height: 16,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      child: Text(
                                        "\u20B9 \u20B9 \u20B9 \u20B9 \u20B9",
                                        style: TextStyle(color: Colors.black),),
                                      width: SizeConfig.safeBlockHorizontal *
                                          30, height: 10,),
                                    // Text("\u20B9" ,style: TextStyle(color: Colors.white12),)

                                  ],
                                )

                              ],
                            )
                        ),
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
                            enabled: true,
                            baseColor: Colors.grey,
                            highlightColor: Colors.white10,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: SizeConfig.safeBlockHorizontal * 50,
                                  color: Colors.white12,),
                                SizedBox(width: 8,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          40,
                                      color: Colors.white12,
                                      height: 16,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      child: Text(
                                        "\u20B9 \u20B9 \u20B9 \u20B9 \u20B9",
                                        style: TextStyle(color: Colors.black),),
                                      width: SizeConfig.safeBlockHorizontal *
                                          30, height: 10,),
                                    // Text("\u20B9" ,style: TextStyle(color: Colors.white12),)

                                  ],
                                )

                              ],
                            )
                        ),
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
                            enabled: true,
                            baseColor: Colors.grey,
                            highlightColor: Colors.white10,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: SizeConfig.safeBlockHorizontal * 50,
                                  color: Colors.white12,),
                                SizedBox(width: 8,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          40,
                                      color: Colors.white12,
                                      height: 16,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      width: SizeConfig.safeBlockHorizontal *
                                          30,
                                      color: Colors.white12,
                                      height: 10,),
                                    SizedBox(height: 5,),
                                    Container(
                                      child: Text(
                                        "\u20B9 \u20B9 \u20B9 \u20B9 \u20B9",
                                        style: TextStyle(color: Colors.black),),
                                      width: SizeConfig.safeBlockHorizontal *
                                          30, height: 10,),
                                    // Text("\u20B9" ,style: TextStyle(color: Colors.white12),)

                                  ],
                                )

                              ],
                            )
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            );
  }*/
}
