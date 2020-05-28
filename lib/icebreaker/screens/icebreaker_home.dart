import 'package:flutter/material.dart';
import 'package:friskyflutter/widgets/text_fa.dart';

class IceBreakerHome extends StatefulWidget {
  @override
  _IceBreakerHomeState createState() => _IceBreakerHomeState();
}

class _IceBreakerHomeState extends State<IceBreakerHome> {
  @override
  Widget build(BuildContext context) {
    var height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            //top padding
            height: MediaQuery.of(context).padding.top,
          ), // TOP Padding
          iceBreakerAppBar(height, width),
          Expanded(child: profilesWheel(height, width)),
          // Profiles Wheel Widget//
          bottomBar(height, width) // Bottom Bar
        ],
      ),
    );
  }

  Widget iceBreakerAppBar(dynamic height, dynamic width) => Container(
        height: height * 0.07,
        child: Placeholder(),
      );

  Widget profilesWheel(dynamic height, dynamic width) => Container(
        child: ListWheelScrollView(
          itemExtent: height * 0.83 * 0.8,
          diameterRatio: 4,
          onSelectedItemChanged: (item) {
            print(item.toString());
          },
          children: List.generate(10, (index) => profileWidget(height, width)),
        ),
      );

  Widget profileWidget(dynamic height, dynamic width) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: InkWell(
          onTap: () {
            print("index");
          },
          child: Container(
            color: Colors.grey,
            child: Image.network(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQbpw7pXkUdbAJWm0RBbJ7rxRkgSCT9GlqR9z_zwa447Cv9rWfi&usqp=CAU",
              fit: BoxFit.cover,
              height: height * 0.83 * 0.8,
              width: width - 24 * 2,
            ),
          ),
        ),
      );

  ///bottom Bar Widget
  Widget bottomBar(dynamic height, dynamic width) => Container(
        height: height * 0.1,
        child: Placeholder(),
      );
}
