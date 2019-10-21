import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../frisky_colors.dart';
import '../size_config.dart';

var resname;
var endtime;
var totalamount;
var imgurl;

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

class v {
  String cb;
  v(String cb) {
    this.cb = cb;
  }
}

List<Visits> VisitsList = List<Visits>();
List<v> vList = List<v>();

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
    // getVisits();
  }

 Future getVisits() async {
    var firestore = Firestore.instance;
    var querySnapshot = await firestore
        .collectionGroup("sessions")
        .where("created_by", isEqualTo: "PIST5V1fPxeGpFEcCNPX88qJhUR2")
        .orderBy("end_time", descending: true)
        .getDocuments()
        .then((data) {
      print("data length = " + data.documents.length.toString());
      int i;
      vList.clear();
      VisitsList.clear();
      print(data.documents.contains("amount_payable").toString());

      for (i = 0; i < data.documents.length; i++) {
        if (data.documents[i].data.containsKey("amount_payable")) {
              endtime = data.documents[i]["end_time"];
              totalamount = data.documents[i]["amount_payable"];
          var img = data.documents[i].reference.parent().parent();
          print("parent ke baad ka print");
          print(img.toString());
          img.get().then((f) {
            imgurl = f.data["image"];
            resname = f.data["name"];
//            print("yeh hai img ka url " + imgurl);
//            print("yeh hai img ka name " + resname);
          }).then((Null){

            VisitsList.add(Visits(imgurl,resname,endtime,totalamount));
                    print("add kiya for number "+ i.toString());
            VisitsList.forEach((f) {
              print(f.restaurantImage.toLowerCase()+" yeahhh ");
            });
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
//
//          print("data length = "+data.documents.length.toString());
//          data.documents.forEach((f){
//            print(f.data.toString());
//            print(f.data["amount_payable"]);
//              vList.add(new v(f.data["amount_payable"]));
//          }
//          );
//      print("after loop");
//      print("LIST KA SIZE " + VisitsList.length.toString());
//
//      print("after loop msg ");
//          print(VisitsList.length.toString());
//          print(VisitsList);
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
            children: <Widget>[
              MaterialButton(onPressed: getVisits, child: Text("get data")),
              _visitsList()
            ],
          )),
    );
  }

  Widget _visitsList() {
    return FutureBuilder(
        future: getVisits(),
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
                          onTap: () {},
                          child: Container(
                            height: SizeConfig.safeBlockVertical * 12,
                            width: SizeConfig.safeBlockHorizontal * 100,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                // Image.network();
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
                                        Text( VisitsList[index].restaurantImage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
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
