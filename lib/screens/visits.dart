import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../frisky_colors.dart';
import '../size_config.dart';

class VisitTab extends StatefulWidget {
  @override
  _VisitTabState createState() => _VisitTabState();
}

class _VisitTabState extends State<VisitTab> {
  @override
  // bool get wantKeepAlive => true;
  Future _visitsListData;
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
        .where("created_by", isEqualTo: firebaseUser.uid)
        .orderBy("end_time", descending: true)
        .getDocuments();
    return querySnapshot.documents;
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _visitsList(),
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
                        FriskyColor().colorCustom,
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
                                        Text(
                                          "created_by" +
                                              snapshot.data[index]
                                                  ["created_by"],
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
