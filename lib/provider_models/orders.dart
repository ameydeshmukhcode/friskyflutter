


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:friskyflutter/structures/order_header.dart';
import 'package:friskyflutter/structures/order_item.dart';
import 'package:friskyflutter/structures/order_status.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:friskyflutter/provider_models/session.dart';
class Orders extends ChangeNotifier
{

  List<Object> mOrderList = new List<Object>();
  bool isOrderActive = false;
  Future getOrderStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isOrderActive = sharedPreferences.getBool("session_active");
    if (isOrderActive == null || isOrderActive == false) {
      isOrderActive = false;
      notifyListeners();
    }
    else{
      isOrderActive = true;
      notifyListeners();
    }
  }

  Stream<List<dynamic>> getOrders() async*{
    SharedPreferences sp = await SharedPreferences.getInstance();
    Firestore.instance
        .collection("restaurants")
        .document(sp.getString("restaurant_id"))
        .collection("orders")
        .where("session_id", isEqualTo: sp.getString("session_id"))
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((snaps) {
      mOrderList.clear();
      int docRank = snaps.documents.length;
      print(docRank.toString());
      print(snaps.toString());
      for (DocumentSnapshot documentSnapshot in snaps.documents) {
        Map<dynamic, dynamic> orderData = documentSnapshot.data["items"];
        print(orderData);
        String orderTime = formatDate(
            documentSnapshot.data["timestamp"].toDate(),
            [hh, ':', nn, ' ', am]).toString();
        print(orderTime);
        OrderHeader orderHeader = new OrderHeader(orderTime, docRank);
        mOrderList.add(orderHeader);
        for (int i = 0; i < orderData.length; i++) {
          String itemID = orderData.keys.elementAt(i).toString();
          Map<dynamic, dynamic> itemData = orderData.values.elementAt(i);
          print(itemID);
          print(itemData);
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
          } else if (itemData["status"].toString().compareTo("cancelled") ==
              0) {
            orderItem.orderStatus = OrderStatus.cancelled;
          }
          mOrderList.add(orderItem);
        }
        docRank--;
      }
      print(mOrderList.toString());
    });
    notifyListeners();
  }
}

