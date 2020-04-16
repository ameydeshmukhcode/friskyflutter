import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends ChangeNotifier {
  bool profileSetupComplete = false;
  String name, bio, imageUrl;

  updateProfileSetupStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    profileSetupComplete = sharedPreferences.getBool("profile_setup_complete");
    if (profileSetupComplete == null || profileSetupComplete == false) {
      profileSetupComplete = false;
      await sharedPreferences.remove("u_name");
      await sharedPreferences.remove("u_bio");
      await sharedPreferences.remove("u_image");
      notifyListeners();
    } else {
      profileSetupComplete = true;
      name = (sharedPreferences.getString("u_name"));
      bio = sharedPreferences.getString("u_bio");
      imageUrl = sharedPreferences.getString("u_image");
      notifyListeners();
    }
  }
}