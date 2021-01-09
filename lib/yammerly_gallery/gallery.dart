import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:techstagram/yammerly_gallery/file.dart';
import 'package:storage_path/storage_path.dart';

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
    var imagePath = await StoragePath.imagesPath;
    var images = jsonDecode(imagePath) as List;
    files = images.map<FileModel>((e) => FileModel.fromJson(e)).toList();
    if (files != null && files.length > 0)
      setState(() {
        selectedModel = files[0];
        image = files[0].files[0];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Next',
                    style: TextStyle(color: Colors.blue),
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
            selectedModel == null && selectedModel.files.length < 1
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
    return files
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
