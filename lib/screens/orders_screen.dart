import 'package:flutter/material.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Your Order"),),
      body: Container(
        child: Center(child: Text("THIS IS ORDER CONFIMATIONS SCREEN"),),
      ),
    );
  }
}

