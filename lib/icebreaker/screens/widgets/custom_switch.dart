import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSwitch extends StatefulWidget {
  final double size;
  CustomSwitch({Key key, this.size}) : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  double animationValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    animationValue = widget.size;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          animationValue = (animationValue == 0) ? widget.size * 2 / 2 : 0;
          setState(() {});
        },
        child: Stack(children: [
          Container(
            height: widget.size,
            width: widget.size * 2,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xFFF0F0F0)),
          ),
          Positioned(
            right: 0,
            child: Container(
              height: widget.size,
              width: widget.size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //    color: Colors.pink
              ),
            ),
          ),
          Positioned(
            left: 0,
            child: Container(
              height: widget.size,
              width: widget.size,
              child: SvgPicture.asset(
                'images/icons/colored-tools-and-utensils.svg',
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //    color: Colors.indigo,
              ),
            ),
          ),
          AnimatedPositioned(
            height: widget.size,
            width: widget.size * 2 / 2,
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Container(
                child: SvgPicture.asset(
                  (animationValue == 0)
                      ? 'images/icons/tools-and-utensils-colored.svg'
                      : 'images/icons/colored-tools-and-utensils.svg',
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.white,
                ),
              ),
            ),
            duration: Duration(seconds: 1),
            curve: Curves.ease,
            right: animationValue,
          ),
        ]),
      ),
    );
  }
}
