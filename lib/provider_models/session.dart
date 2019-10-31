import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Session extends ChangeNotifier{
 bool isSessionActive = false;
 Future getStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isSessionActive = sharedPreferences.getBool("session_active");
    if(isSessionActive==null)
      isSessionActive=false;
    print("SESSION = "+isSessionActive.toString());
    notifyListeners();
  }

}
