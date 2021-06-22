import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:techstagram/models/users.dart';
import 'package:techstagram/status/cam/camera_screen.dart';
import 'package:techstagram/status/status_model.dart';
import 'package:techstagram/status/status_view_page.dart';

class DetailStatusScreen extends StatefulWidget {
  @override
  _DetailStatusScreenState createState() => _DetailStatusScreenState();
}

class _DetailStatusScreenState extends State<DetailStatusScreen> {
  File pickedImage;
  UploadTask task;

  @override
  void initState() {
    print('initstatr initialised');
    super.initState();
    loadData();
  }

  loadData() async {
    print("initialize load data");
    FirebaseFirestore.instance.collection("story").doc();
  }

  Future selectImage(ImageSource source) async {
    await Permission.photos.request();
    final result = await ImagePicker.platform.pickImage(source: source);
    if (result == null) return;
    final path = result.path;
    setState(() => pickedImage = File(path));
  }

  @override
  Widget build(BuildContext context) {
    print('screen loaded');
    TextEditingController text = TextEditingController();

    return Scaffold(
      floatingActionButton: Container(
        height: 100,
        child: Column(
          children: [
            SizedBox(
              height: 45,
              child: FloatingActionButton(
                backgroundColor: Colors.deepPurple[400],
                onPressed: () {
                  Alert(
                    context: context,
                    title: 'Enter Text',
                    content: TextField(
                      controller: text,
                    ),
                    buttons: [
                      DialogButton(
                          child: Text(
                            'Upload Text',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            final Status status =
                                Status(data: text.text, type: StatusType.text);
                            status.addTextStatus();
                            Navigator.of(context).pop();
                            //setState(() {});
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
                backgroundColor: Colors.deepPurple[400],
                onPressed: () {
                  Alert(
                    context: context,
                    title: 'Select Photo',
                    content: Column(
                      children: [
                        TextButton(
                            child: Text('Choose from Files'),
                            onPressed: () {
                              selectImage(ImageSource.gallery);
                            }),
                        TextButton(
                          child: Text('Capture from camera'),
                          onPressed: () {
                            // selectImage(ImageSource.camera);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CameraScreen()));
                          },
                        )
                      ],
                    ),
                    buttons: [
                      DialogButton(
                          child: Text(
                            'Upload Photo',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            //   uploadFile();
                            Navigator.of(context).pop();
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

class StatusScreenBody extends StatefulWidget {
  const StatusScreenBody({
    Key key,
  }) : super(key: key);

  @override
  _StatusScreenBodyState createState() => _StatusScreenBodyState();
}

class _StatusScreenBodyState extends State<StatusScreenBody> {
  @override
  Widget build(BuildContext context) {
    var stream = FirebaseFirestore.instance.collection("story").snapshots();

    return StreamBuilder(
        stream: stream,
        builder: (BuildContext ctx, snapShot) {
          switch (snapShot.connectionState) {
            case ConnectionState.none:
              return Center(child: Text("nothing to show"));
            case ConnectionState.waiting:
              return Center(child: Text("waiting"));
            default:
              if (snapShot.hasData) {
                return ListView.builder(
                    itemCount: snapShot.data.docs.length,
                    itemBuilder: (ctx, i) {
                      String id = snapShot.data.docs[i].id;
                      String pic = snapShot.data.docs[i].data()["photoURL"];
                      print(pic);
                      return GestureDetector(
                        child: ListTile(
                            leading: CircleAvatar(
                          child: Image.network(pic.toString()),
                        )),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => StatusViewScreen(id: id)));
                        },
                      );
                    });
              }
          }
        });
  }
}
