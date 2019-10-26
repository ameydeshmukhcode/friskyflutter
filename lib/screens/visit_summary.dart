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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    print(widget.sessionID + " " + widget.restaurantID + " " + widget.restaurantName);

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
      body: Center(
        child: Container(),
      ),
    );
  }
}
