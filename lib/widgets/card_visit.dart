import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:friskyflutter/screens/visit_summary.dart';

import '../frisky_colors.dart';

class VisitWidget extends StatelessWidget {
  final String sessionID,
      restaurantID,
      restaurantName,
      restaurantImage,
      totalAmount;
  final Timestamp endTime;

  VisitWidget(this.sessionID, this.restaurantID, this.restaurantName,
      this.restaurantImage, this.endTime, this.totalAmount);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: Card(
          margin: EdgeInsets.all(0),
          elevation: 2,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VisitSummary(
                          sessionID: sessionID,
                          restaurantID: restaurantID,
                          restaurantName: restaurantName,
                        )),
              );
            },
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Image.network(restaurantImage, fit: BoxFit.cover),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          restaurantName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(
                              color: FriskyColor().colorTextLight,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: "museoM"),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                        ),
                        Text(
                          "Visited On ",
                          maxLines: 1,
                          style: TextStyle(
                              color: FriskyColor().colorTextLight,
                              fontSize: 12,
                              fontFamily: "museoS"),
                        ),
                        Text(
                          _getFormattedTimestamp(endTime),
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 12,
                              color: FriskyColor().colorTextLight,
                              fontWeight: FontWeight.bold,
                              fontFamily: "museoS"),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 4),
                        ),
                        Text(
                          "Total Amount",
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 12,
                              color: FriskyColor().colorTextLight,
                              fontFamily: "museoS"),
                        ),
                        Text(
                          "\u20B9 " + totalAmount,
                          style: TextStyle(
                              fontSize: 12,
                              color: FriskyColor().colorTextLight,
                              fontWeight: FontWeight.bold,
                              fontFamily: "museoS"),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  _getFormattedTimestamp(Timestamp timestamp) {
    return formatDate(
        timestamp.toDate(), [dd, ' ', M, ' ', yyyy, ' ', hh, ':', nn, '', am]);
  }
}
