
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:friskyflutter/structures/order_header.dart';
import 'package:friskyflutter/structures/order_item.dart';
import 'package:friskyflutter/structures/order_status.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
class Orders extends ChangeNotifier
{

  List<Object> mOrderList = new List<Object>();

  var amountPayable =" ";
   var gst =" ";
  var billAmount ="";
     getOrders() async{


       SharedPreferences sp = await SharedPreferences.getInstance();
       Firestore.instance
           .collection("restaurants")
           .document(sp.getString("restaurant_id"))
           .collection("orders")
           .where("session_id", isEqualTo: sp.getString("session_id"))
           .orderBy("timestamp", descending: true)
           .snapshots()
           .listen((snaps) {
         if(snaps.documentChanges.isNotEmpty)
         {
           updateList(snaps);
           getBillDetails();
           notifyListeners();

         }

         else{
           print("else doc not chnages");
         }
       });
     }

  getBillDetails() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await Firestore.instance
        .collection("restaurants")
        .document(sp.getString("restaurant_id"))
        .collection("sessions")
        .document(sp.getString("session_id"))
        .get()
        .then((data) async {
      amountPayable = data["amount_payable"];
      gst = data["gst"];
      billAmount = data["bill_amount"];
      print(amountPayable);
      print(gst);
      print(billAmount);
      notifyListeners();
    });
  }


  updateList(snaps){

    mOrderList.clear();
    int docRank = snaps.documents.length;
    for (DocumentSnapshot documentSnapshot in snaps.documents) {
      Map<dynamic, dynamic> orderData = documentSnapshot.data["items"];
      String orderTime = formatDate(
          documentSnapshot.data["timestamp"].toDate(),
          [hh, ':', nn, ' ', am]).toString();
      OrderHeader orderHeader = new OrderHeader(orderTime, docRank);
      mOrderList.add(orderHeader);
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
        } else if (itemData["status"].toString().compareTo("cancelled") ==
            0) {
          orderItem.orderStatus = OrderStatus.cancelled;
        }
        mOrderList.add(orderItem);
      }
      docRank--;
    }
  }
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


}

