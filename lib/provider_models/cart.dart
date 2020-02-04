import 'package:flutter/foundation.dart';
import 'package:friskyflutter/structures/menu_item.dart';

class Cart extends ChangeNotifier {

  // This is sent to placeOrder
  Map<String, int> orderList = {};

  // Using this for UI
  List<MenuItem> cartList = [];

  int _cartTotal = 0;
  int _totalItems = 0;

  int get total => _cartTotal;
  int get itemCount => _totalItems;

  int getCount(MenuItem menuItem) {
    return cartList[getIndex(menuItem)].count;
  }

  clearList() {
    cartList.removeRange(0, cartList.length);
    orderList.clear();
    _cartTotal = 0;
    _totalItems = 0;
    notifyListeners();
  }

  int getIndex(MenuItem menuItem) {
    return cartList.indexOf(menuItem);
  }

  void addToCart(MenuItem menuItem) {
    if (!cartList.contains(menuItem)) {
      cartList.add(menuItem);
      cartList[getIndex(menuItem)].incrementCount();
      orderList[menuItem.id] = 1;
      _cartTotal += menuItem.price;
      _totalItems++;
      notifyListeners();
    } else {
      cartList[getIndex(menuItem)].incrementCount();
      orderList[menuItem.id]++;
      _cartTotal += menuItem.price;
      _totalItems++;
      notifyListeners();
    }
  }

  void removeFromCart(MenuItem menuItem) {
    if (cartList[getIndex(menuItem)].count == 1) {
      cartList[getIndex(menuItem)].decrementCount();
      cartList.removeAt(getIndex(menuItem));
      orderList[menuItem.id]--;
      orderList.remove(menuItem.id);
      _totalItems--;
      _cartTotal -= menuItem.price;
      notifyListeners();
    } else {
      if (cartList[getIndex(menuItem)].count > 0) {
        cartList[getIndex(menuItem)].decrementCount();
        orderList[menuItem.id]--;
        _cartTotal -= menuItem.price;
        _totalItems--;
        notifyListeners();
      } else {
        _cartTotal -= menuItem.price;
        notifyListeners();
      }
    }
  }
}
