import 'package:cloud_firestore/cloud_firestore.dart';

class Visit {
  String sessionID;
  String restaurantID;
  String restaurantImage;
  String restaurantName;
  Timestamp endTime;
  String totalAmount;

  Visit(this.sessionID, this.restaurantID, this.restaurantImage,
      this.restaurantName, this.endTime, this.totalAmount);
}
