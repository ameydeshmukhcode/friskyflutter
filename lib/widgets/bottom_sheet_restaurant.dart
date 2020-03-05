import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:friskyflutter/widgets/text_fa.dart';

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
                        style: TextStyle(
                            fontFamily: "Varela",
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                      child: Text(
                        '4.5',
                        style: TextStyle(
                            fontFamily: "Varela",
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
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
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Varela",
                  ),
                ),
                FAText(cuisine, 20, FriskyColor.colorTextLight),
              ],
            ))
      ],
    );
  }
}
