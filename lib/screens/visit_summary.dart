import 'package:flutter/material.dart';

class VisitSummary extends StatelessWidget {

  final String sessionID;
  final String restaurantID;
  final String restaurantName;

  VisitSummary({Key key, @required this.sessionID, @required this.restaurantID,
    @required this.restaurantName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(sessionID + restaurantID + restaurantName);
    return Scaffold(
      appBar: AppBar(
        title: Text("Visit Summary",
          style: TextStyle (
              color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData (
          color: Colors.black
        ),
      ),
      body: Center(
        child: Container(

        ),
      ),
    );
  }
}
