import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSwitch extends StatefulWidget {
  final double size;
  final bool value;
  CustomSwitch({Key key, this.size, this.value}) : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  double animationValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    animationValue = !widget.value ? 0.0 : widget.size - widget.size * 0.2;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          animationValue =
              (animationValue == 0) ? widget.size - widget.size * 0.2 : 0;
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
            left: 0,
            child: Container(
              height: widget.size,
              width: widget.size,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  'images/icons/tools_and_utensils_grey.svg',
                ),
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //    color: Colors.indigo,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              height: widget.size,
              width: widget.size,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: SvgPicture.asset(
                  'images/icons/logo_grey.svg',
                ),
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                //    color: Colors.pink
              ),
            ),
          ),
          AnimatedPositioned(
            height: widget.size,
            width: widget.size * 1.2,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SvgPicture.asset(
                    (animationValue == 0)
                        ? 'images/icons/tools_and_utensils_color.svg'
                        : 'images/icons/logo_color.svg',
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.grey)],
                  color: Colors.white,
                ),
              ),
            ),
            duration: Duration(milliseconds: 300),
            curve: Curves.ease,
            left: animationValue,
          ),
        ]),
      ),
    );
  }
}
