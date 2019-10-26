import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VisitSummary extends StatefulWidget {
  final String sessionID;
  final String restaurantID;
  final String restaurantName;

  VisitSummary(
      {Key key,
      @required this.sessionID,
      @required this.restaurantID,
      @required this.restaurantName})
      : super(key: key);

  @override
  _VisitSummaryState createState() => _VisitSummaryState();
}

class _VisitSummaryState extends State<VisitSummary> {
  Timestamp endTime;
  String amountPayable;
  String gst;
  String billAmount;

  @override
  void initState() {
    super.initState();

    _getVisitSummary().whenComplete(() {
      print(endTime.toString() +
          " " +
          amountPayable.toString() +
          " " +
          gst.toString() +
          " " +
          billAmount.toString());
      _getOrders().whenComplete(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Visit Summary",
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Column());
  }

  Future _getVisitSummary() async {
    await Firestore.instance
        .collection("restaurants")
        .document(widget.restaurantID)
        .collection("sessions")
        .document(widget.sessionID)
        .get()
        .then((data) async {
      endTime = data["end_time"];
      amountPayable = data["amount_payable"];
      gst = data["gst"];
      billAmount = data["bill_amount"];
    });
  }

  Future _getOrders() async {
    await Firestore.instance
        .collection("restaurants")
        .document(widget.restaurantID)
        .collection("orders")
        .where("session_id", isEqualTo: widget.sessionID)
        .getDocuments()
        .then((data) async {
      for (DocumentSnapshot documentSnapshot in data.documents) {
        print(documentSnapshot.data);
      }
    });
  }
}
