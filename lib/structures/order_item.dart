import 'package:friskyflutter/structures/order_status.dart';

class OrderItem {
  String _id;
  String _name;
  int _count = 0;
  int _total;
  OrderStatus orderStatus = OrderStatus.pending;

  OrderItem(this._id, this._name, this._count, this._total);
}
