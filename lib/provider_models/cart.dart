import 'package:flutter/foundation.dart';
import 'package:friskyflutter/structures/MenuItem.dart';
class Cart extends ChangeNotifier
{
  List<MenuItem> cartList = new List();
   String _name = ""    ;
  String  get itemName  =>_name;
  String getCount(MenuItem menuItem){


    return menuItem.getCount().toString();

  }
   void printFunction(MenuItem menuItem ){
      addToCart(menuItem);
    }

    void addToCart(MenuItem menuItem){
      if(!cartList.contains(menuItem))
     { cartList.add(menuItem);
      menuItem.incrementCount();
      notifyListeners();
     }
      else
      {menuItem.incrementCount();}
      printMenuList();
      notifyListeners();
    }
    void removeFromCart(MenuItem menuItem){
       print("remov item count "+menuItem.getCount().toString());
        if(menuItem.getCount()==1)
         {
           menuItem.decrementCount();
           cartList.removeAt(cartList.indexOf(menuItem));
           print("item removed succesfully");
           notifyListeners();
         }
        else
       {
         if(menuItem.getCount()>0)
         {menuItem.decrementCount();
         notifyListeners();}
         else{
            print("Itam Count Zero Order Something");
            notifyListeners();
         }
       }
        printMenuList();
    }

     void printMenuList()
     {

       print("ITEM NAME    Quantity");
       cartList.forEach((f){
         print(f.name+" " +f.getCount().toString());

       });


     }

}