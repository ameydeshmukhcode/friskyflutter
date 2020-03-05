import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:friskyflutter/screens/visit_summary.dart';
import 'package:friskyflutter/widgets/text_fa.dart';

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
        padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
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
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
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
                          fontFamily: "Varela",
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: FriskyColor.colorTextDark),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                    ),
                    FAText("Visited On ", 12, FriskyColor.colorTextLight),
                    FAText(_getFormattedTimestamp(endTime), 14,
                        FriskyColor.colorTextLight),
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                    ),
                    FAText("Total Amount", 12, FriskyColor.colorTextLight),
                    FAText("\u20B9 " + totalAmount, 14,
                        FriskyColor.colorTextLight),
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
        timestamp.toDate(), [dd, ' ', M, ' ', yyyy, ' ', hh, ':', nn, ' ', am]);
  }
}
