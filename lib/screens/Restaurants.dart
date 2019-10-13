import 'package:flutter/material.dart';
import 'package:friskyflutter/frisky_colors.dart';
class RestautantsTab extends StatefulWidget {
  @override
  _RestautantsTabState createState() => _RestautantsTabState();
}

class _RestautantsTabState extends State<RestautantsTab> with AutomaticKeepAliveClientMixin<RestautantsTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FriskyColor().white,

    );
  }

  @override
  bool get wantKeepAlive => true;
}
