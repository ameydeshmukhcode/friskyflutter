library com.frisky.icebreaker.core.structures;

import 'package:friskyflutter/structures/BaseItem.dart';
import 'package:friskyflutter/structures/DietType.dart';

class MenuItem extends BaseItem
{
  String description;
  String category;
  int price;
  bool available;
  DietType dietType;

  MenuItem(String id, String name, String description, String category, int price, bool available, DietType dietType)
  {
    this.id = id;
    this.name = name;
    this.description = description;
    this.category = category;
    this.price = price;
    this.available = available;
    this.dietType = dietType;
  }

  String getId()
  {
    return id;
  }

  String getName()
  {
    return name;
  }

  String getDescription()
  {
    return description;
  }

  String getCategory()
  {
    return category;
  }

  int getPrice()
  {
    return price;
  }

  bool getAvailable()
  {
    return available;
  }

  DietType getDietType()
  {
    return dietType;
  }

  int getCount()
  {
    return count;
  }

  void incrementCount()
  {
    ++count;
  }

  void decrementCount()
  {
    --count;
  }
}
