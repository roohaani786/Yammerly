import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:techstagram/views/tabs/comments_screen.dart';

import '../../constants3.dart';


class FeedsPage extends StatefulWidget {

  final Wiggle wiggle;
  final List<Wiggle> wiggles;
  final Timestamp timestamp;
  final String description;
  final String url;
  final String postId;
  final int likes;
  final int uid;

  FeedsPage(
      {this.wiggles,
        this.wiggle,
        this.timestamp,
        this.description,
        this.url,
        this.uid,
        this.postId,
        this.likes});

  @override
  _FeedsPageState createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> {

  bool isLoading = true;
  bool isEditable = false;
  String loadingMessage = "Loading Profile Data";
  TextEditingController emailController,urlController,descriptionController,
  displayNameController,photoUrlController,
  timestampController,likesController,uidController;
  List<Posts> posts;
  List<DocumentSnapshot> list;

  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
  FirebaseUser currUser;

  ScrollController scrollController = new ScrollController();
  Posts currentpost;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  @override
  void initState() {

    emailController = TextEditingController();
    likesController = TextEditingController();
    uidController = TextEditingController();
    displayNameController = TextEditingController();

    super.initState();
    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));
    fetchPosts();
    fetchProfileData();
    fetchLikes();
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



  getlikes() {
    Firestore.instance.collection('posts')
        .document(widget.postId)
        .collection('likes')
        .document(displayNameController.text)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          liked = true;
          print(liked);
        });
      }
      else{
        setState(() {
          liked = false;
        });
      }
    });

  }

  fetchLikes() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {
      docSnap = await Firestore.instance
          .collection("posts")
          .document(currUser.uid)
          .get();
      setState(() {
        isLoading = false;
        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  fetchProfileData() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {
      docSnap = await Firestore.instance
          .collection("users")
          .document(currUser.uid)
          .get();
      emailController.text = docSnap.data["email"];
      likesController.text = docSnap.data["likes"];
      uidController.text =  docSnap.data["uid"];
      displayNameController.text = docSnap.data["uid"];
      setState(() {
        isLoading = false;
        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  bool liked = false;
  var time = "s";
  User currentUser;

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {

        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }

    return time;
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
              ? Column(
                children: [
                Container(
                  color: Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FlatButton(onPressed: (){},
                        color: Colors.transparent,
                          child: Row(
                            children: [
                              Icon(FontAwesomeIcons.plus,color: Colors.deepPurpleAccent,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Add Post",style:
                                  TextStyle(
                                    color: Colors.deepPurpleAccent,
                                  ),),
                              ),
                            ],
                          ),
                          ),

                      Padding(
                        padding: const EdgeInsets.only(left: 100.0),
                      ),
                      FlatButton(onPressed: (){},
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.star,color: Colors.deepPurpleAccent,),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("Rate us",style:
                              TextStyle(
                                color: Colors.deepPurpleAccent,
                              ),),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                  new Expanded(
                    child: ListView.builder(
                    controller: scrollController,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      String email = snapshot.data.documents[index]['email'];
                      String description =
                      snapshot.data.documents[index]['description'];
                      String displayName =
                      snapshot.data.documents[index]['displayName'];
                      String photoUrl =
                      snapshot.data.documents[index]['photoURL'];

                      Timestamp timestamp =
                      snapshot.data.documents[index]['timestamp'];
                      String url = snapshot.data.documents[index]['url'];
                      String postId = snapshot.data.documents[index]['postId'];
                      int likes = snapshot.data.documents[index]['likes'];

                      readTimestamp(timestamp.seconds);


                      print(email);
                      print(displayName);
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
                                            image: NetworkImage(photoUrl),
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(displayName),
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
                                      (!liked)?IconButton(
                                        onPressed: () {
                                          DatabaseService().likepost(
                                              likes, postId, displayName);
                                          setState(() {
                                            liked = true;
                                          });
                                        },
                                        icon: Icon(FontAwesome.thumbs_up),
                                        iconSize: 25,
                                        color: Colors.grey,
                                        // onPressed: () {
                                        // },
                                        // icon: Icon(FontAwesome.thumbs_up,color: Colors.deepPurple,),
                                      ):IconButton(

                                        onPressed: () {
                                          DatabaseService().unlikepost(
                                              likes, postId, displayName);
                                          setState(() {
                                            liked = false;
                                          });
                                        },

                                        icon: Icon(FontAwesome.thumbs_up),
                                        iconSize: 25,
                                        color: Colors.deepPurple,
                                        // onPressed: () {
                                        // },
                                        // icon: Icon(FontAwesome.thumbs_up,color: Colors.deepPurple,),
                                      ),
                                      Text(
                                        likes.toString(),style: TextStyle(
                                        color: Colors.black,
                                      ),

                                      ),

                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: ((context) => CommentsScreen(
                                                    documentReference: list[index].reference,
                                                    user: currentUser,
                                                  ))));
                                        },
                                        icon: Icon(Icons.comment,color: Colors.deepPurpleAccent),
                                      ),
                                      Text("23"),
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.share,color: Colors.deepPurpleAccent),
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
                                    text: description,
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,),
                                  ),
                                )
                              ),

                              // caption
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 5,
                                ),
//                                child: RichText(
//                                  softWrap: true,
//                                  overflow: TextOverflow.visible,
//                                  text: TextSpan(
//                                    children: [
//                                      TextSpan(
//                                        text: displayName,
//                                        style: TextStyle(
//                                            fontWeight: FontWeight.bold,
//                                            color: Colors.black),
//                                      ),
//                                      // TextSpan(
//                                      //   text: " mlkl",
//                                      //   style: TextStyle(color: Colors.black),
//                                      // ),
//                                    ],
//                                  ),
//                                ),
                              ),

                              // post date
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                alignment: Alignment.topLeft,
                                child: Text(
                                  readTimestamp(timestamp.seconds),
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10.0,
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
                    }),
                  ),
                ],
              )
              : Container();

        },
        ),
      );
  }
}



