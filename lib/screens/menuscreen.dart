import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();

  MenuScreen(this.restaurantName, this.tableName, this.sessionID,):super();
     final String restaurantName,tableName,sessionID;
}

class _MenuScreenState extends State<MenuScreen> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menu Screen"),),
      body: Center(
        child: Container(
          child: Column( mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text("Resturant name = "+ widget.restaurantName,style: TextStyle(fontSize: 20),),
              Text("Table name = "+ widget.tableName,style: TextStyle(fontSize: 20),),
              Text("session ID = "+ widget.sessionID,style: TextStyle(fontSize: 20),)
            ],
          ),
        ),
      ),

    );
  }


}
