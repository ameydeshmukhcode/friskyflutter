import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RestaurantDetails extends StatelessWidget {
  final String image;
  final String name;
  final String address;
  final String cuisine;

  RestaurantDetails(this.image, this.name, this.address, this.cuisine);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          child: Image.network(
            image,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        name,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Text(
                        '4.5',
                        style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                  ],
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
                Text(
                  address,
                  maxLines: 1,
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  cuisine,
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ))
      ],
    );
  }
}
