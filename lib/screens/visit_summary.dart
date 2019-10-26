import 'package:flutter/material.dart';

class VisitSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
