import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

enum StatusType {
  text,
  image,
  video,
}

class Status {
  static User currUser = FirebaseAuth.instance.currentUser;
  final String data;
  final StatusType type;

  Status({
    this.data,
    this.type,
    this.caption,
    this.colour,
  });
  final DateTime startTime = DateTime.now();
  String caption;
  Color colour;
  final storyRef = FirebaseFirestore.instance.collection("story");

  addUserData() async {
    var result = await FirebaseFirestore.instance
        .collection('users')
        .doc(currUser.uid)
        .get();
    await storyRef.doc(currUser.email).set({
      'displayName': result.data()["displayName"],
      'photoURL': result.data()["photoURL"],
      'uid': result.data()["uid"],
      'time': startTime.toString(),
    });
  }

  String returnFileType(StatusType type) {
    if (type == StatusType.text)
      return 'text';
    else if (type == StatusType.image)
      return 'image';
    else if (type == StatusType.video) return 'video';
  }

  void refreshViewers() {
    storyRef.doc(currUser.email).collection("viewers").get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  void refreshViewed() {
    storyRef.get().then((value) {
      for (DocumentSnapshot ds in value.docs) {
        storyRef.doc(ds.id).collection("viewed").get().then((value) {
          for (DocumentSnapshot doc in value.docs)
            if (doc.id == currUser.email) doc.reference.delete();
        });
      }
    });
    storyRef.doc().collection("viewed").get().then((value) {
      for (DocumentSnapshot ds in value.docs)
        if (ds.id == currUser.email) ds.reference.delete();
    });
  }

  void addTextStatus() async {
    await storyRef.doc(currUser.email).collection("uploaded status").doc().set(
      {
        'data': data,
        'type': returnFileType(type),
        'uploadTime': startTime.toString(),
      },
    );
    addUserData();
    refreshViewers();
    refreshViewed();
  }

  void addMediaStatus() async {
    await storyRef.doc(currUser.email).collection("uploaded status").doc().set({
      'data': data,
      'type': returnFileType(type),
      'caption': caption,
      'uploadTime': startTime.toString(),
    });
    addUserData();
    refreshViewers();
    refreshViewed();
  }
}
