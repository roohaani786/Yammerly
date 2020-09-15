import 'package:techstagram/models/user.dart';
import 'package:techstagram/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:techstagram/models/wiggle.dart';
import 'package:techstagram/services/database.dart';

import '../../constants3.dart';


class FeedsPage extends StatefulWidget {
  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {

  Stream<QuerySnapshot> postsStream;
  final timelineReference = Firestore.instance.collection('posts');
  ScrollController scrollController = new ScrollController();
  Wiggle currentWiggle;

  retrieveTimeline() async {
    DatabaseService().getPosts().then((val) {
      setState(() {
        postsStream = val;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        color: Colors.red,
      ),
    );
  }
}

