import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:friskyflutter/frisky_colors.dart';

import 'text_fa.dart';

class RestaurantCard extends StatelessWidget {
  final String image, name, address, cuisine;

  RestaurantCard(this.image, this.name, this.address, this.cuisine);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
      height: 120,
      child: Row(
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.25,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
              child: Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontFamily: "Varela",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        address,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Varela",
                        ),
                      ),
                      FAText(cuisine, 14, FriskyColor.colorTextLight),
                    ],
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.green),
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Text(
                          "4.5",
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Varela",
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ))
        ],
      ),
    );
  }
}
