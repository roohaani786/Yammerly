import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeGenerator extends StatefulWidget {
  final String displayName;
  QrCodeGenerator(this.displayName);

  @override
  _QrCodeGeneratorState createState() => _QrCodeGeneratorState(displayName);
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  final String displayName;
  _QrCodeGeneratorState(this.displayName);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Your Qr Code", style: TextStyle(color: Colors.deepPurple)),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          child:
          (displayName!=null)
              ?Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height*0.1),
              QrImage(
                data: displayName,
                // backgroundColor: Colors.deepPurple,
                // foregroundColor: Colors.white,
                size: 200.0,
              ),
              SizedBox(height: MediaQuery.of(context).size.height*0.1),
              Text(
                displayName,
                style: TextStyle(color: Colors.deepPurple,fontSize: 20),
              )
            ],
          )
              :Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
