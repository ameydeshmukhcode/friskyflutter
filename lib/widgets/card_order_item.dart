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
          Expanded(
            child: Column(
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
                    Flexible(
                      child: Text(name, style: TextStyle(fontFamily: "museoS")),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text("x" + count.toString(),
                        style: TextStyle(fontFamily: "museoS")),
                    Padding(
                      padding: EdgeInsets.only(left: 4),
                    ),
                    Text("Item total ", style: TextStyle(fontFamily: "museoS")),
                    Text(
                      "\u20B9 " + total.toString(),
                      style: TextStyle(color: Colors.red, fontFamily: "museoS"),
                    )
                  ],
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
              ),
              Padding(
                padding: EdgeInsets.only(left: 4),
              ),
              Text(
                _getStatusString(status),
                style: TextStyle(
                    color: _getStatusColor(status), fontFamily: "museoS"),
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

  MaterialColor _getStatusColor(OrderStatus orderStatus) {
    switch (orderStatus) {
      case OrderStatus.pending:
        return Colors.yellow;
      case OrderStatus.accepted:
        return Colors.green;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        return Colors.red;
    }
    return Colors.transparent;
  }
}
