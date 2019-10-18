import 'package:flutter/material.dart';

class DineTab extends StatefulWidget {
  @override
  _DineTabState createState() => _DineTabState();
}

class _DineTabState extends State<DineTab>
    with AutomaticKeepAliveClientMixin<DineTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
