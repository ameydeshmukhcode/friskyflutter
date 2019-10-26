import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../frisky_colors.dart';
import '../size_config.dart';
import 'visit_summary.dart';

class Visits {
  String sessionID;
  String restaurantID;
  String restaurantImage;
  String restaurantName;
  Timestamp endTime;
  String totalAmount;
  Visits([String sessionID,
        String restaurantID,
        String restaurantImage,
        String restaurantName,
        Timestamp endTime,
        String totalAmount]) {
    this.sessionID = sessionID;
    this.restaurantID = restaurantID;
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

class _VisitTabState extends State<VisitTab> with AutomaticKeepAliveClientMixin<VisitTab> {
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

  Future getUser()  async{
    firebaseUser = await _auth.currentUser();
    print(firebaseUser.uid.toString());
  }

  @override
  void initState() {
    this.getUser().whenComplete((){

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
            print("length  = "+ VisitsList.length.toString());

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
            VisitsList.add(Visits(sessionId, resid, imgurl, resname, endtime, totalamount));
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
          else {
            if (isEmpty == true) {
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
              return Column(
                children: <Widget>[
                  ListView.builder(
                      itemCount: VisitsList.length,
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                          child: Card(
                              margin: EdgeInsets.all(0),
                              elevation: 1,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => VisitSummary(
                                      sessionID: VisitsList[index].sessionID,
                                      restaurantID: VisitsList[index].restaurantID,
                                      restaurantName: VisitsList[index].restaurantName,
                                    )),
                                  );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Expanded(
                                      child: Image.network(
                                          VisitsList[index].restaurantImage,
                                          fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded (
                                        child: Container(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
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
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Divider(),
                                                Text("Visited On ",
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      color: FriskyColor().colorTextLight,
                                                      fontWeight: FontWeight.w300,
                                                      fontSize: 14),
                                                ),
                                                Text(formatDate(VisitsList[index].endTime.toDate(), [dd, ' ', M, ' ', yyyy,' ', hh,':', nn, '', am]),
                                                  maxLines: 1,
                                                  style: TextStyle(fontSize: 14,
                                                      color: FriskyColor().colorTextLight,
                                                      fontWeight: FontWeight.bold
                                                  ),
                                                ),
                                                Padding(padding: EdgeInsets.only(top: 4),),
                                                Text("Total Amount",

                                                  maxLines: 1,
                                                  style: TextStyle(fontSize: 14,
                                                      color: FriskyColor().colorTextLight,
                                                      fontWeight: FontWeight.w300),

                                                ),
                                                Text(
                                                  "\u20B9 "+VisitsList[index].totalAmount,
                                                  style: TextStyle(fontSize: 14,
                                                      color: FriskyColor().colorTextLight,
                                                      fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                    )
                                  ],
                                ),
                              ),
                            )
                        );
                      }),
                ],
              );
            }
          }
        });
  }
}
