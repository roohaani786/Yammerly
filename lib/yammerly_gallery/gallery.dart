import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:techstagram/resources/uploadimage.dart';
import 'package:techstagram/yammerly_gallery/file.dart';
import 'package:storage_path/storage_path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery/image_gallery.dart';
import 'dart:async';
import 'dart:collection';

class gallery extends StatefulWidget {
  gallery({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _galleryState createState() => _galleryState();
}

class _galleryState extends State<gallery> {
  Map<dynamic, dynamic> allImageInfo = new HashMap();
  List allImage = new List();
  List allNameList = new List();

  List<FileModel> files;
  FileModel selectedModel;
  String image;
  @override
  void initState() {
    super.initState();
    //getImagesPath();
    loadImageList();
  }

  Future<void> loadImageList() async {
    Map<dynamic, dynamic> allImageTemp;
    allImageTemp = await FlutterGallaryPlugin.getAllImages;
    print(" call $allImageTemp.length");

    setState(() {
      this.allImage = allImageTemp['URIList'] as List;
      this.allNameList = allImageTemp['DISPLAY_NAME'] as List;
    });
  }

  getImagesPath() async {
    if (StoragePath.imagesPath == null) {
      return CircularProgressIndicator();
    }
    var imagePath = await StoragePath.imagesPath;
    var images = jsonDecode(imagePath) as List;
    files = images.map<FileModel>((e) => FileModel.fromJson(e)).toList();
    if (files != null && files.length > 0) {
      setState(() {
        selectedModel = files[0];
        image = files[0].files[0];
      });
    } else {
      return CircularProgressIndicator();
    }
  }

  int selectedIndex = 0;
  File selectedfile;
  bool _inProcess = false;

  getImage(File file) async {
    print("aa gayaaaa");
    //if(selectedfile ==  null){
    print("null h");
    this.setState(() {
      _inProcess = true;
    });
    //File image = await ImagePicker.pickImage(source: source);
    if (file != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: file.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 100,
          maxWidth: 700,
          maxHeight: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.white,
            toolbarTitle: "Yammerly Cropper",
            activeControlsWidgetColor: Colors.purple,
            toolbarWidgetColor: Colors.deepPurple,
            statusBarColor: Colors.purple,
            backgroundColor: Colors.white,
            showCropGrid: false,
            dimmedLayerColor: Colors.black54,
          ));
      this.setState(() {
        selectedfile = cropped;
        _inProcess = false;
      });
      if (selectedfile != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UploadImage(
                  file: selectedfile, shared: false, isVideo: false)),
        );
        setState(() {
          selectedfile == null;
        });
      }
    }
    //}
    // else{
    //   print("hu");
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) =>
    //         UploadImage(file: File(image),
    //           shared: false,)),
    //   );
    //   setState(() {
    //     selectedfile == null;
    //   });
    // }
  }

  //var status = Permission.gallery.status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.clear)),
                      SizedBox(width: 10),
                      // DropdownButtonHideUnderline(
                      //     child: DropdownButton<FileModel>(
                      //       items: getItems(),
                      //       onChanged: (FileModel d) {
                      //         assert(d.files.length > 0);
                      //         image = d.files[0];
                      //         setState(() {
                      //           selectedModel = d;
                      //         });
                      //       },
                      //       value: selectedModel,
                      //     ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 80.0,
                    height: 15.0,
                    child: MaterialButton(
                      onPressed: () => getImage(File(allImage[selectedIndex])),
                      child: Text(
                        'Next',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                )
              ],
            ),
            Divider(),
            Container(
                height: MediaQuery.of(context).size.height * 0.45,
                child: allImage != null
                    ? Image.file(File(allImage[selectedIndex]),
                        height: MediaQuery.of(context).size.height * 0.45,
                        width: MediaQuery.of(context).size.width)
                    : Container()),
            Divider(),
            (allImage == null)
                ? CircularProgressIndicator()
                : Container(
                    height: MediaQuery.of(context).size.height * 0.38,
                    child: GridView.extent(
                        maxCrossAxisExtent: 150.0,
                        // padding: const EdgeInsets.all(4.0),
                        mainAxisSpacing: 1.0,
                        crossAxisSpacing: 1.0,
                        children: _buildGridTileList(allImage.length))
                    //   child: GridView.builder(
                    //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //           crossAxisCount: 4,
                    //           crossAxisSpacing: 4,
                    //           mainAxisSpacing: 4),
                    //       itemCount: allImage.length,
                    //       itemBuilder: (_, i) {
                    //         return GestureDetector(
                    //           child: Image.file(
                    //             File(allImage[i].toString()),
                    //             fit: BoxFit.cover,
                    //           ),
                    //           onTap: () {
                    //             setState(() {
                    //             });
                    //           },
                    //         );
                    //       },
                    // )
                    )
          ],
        ),
      ),
    );
  }

  List<Container> _buildGridTileList(int count) {
    return List<Container>.generate(
        count,
        (int index) => Container(
                child: new Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Image.file(
                      File(allImage[index].toString()),
                      width: 110.0,
                      height: 110.0,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            )));
  }

  List<DropdownMenuItem> getItems() {
    return (files == null)
        ? null
        : files
                .map((e) => DropdownMenuItem(
                      child: Text(
                        e.folder,
                        style: TextStyle(color: Colors.black),
                      ),
                      value: e,
                    ))
                .toList() ??
            [];
  }
}
