import 'dart:core';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:friskyflutter/structures/visit.dart';
import 'package:friskyflutter/widgets/card_visit.dart';

import '../frisky_colors.dart';

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
  var restaurantID;
  var restaurantName;
  var endTime;
  var totalAmount;
  var imagePath;

  Future _visitsListFuture;
  bool isLoading = true;
  bool isEmpty = false;

  Future getUser() async {
    firebaseUser = await _auth.currentUser();
    print("Firebase user id " + firebaseUser.uid.toString());
  }

  @override
  void initState() {
    this.getUser().whenComplete(() {
      _visitsListFuture = this.getVisits().whenComplete(() {
        setState(() {
          if (VisitsList.isNotEmpty) {
            isLoading = false;
          } else {
            isLoading = false;
            isEmpty = true;
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
          endTime = await data.documents[i]["end_time"];
          totalAmount = await data.documents[i]["amount_payable"];
          var img = data.documents[i].reference.parent().parent();
          await img.get().then((f) async {
            imagePath = await f.data["image"];
            restaurantName = await f.data["name"];
            restaurantID = f.documentID;
          }).then((f) async {
            VisitsList.add(Visit(sessionId, restaurantID, imagePath,
                restaurantName, endTime, totalAmount));
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
        future: _visitsListFuture,
        builder: (context, snapshot) {
          if (isLoading == true) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  FriskyColor.colorPrimary,
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
                        "You do not have any visits yet.",
                        style: TextStyle(
                            fontFamily: "Varela",
                            fontSize: 20,
                            color: FriskyColor.colorTextLight),
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
                  itemBuilder: (context, index) {
                    return VisitWidget(
                      VisitsList[index].sessionID,
                      VisitsList[index].restaurantID,
                      VisitsList[index].restaurantName,
                      VisitsList[index].restaurantImage,
                      VisitsList[index].endTime,
                      VisitsList[index].totalAmount,
                    );
                  });
            }
          }
        });
  }
}
