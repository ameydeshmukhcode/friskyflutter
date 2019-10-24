import 'package:flutter/material.dart';
import 'package:qrcode/qrcode.dart';
class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  QRCaptureController _captureController = QRCaptureController();

  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _captureController.onCapture((data) {

      showDialog(context: context, builder: (BuildContext context){


        return AlertDialog(

          title: Text("Start New Session ?"),
          content: Text("Start New Session to :\n lol\nlo\nlol"),
          actions: <Widget>[
            FlatButton(onPressed: (){}, child: Text("Cancle22")),
            FlatButton(onPressed: (){}, child: Text("Cancle")),
          ],
        );

      });

    });


  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Container(child: QRCaptureView(controller: _captureController)),
           // Container(color: Colors.orange.withOpacity(0.2),),
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildToolBar(),
            )
          ],
        ),
      ),
    );
  }
  Widget _buildToolBar() {
    return Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
    FlatButton(
    onPressed: () {
      _captureController.pause();
    },
    child: Text('pause'),
    ),
    FlatButton(
    onPressed: () {
    if (_isTorchOn) {
    _captureController.torchMode = CaptureTorchMode.off;
    } else {
    _captureController.torchMode = CaptureTorchMode.on;
    }
    _isTorchOn = !_isTorchOn;
    },
    child: Text('torch'),
    ),
    FlatButton(
    onPressed: () {
    _captureController.resume();
    },
    child: Text('resume'),
    ),
    ],
    );
  }



}
