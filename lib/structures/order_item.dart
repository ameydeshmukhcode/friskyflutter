enum OrderStatus { pending, accepted, rejected, cancelled }

class OrderItem {
  String id;
  String name;
  int count = 0;
  int total;
  OrderStatus orderStatus = OrderStatus.pending;

  OrderItem(this.id, this.name, this.count, this.total);
}
