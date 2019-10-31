import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Session extends ChangeNotifier{
  // ignore: unused_field
 bool isSessionActive = false;
 Future getStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    isSessionActive = sharedPreferences.getBool("session_active");
    print("SESSION = "+isSessionActive.toString());
    notifyListeners();
  }

}
