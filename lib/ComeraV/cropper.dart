import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

//void main() => runApp(MyApp());


class CropperPage extends StatefulWidget {

  File file;
  int cam;
  CropperPage({this.file,this.cam});
  @override
  _CropperPageState createState() => _CropperPageState(file: file,cam: cam);
}

class _CropperPageState extends State<CropperPage> {
  File file;
  bool _inProcess = false;
  int cam;
  File selectedFile;

  _CropperPageState({this.file,this.cam});

  // Widget getImageWidget() {
  //   if (_selectedFile != null) {
  //     return Image.file(
  //       _selectedFile,
  //       width: 250,
  //       height: 250,
  //       fit: BoxFit.cover,
  //     );
  //   } else {
  //     return Image.asset(
  //       "assets/placeholder.jpg",
  //       width: 250,
  //       height: 250,
  //       fit: BoxFit.cover,
  //     );
  //   }
  // }

  getImage() async {
    this.setState((){
      _inProcess = true;
    });
    //File image = await ImagePicker.pickImage(source: source);
    if(file != null){
      File cropped = await ImageCropper.cropImage(
          sourcePath: file.path,
          aspectRatio: CropAspectRatio(
              ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.deepOrange,
            toolbarTitle: "RPS Cropper",
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          )
      );

      this.setState((){
        selectedFile = cropped;
        _inProcess = false;
      });
    } else {
      this.setState((){
        _inProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getImage(),
        // body: Stack(
        //   children: <Widget>[
        //     Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: <Widget>[
        //         getImageWidget(),
        //         Row(
        //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //           children: <Widget>[
        //             MaterialButton(
        //                 color: Colors.green,
        //                 child: Text(
        //                   "Camera",
        //                   style: TextStyle(color: Colors.white),
        //                 ),
        //                 onPressed: () {
        //                   getImage(ImageSource.camera);
        //                 }),
        //             MaterialButton(
        //                 color: Colors.deepOrange,
        //                 child: Text(
        //                   "Device",
        //                   style: TextStyle(color: Colors.white),
        //                 ),
        //                 onPressed: () {
        //                   getImage(ImageSource.gallery);
        //                 })
        //           ],
        //         )
        //       ],
        //     ),
        //     (_inProcess)?Container(
        //       color: Colors.white,
        //       height: MediaQuery.of(context).size.height * 0.95,
        //       child: Center(
        //         child: CircularProgressIndicator(),
        //       ),
        //     ):Center()
        //   ],
        // )
    );
  }
}
