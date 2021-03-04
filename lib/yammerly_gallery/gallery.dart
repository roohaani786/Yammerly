import 'dart:convert';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:techstagram/resources/uploadimage.dart';
import 'package:techstagram/yammerly_gallery/file.dart';
import 'package:storage_path/storage_path.dart';
import 'package:permission_handler/permission_handler.dart';

class gallery extends StatefulWidget {
  gallery({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _galleryState createState() => _galleryState();
}

class _galleryState extends State<gallery> {
  List<FileModel> files;
  FileModel selectedModel;
  String image;
  @override
  void initState() {
    super.initState();
    getImagesPath();
  }

  getImagesPath() async {
    if(StoragePath.imagesPath == null){
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
    }
    else{
      return CircularProgressIndicator();
    }
  }

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
          aspectRatio: CropAspectRatio(
              ratioX: 1, ratioY: 1),
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
          )
      );
      this.setState(() {
        selectedfile = cropped;
        _inProcess = false;
      });
      if(selectedfile!= null){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              UploadImage(file: selectedfile,
                shared: false,isVideo:false)),
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
                  width: MediaQuery.of(context).size.width*0.75,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                          onTap : () => Navigator.pop(context),
                          child: Icon(Icons.clear)),
                      SizedBox(width: 10),
                      DropdownButtonHideUnderline(
                          child: DropdownButton<FileModel>(
                            items: getItems(),
                            onChanged: (FileModel d) {
                              assert(d.files.length > 0);
                              image = d.files[0];
                              setState(() {
                                selectedModel = d;
                              });
                            },
                            value: selectedModel,
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 80.0,
                    height: 15.0,
                    child: FlatButton(
                      onPressed: () => getImage(File(image)),
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
                child: image != null
                    ? Image.file(File(image),
                    height: MediaQuery.of(context).size.height * 0.45,
                    width: MediaQuery.of(context).size.width)
                    : Container()),
            Divider(),
            (files == null)?CircularProgressIndicator()
                :selectedModel == null
                ? Container()
                : Container(
              height: MediaQuery.of(context).size.height * 0.38,
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4),
                  itemBuilder: (_, i) {
                    var file = selectedModel.files[i];
                    return GestureDetector(
                      child: Image.file(
                        File(file),
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        setState(() {
                          image = file;
                        });
                      },
                    );
                  },
                  itemCount: selectedModel.files.length),
            )
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem> getItems() {
    return (files == null)?null:files
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