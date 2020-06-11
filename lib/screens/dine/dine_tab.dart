import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dine_tab_active.dart';
import 'dine_tab_bill_requested.dart';
import 'dine_tab_default.dart';
import '../../provider_models/session.dart';

class DineTab extends StatefulWidget {
  @override
  _DineTabState createState() => _DineTabState();
}

class _DineTabState extends State<DineTab> {
  @override
  Widget build(BuildContext context) {
    // ignore: missing_return
    return Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<Session>(builder: (context, session, child) {
          if (!session.isSessionActive) {
            return DineTabDefault();
          } else {
            if (session.isBillRequested) {
              return DineTabBillRequested();
            } else {
              return DineTabActive();
            }
          }
        }));
  }
}
