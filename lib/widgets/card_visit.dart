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
    return InkWell(
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
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
        height: 120,
        child: Row(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 1.25,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  restaurantImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
                child: Container(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      restaurantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                    ),
                    Text(
                      "Visited On ",
                      maxLines: 1,
                      style: TextStyle(
                          color: FriskyColor.colorTextLight,
                          fontSize: 12,
                          fontFamily: "museoS"),
                    ),
                    Text(
                      _getFormattedTimestamp(endTime),
                      maxLines: 1,
                      style: TextStyle(fontSize: 16),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                    ),
                    Text(
                      "Total Amount",
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 12,
                          color: FriskyColor.colorTextLight,
                          fontFamily: "museoS"),
                    ),
                    Text(
                      "\u20B9 " + totalAmount,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  _getFormattedTimestamp(Timestamp timestamp) {
    return formatDate(
        timestamp.toDate(), [dd, ' ', M, ' ', yyyy, ' ', hh, ':', nn, '', am]);
  }
}
