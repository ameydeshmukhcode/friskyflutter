import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../frisky_colors.dart';
import 'package:date_format/date_format.dart';
import '../size_config.dart';


var resname;
var endtime;
var totalamount;
var imgurl;
Future _visitslist;
bool isLoading = true;
bool isEmpty = false;

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

class _VisitTabState extends State<VisitTab> {
  // bool get wantKeepAlive => true;
  //Future _visitsListData;
  FirebaseUser firebaseUser;
  FirebaseAuth _auth = FirebaseAuth.instance;
  getUser() async {
    firebaseUser = await _auth.currentUser();
    print("ye hai USer Id " + firebaseUser.uid);
  }

  @override
  void initState() {
    super.initState();
    getUser();
    _visitslist = this.getVisits().whenComplete(() {
      print("data size = = = " + VisitsList.length.toString());
      print("Empty hai kya " + VisitsList.isEmpty.toString());
      setState(() {
        if (VisitsList.isNotEmpty) {
          isLoading = false;
          print("set state kiya");
        } else {
          print("set empty state kiya");
          isLoading = false;
          isEmpty = true;
        }
      });
    });
    print("initi state huwa");
  }

  Future getVisits() async {
    print("inside get visit");
    var firestore = Firestore.instance;
    await firestore
        .collectionGroup("sessions")
        .where("created_by", isEqualTo: "PIST5V1fPxeGpFEcCNPX88qJhUR2")
        .orderBy("end_time", descending: true)
        .getDocuments()
        .then((data) async {
      print("data length = " + data.documents.length.toString());
      int i;
      VisitsList.clear();
      print(data.documents.contains("amount_payable").toString());
      for (i = 0; i < data.documents.length; i++) {
        if (data.documents[i].data.containsKey("amount_payable")) {
          endtime = await data.documents[i]["end_time"];
          totalamount = await data.documents[i]["amount_payable"];
          var img = data.documents[i].reference.parent().parent();
          print("parent ke baad ka print");
          print(img.toString());
          await img.get().then((f) async {
            imgurl = await f.data["image"];
            resname = await f.data["name"];
//            print("yeh hai img ka url " + imgurl);
//            print("yeh hai img ka name " + resname);
          }).then((f) async {
            await VisitsList.add(Visits(imgurl, resname, endtime, totalamount));
            print("add kiya for number " + i.toString());
          });
          //          VisitsList.add(new Visits(
//            data.documents[i]["imgurl"],
//            data.documents[i]["resname"],
//            data.documents[i]["end_time"],
//            data.documents[i]["amount_payable"],
//          ));
        }
        print(i.toString() + "  time in for loop");
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
          child: Column(
        children: <Widget>[_visitsList()],
      )),
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
              return Text("NULL hai bhai sorted ");
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
                             // navigateToDetails(snapshot.data[index]);
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
