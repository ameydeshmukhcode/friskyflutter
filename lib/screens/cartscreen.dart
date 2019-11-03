import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:friskyflutter/provider_models/cart.dart';

class CartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: Provider.of<Cart>(context, listen: true).cartList.length,
          itemBuilder: (context, index) {
            return Container(
                child: ListTile(
              title: Text(Provider.of<Cart>(context, listen: true)
                  .cartList[index]
                  .getName()),
              subtitle: Text(Provider.of<Cart>(context, listen: true)
                  .cartList[index]
                  .getCount()
                  .toString()),
              trailing: FlatButton(
                  onPressed: () {
                    Provider.of<Cart>(context, listen: false)
                        .addToCart(Provider.of<Cart>(context, listen: false).cartList[index]);
                  },
                  child: Text("+")),

                  leading: FlatButton(
                      onPressed: () {
                        Provider.of<Cart>(context, listen: false)
                            .removeFromCart(Provider.of<Cart>(context, listen: false).cartList[index]);
                      },
                      child: Text("-")),
                ),

            );
          }),
    );
  }
}
