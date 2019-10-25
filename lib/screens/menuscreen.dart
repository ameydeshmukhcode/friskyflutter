import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu Screen"),),
      body: Container(
        child: Column(
          children: <Widget>[
            Text("heloow from  MEnu")
          ],
        ),
      ),

    );
  }
}
