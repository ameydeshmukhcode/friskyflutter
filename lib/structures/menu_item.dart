library com.frisky.icebreaker.core.structures;

import 'package:friskyflutter/structures/base_item.dart';
import 'package:friskyflutter/structures/diet_type.dart';

class MenuItem extends BaseItem {
  String description;
  String category;
  int price;
  bool available;
  DietType dietType;

  MenuItem(id, name, this.description, this.category, this.price,
      this.available, this.dietType) {
    this.id = id;
    this.name = name;
  }

  void incrementCount() {
    ++count;
  }

  void decrementCount() {
    --count;
  }
}
