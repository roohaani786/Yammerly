import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:techstagram/models/posts.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
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

  bool isLoading = true;
  bool isEditable = false;
  String loadingMessage = "Loading Profile Data";
  TextEditingController emailController,urlController,descriptionController,
  timestampController,likesController;
  List<Posts> posts;

  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
  FirebaseUser currUser;

  ScrollController scrollController = new ScrollController();
  Posts currentpost;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {

    super.initState();
    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));
    fetchPosts();
  }

  Stream<QuerySnapshot> postsStream;
  final timelineReference = Firestore.instance.collection('posts');

  fetchPosts() async {

    DatabaseService().getPosts().then((val){
      setState(() {
        postsStream = val;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      body: StreamBuilder(
        stream: postsStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
              controller: scrollController,
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                String email = snapshot.data.documents[index]['email'];
                String description =
                snapshot.data.documents[index]['description'];
                Timestamp timestamp =
                snapshot.data.documents[index]['timestamp'];
                String url = snapshot.data.documents[index]['url'];
                String postId = snapshot.data.documents[index]['postId'];
                int likes = snapshot.data.documents[index]['likes'];

                print(email);
//                for (int i = 0; i < posts.length; i++) {
//                  if (posts[i].email == email) {
//                    currentpost = posts[i];
//                  }
//                }
                return Container(
                  height: 150.0,
                  width: 150.0,
                  child: Image.network(url),
                );

//                return FeedTile(
//                  wiggle: currentpost,
//                  wiggles: posts,
//                  description: description,
//                  timestamp: timestamp,
//                  url: url,
//                  postId: postId,
//                  likes: likes,
//                );
              })
              : Container();

        },
        ),
      );
  }
}

