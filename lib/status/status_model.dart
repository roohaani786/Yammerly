import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum StatusType {
  text,
  image,
  video,
}

class StatusList {
  static List<Status> statusList = [];
}

class Status {
  User currUser = FirebaseAuth.instance.currentUser;
  final String data;
  final StatusType type;
  int views = 0;

  Status({
    @required this.data,
    @required this.type,
    this.caption,
    this.colour,
  });
  final DateTime startTime = DateTime.now();
  String caption;
  String colour;
  final storyRef = FirebaseFirestore.instance.collection("story");

  addUserData() async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .doc(currUser.uid)
        .get();
    await storyRef.doc(currUser.email).set({
      'displayName': result.data()["displayName"],
      'photoURL': result.data()["photoURL"],
      'uid': result.data()["uid"]
    });
  }

  String returnFileType(StatusType type) {
    if (type == StatusType.text)
      return 'text';
    else if (type == StatusType.image)
      return 'image';
    else if (type == StatusType.video) return 'video';
  }

  void addTextStatus() async {
    print('uploading text');
    print(currUser.email);
    await storyRef.doc(currUser.email).collection("uploaded status").doc().set(
      {
        'data': data,
        'type': returnFileType(type),
        'views': views,
        'uploadTime': startTime.toString(),
      },
    );
    addUserData();
  }

  void addMediaStatus() async {
    print('uploading text');
    storyRef.doc(currUser.email).collection(currUser.email).doc().set({
      'data': data,
      'type': returnFileType(type),
      'caption': caption,
      'views': views,
      'uploadTime': startTime.toString(),
    });
  }
}
