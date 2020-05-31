import 'package:flutter/foundation.dart';

import '../structures/menu_item.dart';

class Cart extends ChangeNotifier {

  // This is sent to placeOrder
  Map<String, int> orderList = {};

  // Using this for UI
  List<MenuItem> cartList = [];

  int _cartTotal = 0;
  int _totalItems = 0;

  int get total => _cartTotal;
  int get itemCount => _totalItems;

  // Used to show current count in menu and cart
  int getItemCount(MenuItem menuItem) {
    return cartList[_getIndex(menuItem)].count;
  }

  // clears cart and resets values
  clearCartAndOrders() {
    cartList.removeRange(0, cartList.length);
    orderList.clear();
    _cartTotal = 0;
    _totalItems = 0;
    notifyListeners();
  }

  void addToCart(MenuItem menuItem) {
    if (!cartList.contains(menuItem)) {

      // Add new item to cart
      cartList.add(menuItem);
      cartList[_getIndex(menuItem)].incrementCount();
      orderList[menuItem.id] = 1;
      _cartTotal += menuItem.price;
      _totalItems++;
      notifyListeners();
    } else {

      // Or increment count of item in cart
      cartList[_getIndex(menuItem)].incrementCount();
      orderList[menuItem.id]++;
      _cartTotal += menuItem.price;
      _totalItems++;
      notifyListeners();
    }
  }

  void removeFromCart(MenuItem menuItem) {
    if (cartList[_getIndex(menuItem)].count == 1) {

      // Remove item from cart when count is 1
      cartList[_getIndex(menuItem)].decrementCount();
      cartList.removeAt(_getIndex(menuItem));
      orderList[menuItem.id]--;
      orderList.remove(menuItem.id);
      _totalItems--;
      _cartTotal -= menuItem.price;
      notifyListeners();
    } else {

      // Or just decrement count by 1
      if (cartList[_getIndex(menuItem)].count > 0) {
        cartList[_getIndex(menuItem)].decrementCount();
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

  int _getIndex(MenuItem menuItem) {
    return cartList.indexOf(menuItem);
  }
}
