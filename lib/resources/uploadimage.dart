import 'dart:io';

import 'package:techstagram/models/user.dart';
import 'package:techstagram/models/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;

class UploadImage extends StatefulWidget {
  final User userData;
  File file;
  UploadImage({this.file, this.userData});

  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage>
    with AutomaticKeepAliveClientMixin<UploadImage> {
  File file;
  TextEditingController descriptionTextEditingController =
  TextEditingController();
  bool uploading = false;
  final StorageReference storageReference =
  FirebaseStorage.instance.ref().child("Post Pictures");
  final postReference = Firestore.instance.collection("posts");
  String postId = Uuid().v4();

  // removeImage() {
  //   descriptionTextEditingController.clear();
  //   setState(() {
  //     widget.file = null;
  //   });
  // }

  compressPhoto() async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImage = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(
        ImD.encodeJpg(mImageFile, quality: 60),
      );
    setState(() {
      file = compressedImage;
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask mStorageUploadTask =
    storageReference.child("post_$postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot =
    await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });

    await compressPhoto();

    String downloadUrl = await uploadPhoto(file);
    savePostInfoToFirestore(downloadUrl, descriptionTextEditingController.text);

    descriptionTextEditingController.clear();
    setState(() {
      // file = null;
      uploading = false;
      postId = Uuid().v4();
    });
    Navigator.pop(context);
  }

  savePostInfoToFirestore(String url, String description) {
    postReference.document(postId).setData({
      "postId": postId,
//      "name": widget.userData.displayName,
      "timestamp": Timestamp.now(),
//      "email": widget.userData.email,
//      "description": description,
      "likes": 0,
      "url": url,
//      "photourl": widget.userData.photoUrl,
    });
  }

  displayUploadFormScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.deepPurple,),
            onPressed: (){
          Navigator.pop(context);
        }),
        title: Text(
          "New Post",
          style: TextStyle(
              color: Colors.deepPurple, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          // uploading ? linearProgress() : Text(''),
          FlatButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: () => controlUploadAndSave(),
            child: Text(
              "Share",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: uploading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : ListView(
        children: <Widget>[
          Container(
            height: 330,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 6 / 5,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(

                        image: FileImage(file), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12),
          ),

          Container(
//            color: Colors.white,
            child:  Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Text("Caption",style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),),
                  Text("djsjfsgfhghdfghdfh",style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    file = widget.file;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: displayUploadFormScreen(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}