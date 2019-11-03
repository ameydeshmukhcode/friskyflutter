import 'package:flutter/foundation.dart';
import 'package:friskyflutter/structures/MenuItem.dart';

class Cart extends ChangeNotifier {
  List<MenuItem> cartList = new List();
  String _name = "";

  String get itemName => _name;

  String getCount(MenuItem menuItem) {
    return cartList[getIndex(menuItem)].getCount().toString();
  }

  clearList()
  {
    print("list before clear");

    printList();
    cartList.removeRange(0, cartList.length);
    print("list after clear");
    printList();
    notifyListeners();
  }

  int getIndex(MenuItem menuItem) {
    return cartList.indexOf(menuItem);
  }

  void addToCart(MenuItem menuItem) {
    if (!cartList.contains(menuItem)) {
      cartList.add(menuItem);
      cartList[getIndex(menuItem)].incrementCount();
      notifyListeners();
    } else {
      cartList[getIndex(menuItem)].incrementCount();
      notifyListeners();
    }
  //  printMenuList();
    printList();
    printMenuList();

  }

  void removeFromCart(MenuItem menuItem) {
    print("remov item count " + menuItem.getCount().toString());
    if (cartList[getIndex(menuItem)].getCount() == 1) {
      cartList[getIndex(menuItem)].decrementCount();
      cartList.removeAt(getIndex(menuItem));
      print("item removed succesfully");
      notifyListeners();
    } else {
      if (cartList[getIndex(menuItem)].getCount() > 0) {
        cartList[getIndex(menuItem)].decrementCount();
        notifyListeners();
      } else {
        print("Itam Count Zero Order Something");
        notifyListeners();
      }
    }
   // printMenuList();
    printList();
    printMenuList();
  }

  void printMenuList() {
    print("ITEM NAME            Quantity");
    cartList.forEach((f) {
      print(f.name + "         " + f.getCount().toString());
    });
  }

  printList(){
    if(cartList.isEmpty)
      print("List IS EMPTY");
    print(cartList.toString());

  }
}
