import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:friskyflutter/size_config.dart';

class DetailsPage extends StatefulWidget {
  final DocumentSnapshot resturant;

  const DetailsPage({this.resturant});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
//  getImages() {
//    StorageReference storageReference = FirebaseStorage.instance
//        .ref()
//        .child("restaurants/" + widget.resturant.documentID + "/menu");
//    StorageFileDownloadTask downloadTask = storageReference.getData(10000).then()
//  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            //  backgroundColor: Colors.blue,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.resturant.data["image"],
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
                        Text(
                          widget.resturant.data['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: SizeConfig.safeBlockVertical * 4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.resturant.data['address'],
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockVertical * 2.2),
                        ),
                        Text(
                          widget.resturant.data['cuisine'][0] +
                              ", " +
                              widget.resturant.data['cuisine'][1],
                          style: TextStyle(
                              fontSize: SizeConfig.safeBlockVertical * 2.2),
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
        child: Container(
          height: SizeConfig.safeBlockVertical * 8.5,
          width: SizeConfig.safeBlockHorizontal * 100,
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
                        fontSize: SizeConfig.safeBlockVertical * 2.5,
                      ),
                      textAlign: TextAlign.center,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}