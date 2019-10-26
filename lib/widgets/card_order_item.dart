import 'package:flutter/material.dart';
import 'package:friskyflutter/structures/order_status.dart';

class OrderItemWidget extends StatelessWidget {
  final String name;
  final int count;
  final int total;
  final OrderStatus status;

  OrderItemWidget(this.name, this.count, this.total, this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
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
                  Text("Item total "),
                  Text(
                    "\u20B9 " + total.toString(),
                    style: TextStyle(color: Colors.red),
                  )
                ],
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                _getStatusIcon(status),
                color: Colors.green,
              ),
              Padding(
                padding: EdgeInsets.only(left: 4),
              ),
              Text(
                _getStatusString(status),
                style: TextStyle(color: Colors.green),
              )
            ],
          )
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus orderStatus) {
    switch (orderStatus) {
      case OrderStatus.pending:
        return Icons.access_time;
      case OrderStatus.accepted:
        return Icons.done;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return Icons.close;
    }
    return Icons.trip_origin;
  }

  String _getStatusString(OrderStatus orderStatus) {
    switch (orderStatus) {
      case OrderStatus.pending:
        return "Pending";
      case OrderStatus.accepted:
        return "Accepted";
      case OrderStatus.rejected:
        return "Rejected";
      case OrderStatus.cancelled:
        return "Cancelled";
    }
    return "";
  }
}
