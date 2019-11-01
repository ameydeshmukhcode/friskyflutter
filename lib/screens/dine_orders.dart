import 'package:flutter/material.dart';

class DineOrders extends StatefulWidget {
  @override
  _DineOrdersState createState() => _DineOrdersState();
}

class _DineOrdersState extends State<DineOrders> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("DINE SCREEN WHILE SESSION ACTIVE"),
      ),
      color: Colors.white,
    );
  }
}
