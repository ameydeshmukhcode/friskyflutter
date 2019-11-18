import 'package:flutter/material.dart';
import 'package:friskyflutter/provider_models/session.dart';
import 'package:friskyflutter/screens/dine_orders.dart';
import 'package:friskyflutter/screens/dine_tab_bill.dart';
import 'package:friskyflutter/screens/dine_tab_default.dart';
import 'package:provider/provider.dart';

class DineTab extends StatefulWidget {
  @override
  _DineTabState createState() => _DineTabState();
}

class _DineTabState extends State<DineTab> {
  @override
  Widget build(BuildContext context) {
    // ignore: missing_return
    return Scaffold(body: Consumer<Session>(builder: (context, Session, child) {
      if (!Session.isSessionActive) {
        return DineTabDefault();
      } else {
        if (Session.isBillRequested) {
          return DineTabBillRequested();
        } else {
          return DineTabActive();
        }
      }
    }));
  }
}
