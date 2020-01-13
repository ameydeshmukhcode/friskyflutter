import 'package:flutter/foundation.dart';
import 'package:friskyflutter/structures/menu_item.dart';

class Cart extends ChangeNotifier {
  List<MenuItem> cartList = new List();
  String _name = "";
  int _cartTotal = 0;
  int _totalItems = 0;

  String get itemName => _name;
  int get total => _cartTotal;
  int get itemCount => _totalItems;

  String getCount(MenuItem menuItem) {
    return cartList[getIndex(menuItem)].count.toString();
  }

  _countTotal() {
    _cartTotal = 0;
    for (int i = 0; i < cartList.length; i++) {
      _cartTotal = _cartTotal + (cartList[i].price * cartList[i].count);
    }
  }

  clearList() {
    cartList.removeRange(0, cartList.length);
    notifyListeners();
  }

  int getIndex(MenuItem menuItem) {
    return cartList.indexOf(menuItem);
  }

  void addToCart(MenuItem menuItem) {
    if (!cartList.contains(menuItem)) {
      cartList.add(menuItem);
      cartList[getIndex(menuItem)].incrementCount();
      _countTotal();
      _totalItems++;
      notifyListeners();
    } else {
      cartList[getIndex(menuItem)].incrementCount();
      _countTotal();
      _totalItems++;
      notifyListeners();
    }
  }

  void removeFromCart(MenuItem menuItem) {
    print("remov item count " + menuItem.count.toString());
    if (cartList[getIndex(menuItem)].count == 1) {
      cartList[getIndex(menuItem)].decrementCount();
      cartList.removeAt(getIndex(menuItem));
      print("item removed succesfully");
      _totalItems--;
      _countTotal();
      notifyListeners();
    } else {
      if (cartList[getIndex(menuItem)].count > 0) {
        cartList[getIndex(menuItem)].decrementCount();
        _countTotal();
        _totalItems--;
        notifyListeners();
      } else {
        print("Itam Count Zero Order Something");
        _countTotal();
        notifyListeners();
      }
    }
  }
}
