import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:techstagram/ui/Otheruser/other_user.dart';

class QRScreen extends StatefulWidget {
  QRScreen(this.curUsrName);
  final String curUsrName;
  @override
  State<StatefulWidget> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> {
  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  User currUser = FirebaseAuth.instance.currentUser;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: getUserInfo(result),
          builder: (context, snap) {
            if (snap.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: NetworkImage(snap.data[1].toString()),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Text(result.code),
                    ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.deepPurple)),
                        onPressed: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => OtherUserProfile(
                                      displayName: result.code.toString(),
                                      displayNamecurrentUser: widget.curUsrName,
                                      uid: currUser.uid,
                                      uidX: snap.data[0].toString(),
                                    ))),
                        child: Text('View Profile'))
                  ],
                ),
              );
            } else
              return Column(
                children: <Widget>[
                  Expanded(flex: 5, child: _buildQrView(context)),
                  Expanded(
                    flex: 1,
                    child: FittedBox(
                        fit: BoxFit.contain,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            if (result != null)
                              Text(
                                  'Barcode Type: ${describeEnum(result.format)}   Data: ${result.code}')
                            else
                              Text('Scan a code'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(8),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.deepPurple)),
                                      onPressed: () async {
                                        await controller?.toggleFlash();
                                        setState(() {});
                                      },
                                      child: FutureBuilder(
                                        future: controller?.getFlashStatus(),
                                        builder: (context, snapshot) {
                                          return Text(
                                              'Flash: ${snapshot.data}');
                                        },
                                      )),
                                ),
                                Container(
                                  margin: EdgeInsets.all(8),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.deepPurple)),
                                      onPressed: () async {
                                        await controller?.flipCamera();
                                        setState(() {});
                                      },
                                      child: FutureBuilder(
                                        future: controller?.getCameraInfo(),
                                        builder: (context, snapshot) {
                                          if (snapshot.data != null) {
                                            return Text(
                                                'Camera facing ${describeEnum(snapshot.data)}');
                                          } else {
                                            return Text('loading');
                                          }
                                        },
                                      )),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.all(8),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.deepPurple)),
                                    onPressed: () async {
                                      await controller?.pauseCamera();
                                    },
                                    child: Text('Pause',
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.all(8),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.deepPurple)),
                                    onPressed: () async {
                                      await controller?.resumeCamera();
                                    },
                                    child: Text('Resume',
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                )
                              ],
                            ),
                          ],
                        )),
                  )
                ],
              );
          }),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  Future<dynamic> getUserInfo(Barcode res) async {
    String id;
    String pic;
    if (res == null) return null;

    String userName = res.code.toString();
    await FirebaseFirestore.instance
        .collection("users")
        .where("displayName", isEqualTo: userName)
        .get()
        .then((value) {
      value.docs.forEach((result) {
        id = result.id;
        pic = result.data()['photoURL'];
      });
    });
    return [id, pic];
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
