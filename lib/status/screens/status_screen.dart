import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:techstagram/status/cam/camera_screen.dart';
import 'package:techstagram/status/model/status_model.dart';
import 'package:techstagram/status/widgets/status_screen_body.dart';

class DetailStatusScreen extends StatefulWidget {
  @override
  _DetailStatusScreenState createState() => _DetailStatusScreenState();
}

class _DetailStatusScreenState extends State<DetailStatusScreen> {
  File pickedImage;
  UploadTask task;

  Future selectImage() async {
    await Permission.photos.request();
    final result =
        await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    if (result == null) return;
    final path = result.path;

    setState(() => pickedImage = File(path));
  }

  String uid;
  User currUser = FirebaseAuth.instance.currentUser;
  String urlDownload;
  getCurrentUser() async {
    var docSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser.uid)
        .get();
    uid = docSnap["uid"];
  }

  Future uploadFile() async {
    getCurrentUser();
    Reference storageRef = FirebaseStorage.instance
        .ref()
        .child("Story")
        .child(uid)
        .child(DateTime.now().toString());

    UploadTask uploadTask = storageRef.putFile(pickedImage);
    TaskSnapshot taskSnapshot = await uploadTask;

    urlDownload = await taskSnapshot.ref.getDownloadURL();

    final Status status =
        Status(data: urlDownload, type: StatusType.image, caption: '');
    status.addMediaStatus();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController text = TextEditingController();
    return Scaffold(
      floatingActionButton: Container(
        height: 100,
        child: Column(
          children: [
            SizedBox(
              height: 45,
              child: FloatingActionButton(
                heroTag: "TextButton",
                backgroundColor: Colors.deepPurple[400],
                onPressed: () {
                  Alert(
                    closeFunction: () {
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    context: context,
                    title: 'Enter Text',
                    content: TextField(
                      controller: text,
                    ),
                    buttons: [
                      DialogButton(
                          color: Colors.deepPurple[400],
                          child: Text(
                            'Upload Text',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            final Status status =
                                Status(data: text.text, type: StatusType.text);
                            status.addTextStatus();
                            Navigator.of(context).pop();
                            setState(() {});
                          })
                    ],
                  ).show();
                },
                child: Icon(
                  (Icons.text_fields),
                ),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            SizedBox(
              height: 45,
              child: FloatingActionButton(
                heroTag: "imageButton",
                backgroundColor: Colors.deepPurple[400],
                onPressed: () {
                  Alert(
                    closeFunction: () {
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                    context: context,
                    title: 'Select Photo',
                    content: Column(
                      children: [
                        TextButton(
                            child: Text(
                              'Choose from Files',
                              style: TextStyle(color: Colors.purple[400]),
                            ),
                            onPressed: () {
                              selectImage();
                            }),
                        TextButton(
                          child: Text(
                            'Capture from camera',
                            style: TextStyle(color: Colors.purple[400]),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CameraScreen()));
                          },
                        )
                      ],
                    ),
                    buttons: [
                      DialogButton(
                          color: Colors.deepPurple[400],
                          child: Text(
                            'Upload Photo',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            uploadFile();
                            Navigator.of(context).pop();
                            setState(() {});
                          })
                    ],
                  ).show();
                },
                child: Icon(
                  (Icons.photo_album_outlined),
                ),
              ),
            ),
          ],
        ),
      ),
      body: StatusScreenBody(),
    );
  }
}
