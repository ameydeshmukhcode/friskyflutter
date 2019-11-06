import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session extends ChangeNotifier {
  bool isSessionActive = false;
  String restaurantName = " ";
  String tableName = " ";
  String tableID = " ";
  String sessionID = " ";
  String restaurantID = " ";
  Future getStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isSessionActive = sharedPreferences.getBool("session_active");
    if (isSessionActive == null || isSessionActive == false) {
      print("SESSION = " + isSessionActive.toString());
      isSessionActive = false;
      print("SESSION = " + isSessionActive.toString());
      await sharedPreferences.setString("restaurant_id", " ");
      await sharedPreferences.setString("session_id", " ");
      await sharedPreferences.setString("table_id", " ");
      await sharedPreferences.setString("table_name", " ");
      await sharedPreferences.setString("restaurant_name", " ");
      notifyListeners();
    } else {
      print("SESSION = " + isSessionActive.toString());
      restaurantName = (sharedPreferences.getString("restaurant_name"));
      tableName = sharedPreferences.getString("table_name");
      tableID = sharedPreferences.getString("table_id");
      sessionID = sharedPreferences.getString("session_id");
      restaurantID = sharedPreferences.getString("restaurant_id");
      notifyListeners();
    }
  }
}
