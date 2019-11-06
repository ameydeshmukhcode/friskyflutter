
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
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


}

