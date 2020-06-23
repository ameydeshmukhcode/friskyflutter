import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../structures/order_header.dart';
import '../structures/order_item.dart';

class Orders extends ChangeNotifier {
  bool isOrderActive = false;
  bool isLoading = true;
  List<Object> ordersList = new List<Object>();
  String amountPayable = "0";
  String gst = "0";
  String billAmount = "0";

  fetchData() async {
    await getOrders().then((a) async {
      await getBillDetails().then((a) async{
        getOrderStatus().then((value) async => notifyListeners());
      });
    });
  }

  Future getOrders() async {
    ordersList.removeRange(0, ordersList.length);
    SharedPreferences sp = await SharedPreferences.getInstance();
    Firestore.instance
        .collection("restaurants")
        .document(sp.getString("restaurant_id"))
        .collection("orders")
        .where("session_id", isEqualTo: sp.getString("session_id"))
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snaps) {
      if (snaps.documentChanges.isNotEmpty) {
        updateList(snaps);
        notifyListeners();
      } else {
        updateList(snaps);
        notifyListeners();
      }
    });
  }

  Future getBillDetails() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    Firestore.instance
        .collection("restaurants")
        .document(sp.getString("restaurant_id"))
        .collection("sessions")
        .document(sp.getString("session_id"))
        .snapshots()
        .listen((data) {
      if (data.exists) {
        updateBill(data);
        notifyListeners();
      } else {
        updateBill(data);
        notifyListeners();
      }
    });
  }

  updateBill(data) {
    amountPayable = data["amount_payable"] ?? "0";
    gst = data["gst"] ?? "0";
    billAmount = data["bill_amount"] ?? "0";
  }

  resetBill() {
    amountPayable = "0";
    gst = "0";
    billAmount = "0";
    notifyListeners();
  }

  resetOrdersList() {
    ordersList.clear();
    notifyListeners();
  }

  updateList(snaps) {
    ordersList.clear();
    int docRank = snaps.documents.length;
    for (DocumentSnapshot documentSnapshot in snaps.documents) {
      Map<dynamic, dynamic> orderData = documentSnapshot.data["items"];
      String orderTime = formatDate(documentSnapshot.data["timestamp"].toDate(),
          [hh, ':', nn, ' ', am]).toString();
      OrderHeader orderHeader = new OrderHeader(orderTime, docRank);
      ordersList.add(orderHeader);
      for (int i = 0; i < orderData.length; i++) {
        String itemID = orderData.keys.elementAt(i).toString();
        Map<dynamic, dynamic> itemData = orderData.values.elementAt(i);
        String name = itemData["name"];
        int cost = int.parse(itemData["cost"]);
        int quantity = itemData["quantity"];
        OrderItem orderItem =
            OrderItem(itemID, name, quantity, (quantity * cost));
        if (itemData["status"].toString().compareTo("pending") == 0) {
          orderItem.orderStatus = OrderStatus.pending;
        } else if (itemData["status"].toString().compareTo("accepted") == 0) {
          orderItem.orderStatus = OrderStatus.accepted;
        } else if (itemData["status"].toString().compareTo("rejected") == 0) {
          orderItem.orderStatus = OrderStatus.rejected;
        } else if (itemData["status"].toString().compareTo("cancelled") == 0) {
          orderItem.orderStatus = OrderStatus.cancelled;
        }
        ordersList.add(orderItem);
      }
      docRank--;
    }
  }

  Future getOrderStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isOrderActive = sharedPreferences.getBool("order_active");
    if (isOrderActive == null || isOrderActive == false) {
      isOrderActive = false;
      notifyListeners();
    } else {
      isOrderActive = true;
      notifyListeners();
    }
  }
}
