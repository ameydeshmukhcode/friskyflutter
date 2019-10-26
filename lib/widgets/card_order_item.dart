import 'package:flutter/material.dart';

class OrderItemWidget extends StatelessWidget {
  final String name;
  final int count;
  final int total;

  OrderItemWidget(this.name, this.count, this.total);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    Icons.trip_origin,
                    size: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                  ),
                  Text(name)
                ],
              ),
              Row(
                children: <Widget>[
                  Text("x" + count.toString()),
                  Padding(
                    padding: EdgeInsets.only(left: 4),
                  ),
                  Text("Item total \u20B9" + total.toString()),
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                Icons.done,
                color: Colors.green,
              ),
              Padding(
                padding: EdgeInsets.only(left: 4),
              ),
              Text(
                "Accepted",
                style: TextStyle(color: Colors.green),
              )
            ],
          )
        ],
      ),
    );
  }
}
