import 'package:flutter/widgets.dart';

class FAText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;

  FAText(this.text, this.fontSize, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontFamily: "Varela", fontSize: fontSize, color: color),
    );
  }
}
