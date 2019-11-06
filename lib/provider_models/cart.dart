import 'package:flutter/foundation.dart';
import 'package:friskyflutter/structures/menu_item.dart';

class Cart extends ChangeNotifier {
  List<MenuItem> cartList = new List();
  String _name = "";
  int _cartTotal = 0;
  String get itemName => _name;
  int get total => _cartTotal;
  String getCount(MenuItem menuItem) {
    return cartList[getIndex(menuItem)].getCount().toString();
  }

   countTotal()
   {
     _cartTotal = 0;
     for(int i = 0 ; i<cartList.length;i++){
       _cartTotal = _cartTotal + (cartList[i].getPrice() * cartList[i].getCount());
     }
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



 void clearCart(){
    for(int i=cartList.length-1;i>=0;i--)
      {
        cartList[i].count = 0;
        cartList.removeAt(i);
        print("inside clearCArt "+i.toString());
        printList();
      }
    notifyListeners();
  }

  int getIndex(MenuItem menuItem) {
    return cartList.indexOf(menuItem);
  }

  void addToCart(MenuItem menuItem) {
    if (!cartList.contains(menuItem)) {
      cartList.add(menuItem);
      cartList[getIndex(menuItem)].incrementCount();
      countTotal();
      notifyListeners();
    } else {
      cartList[getIndex(menuItem)].incrementCount();
      countTotal();
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
      countTotal();
      notifyListeners();
    } else {
      if (cartList[getIndex(menuItem)].getCount() > 0) {
        cartList[getIndex(menuItem)].decrementCount();
        countTotal();
        notifyListeners();
      } else {
        print("Itam Count Zero Order Something");
        countTotal();
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
