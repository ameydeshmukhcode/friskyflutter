import 'dart:core';

class MenuCategory {
  String id;
  String name;
  MenuCategory(String id, String name) {
    this.id = id;
    this.name = name;
  }
  String getId() {
    return id;
  }

  String getName() {
    return name;
  }
}
