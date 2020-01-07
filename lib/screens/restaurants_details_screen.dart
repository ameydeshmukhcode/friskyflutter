import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  final DocumentSnapshot restaurant;

  const DetailsPage({this.restaurant});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            //  backgroundColor: Colors.blue,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.restaurant.data["image"],
                fit: BoxFit.cover,
              ),
            ),
            pinned: true,
            expandedHeight: 150,
          ),
          SliverFillRemaining(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                widget.restaurant.data['name'],
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(4),
                              child: Text(
                                '4.5',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            )
                          ],
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                        Text(
                          widget.restaurant.data['address'],
                          maxLines: 1,
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          widget.restaurant.data['cuisine'][0] +
                              ", " +
                              widget.restaurant.data['cuisine'][1],
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                _menuImages()
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _menuImages() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        elevation: 2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Menu",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
