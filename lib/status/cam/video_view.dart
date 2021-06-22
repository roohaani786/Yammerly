import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../status_model.dart';
import '../status_screen.dart';

class VideoViewPage extends StatefulWidget {
  const VideoViewPage({Key key, this.file}) : super(key: key);
  final XFile file;

  @override
  _VideoViewPageState createState() => _VideoViewPageState();
}

class _VideoViewPageState extends State<VideoViewPage> {
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.file.path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    File finalFile = File(widget.file.path);
    User currUser = FirebaseAuth.instance.currentUser;
    String uid;
    String urlDownload;
    TextEditingController text = TextEditingController();

    getCurrentUser() async {
      var docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUser.uid)
          .get();
      uid = docSnap["uid"];
    }

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

      final Status status = Status(data: urlDownload, type: StatusType.video);
      status.addMediaStatus();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => DetailStatusScreen()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : Container(),
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
                      Icons.add_photo_alternate,
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
                  uploadFile();
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
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: CircleAvatar(
                  radius: 33,
                  backgroundColor: Colors.black38,
                  child: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
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
