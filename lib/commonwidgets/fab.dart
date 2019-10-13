import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../frisky_colors.dart';

Widget FriskyFab() {
  return FloatingActionButton.extended(
    onPressed: () {},
    icon: Icon(MdiIcons.qrcode),
    label: Text("Scan QR Code"),
    backgroundColor: FriskyColor().colorCustom,
  );
}
