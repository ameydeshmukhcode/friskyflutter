import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Session extends ChangeNotifier{
 bool isSessionActive = false;
 String restaurantName = " ";
 String tableName = " ";
 String tableID = " ";
 Future getStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isSessionActive = sharedPreferences.getBool("session_active");
    if(isSessionActive==null)
  {    isSessionActive=false;
  }
  else{
    print("SESSION = "+isSessionActive.toString());
    restaurantName = sharedPreferences.getString("resturant_name");
    tableName = sharedPreferences.getString("table_name");
    tableID = sharedPreferences.getString("table_id");
    notifyListeners();
  }
  }

}
