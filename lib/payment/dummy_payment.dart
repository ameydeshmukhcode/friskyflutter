import 'package:flutter/material.dart';
import 'package:friskyflutter/frisky_colors.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
class DummyPayment extends StatefulWidget {
  @override
  _DummyPaymentState createState() => _DummyPaymentState();
}

class _DummyPaymentState extends State<DummyPayment> {

  Razorpay razorpay;
  TextEditingController textEditingController = new TextEditingController();
  var Status;

  @override
  void initState() {
    super.initState();

    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }

  void openCheckout(){
    var options = {
      "key" : "rzp_test_RvFwNcl7w52DPJ",
      "amount" : num.parse(textEditingController.text)*100,
      "name" : "Frisky Test",
      "currency" : "INR",
      "description" : "Payment for Frisky TEST",
    };

    try{
      razorpay.open(options);
    }catch(e){
      print(e.toString());
    }

  }

  void handlerPaymentSuccess(PaymentSuccessResponse response){
    print("Payment success");

    Fluttertoast.showToast(
        msg: "Payment success",
        toastLength: Toast.LENGTH_LONG);
    setState(() {
      Status = response.toString();
    });

  }

  void handlerErrorFailure(PaymentFailureResponse response){

    PaymentFailureResponse failureResponse = response;
    print("Payment error");
    print(failureResponse.message);
    Fluttertoast.showToast(
        msg: "Payment Error",
        toastLength: Toast.LENGTH_LONG);
    setState(() {
      Status =failureResponse.message;
    });

  }

  void handlerExternalWallet(ExternalWalletResponse response){
    print("External Wallet");
    Fluttertoast.showToast(
        msg: "External Wallet",
        toastLength: Toast.LENGTH_LONG);
    setState(() {
      Status = response.toString();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
      (
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Frisky RazorPay TEST"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                  hintText: "amount to pay"
              ),
            ),
            SizedBox(height: 12,),
            RaisedButton(
             color: FriskyColor.colorPrimary,
              child: Text("Pay Now", style: TextStyle(
                  color: Colors.white
              ),),
              onPressed: (){
                openCheckout();
              },
            ),

            Text("PAYMENT STATUS\n"),
          ],
        ),
      ),
    );
  }
}