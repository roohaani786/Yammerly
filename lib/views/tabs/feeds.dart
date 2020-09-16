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
import 'package:flutter_icons/flutter_icons.dart';

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0,bottom: 20.0,right: 170.0),
            child: Container(
              child: RichText(
                softWrap: true,
                overflow: TextOverflow.visible,
                text: TextSpan(
                  text: "My Feed",
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Barlow-Bold',
                    fontWeight: FontWeight.bold,
                    fontSize: 40.0,
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder(
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
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(40),
                                        child: Image(
                                          image: NetworkImage(url),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("posts[i].username"),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(SimpleLineIcons.options),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            //Image.network(url),

                            FadeInImage(
                              image: NetworkImage(url),
                              //image: NetworkImage("posts[i].postImage"),
                              placeholder: AssetImage("assets/images/empty.png"),
                              width: MediaQuery.of(context).size.width,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(FontAwesome.heart_o),
                                    ),
                                    Text("123"),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(FontAwesome.comment_o),
                                    ),
                                    Text("23"),
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(FontAwesome.send_o),
                                    ),
                                  ],
                                ),
                                // IconButton(
                                //   onPressed: () {},
                                //   icon: Icon(FontAwesome.bookmark_o),
                                // ),
                              ],
                            ),

                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              child: RichText(
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                text: TextSpan(
                                  text: "Vampire of new orleans do recall that i am an original.",
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),
                                ),
                              )
                              // child: RichText(
                              //   softWrap: true,
                              //   overflow: TextOverflow.visible,
                              //   text: TextSpan(
                              //     children: [
                              //       TextSpan(
                              //         text: "Liked By ",
                              //         style: TextStyle(color: Colors.black),
                              //       ),
                              //       TextSpan(
                              //         text: "Sigmund,",
                              //         style: TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //             color: Colors.black),
                              //       ),
                              //       TextSpan(
                              //         text: " Yessenia,",
                              //         style: TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //             color: Colors.black),
                              //       ),
                              //       TextSpan(
                              //         text: " Dayana",
                              //         style: TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //             color: Colors.black),
                              //       ),
                              //       TextSpan(
                              //         text: " and",
                              //         style: TextStyle(
                              //           color: Colors.black,
                              //         ),
                              //       ),
                              //       TextSpan(
                              //         text: " 1263 others",
                              //         style: TextStyle(
                              //             fontWeight: FontWeight.bold,
                              //             color: Colors.black),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            ),

                            // caption
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              child: RichText(
                                softWrap: true,
                                overflow: TextOverflow.visible,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "posts[i].username",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    // TextSpan(
                                    //   text: " mlkl",
                                    //   style: TextStyle(color: Colors.black),
                                    // ),
                                  ],
                                ),
                              ),
                            ),

                            // post date
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              alignment: Alignment.topLeft,
                              child: Text(
                                "2 days ago",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // height: 150.0,
                      // width: 150.0,
                      //child: Image.network(url),
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
        ],
      ),
      );
  }
}

