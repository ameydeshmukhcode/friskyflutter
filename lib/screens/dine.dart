import 'package:flutter/material.dart';
import 'package:friskyflutter/frisky_colors.dart';

class DineTab extends StatefulWidget {
  @override
  _DineTabState createState() => _DineTabState();
}

class _DineTabState extends State<DineTab>
    with AutomaticKeepAliveClientMixin<DineTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FriskyColor().white,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
