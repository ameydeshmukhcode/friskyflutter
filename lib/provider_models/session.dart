import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session extends ChangeNotifier {
  bool isSessionActive = false;
  bool isBillRequested = false;
  String restaurantName = " ";
  String tableName = " ";
  String tableID = " ";
  String sessionID = " ";
  String restaurantID = " ";
  String totalAmount = "0";

  Future updateSessionStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isSessionActive = sharedPreferences.getBool("session_active");
    // isBillRequested = sharedPreferences.getBool("bill_requested");
    if (isSessionActive == null || isSessionActive == false) {
      print("in if of SESSION = " + isSessionActive.toString());
      isSessionActive = false;
      // isBillRequested =false;
      //print("SESSION = " + isSessionActive.toString());
      await sharedPreferences.remove("restaurant_id");
      await sharedPreferences.remove("session_id");
      await sharedPreferences.remove("table_id");
      await sharedPreferences.remove("table_name");
      await sharedPreferences.remove("restaurant_name");
      notifyListeners();
    } else {
      //totalAmount = (sharedPreferences.getString("total_Amount").isNotEmpty)?sharedPreferences.getString("total_Amount"):"0";
      isBillRequested = sharedPreferences.getBool("bill_requested");
      isSessionActive = true;
      print("SESSION = " + isSessionActive.toString());
      restaurantName = (sharedPreferences.getString("restaurant_name"));
      tableName = sharedPreferences.getString("table_name");
      tableID = sharedPreferences.getString("table_id");
      sessionID = sharedPreferences.getString("session_id");
      restaurantID = sharedPreferences.getString("restaurant_id");
      notifyListeners();
      getBillStatus();
    }
  }

  Future getBillStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isBillRequested = sharedPreferences.getBool("bill_requested");
    if (isBillRequested == null || isBillRequested == false) {
      isBillRequested = false;
      notifyListeners();
    } else {
      totalAmount = sharedPreferences.getString("total_Amount");
      isBillRequested = true;
      notifyListeners();
    }
  }
}
