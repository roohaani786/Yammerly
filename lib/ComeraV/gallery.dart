import 'dart:io';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/ComeraV/video_preview.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
//import 'package:techstagram/model/user.dart';
//import 'package:techstagram/models/user.dart';
//import 'package:techstagram/resources/auth.dart';
//import 'dart:io';

import 'package:techstagram/resources/uploadimage.dart';

class Gallery extends StatefulWidget {
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  String currentFilePath;





  @override
  void initState() {



    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.black,

        actions: [
          IconButton(
            icon: Icon(Icons.delete,color: Colors.white),
            onPressed: _deleteFile,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _getAllImages(),
        builder: (context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Container();
          }
          print('${snapshot.data.length} ${snapshot.data}');
          if (snapshot.data.length == 0) {
            return Center(
              child: Text('No images found.'),
            );
          }

          return PageView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (context, index) {
              currentFilePath = snapshot.data[index].path;
              var extension = path.extension(snapshot.data[index].path);
              if (extension == '.jpeg') {
                return Container(
                  height: 300,
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.file(
                    File(snapshot.data[index].path),
                  ),
                );
              } else {
                return VideoPreview(
                  videoPath: snapshot.data[index].path,
                );
              }
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 56.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 20.0,
                  child: IconButton(
                    icon: Icon(Icons.share,color: Colors.white),
                    onPressed: () => _shareFile(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 20.0,
                  child: IconButton(
                    icon: Icon(Icons.add_circle,color: Colors.white),
                    onPressed: (){
                      //add post space

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadImage(file: File(currentFilePath),)),
                      );

                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _shareFile() async {
    var extension = path.extension(currentFilePath);
    await Share.file(
      'image',
      (extension == '.jpeg') ? 'image.jpeg' : '	video.mp4',
      File(currentFilePath).readAsBytesSync(),
      (extension == '.jpeg') ? 'image/jpeg' : '	video/mp4',
    );
  }

  _deleteFile() {
    final dir = Directory(currentFilePath);
    dir.deleteSync(recursive: true);
    print('deleted');
    setState(() {});
  }


//  Future uploadFile() async {
//
//    StorageReference storageReference = FirebaseStorage.instance
//        .ref()
//        .child('posts/${Path.basename(currentFilePath)}}');
//    StorageUploadTask uploadTask = storageReference.putFile(File(currentFilePath));
//    await uploadTask.onComplete;
//    print('File Uploaded');
//    storageReference.getDownloadURL().then((fileURL) {
//      setState(() {
//        currentFilePath = fileURL;
//      });
//    });
//  }

  Future<List<FileSystemEntity>> _getAllImages() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/media';
    final myDir = Directory(dirPath);
    List<FileSystemEntity> _images;
    _images = myDir.listSync(recursive: true, followLinks: false);
    _images.sort((a, b) {
      return b.path.compareTo(a.path);
    });
    return _images;
  }
}
