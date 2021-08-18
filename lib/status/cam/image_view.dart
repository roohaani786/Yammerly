import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:techstagram/status/model/status_model.dart';

class ImageViewPage extends StatelessWidget {
  const ImageViewPage({Key key, this.file}) : super(key: key);
  final XFile file;

  @override
  Widget build(BuildContext context) {
    File finalFile = File(file.path);
    String urlDownload;
    User currUser = FirebaseAuth.instance.currentUser;
    String uid;
    TextEditingController text = TextEditingController();

    cropImage() async {
      File cropper = await ImageCropper.cropImage(
          sourcePath: finalFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1));
      finalFile = cropper;
      print("finalFIle: $finalFile");
    }

    getCurrentUser() async {
      var docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUser.uid)
          .get();
      uid = docSnap["uid"];
    }

    // compressImage() async {
    //   final result = await FlutterImageCompress.compressAndGetFile(
    //       file.path, finalFile.path,
    //       quality: 80);
    //   print(result);
    //   finalFile = result;
    // }

    Future uploadFile() async {
      getCurrentUser();
      // compressImage();
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("Story")
          .child(uid)
          .child(DateTime.now().toString());

      UploadTask uploadTask = storageRef.putFile(finalFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      urlDownload = await taskSnapshot.ref.getDownloadURL();
      print(urlDownload);

      final Status status =
          Status(data: urlDownload, type: StatusType.image, caption: text.text);
      status.addMediaStatus();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Uploaded')));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
              },
              icon: Icon(
                Icons.filter,
                size: 18,
                color: Colors.white,
              )),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(
                Icons.crop_rotate,
                size: 27,
              ),
              onPressed: () => cropImage(),
            ),
          ),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: Image.file(
                File(finalFile.path),
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black38,
                width: MediaQuery.of(context).size.width - 20,
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                  maxLines: 6,
                  minLines: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Add Caption....",
                    prefixIcon: Icon(
                      Icons.text_fields_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              right: 15,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Uploading, please wait!')));
                  uploadFile();
                  Navigator.of(context).pop();
                },
                child: CircleAvatar(
                  backgroundColor: Colors.purple[400],
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
