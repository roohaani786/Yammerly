import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/models/posts.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/resources/uploadimage.dart';
import 'package:techstagram/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/ui/Otheruser/other_user.dart';
import 'package:techstagram/views/tabs/comments_screen.dart';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';

class postPage extends StatefulWidget {
  @override
  final String PostUrl;
  final String displayNamecurrentUser;
  final String uidX;
  final bool delete;

  postPage({
    this.PostUrl,
    this.displayNamecurrentUser,
    this.uidX,
    this.delete,
  });

  @override
  _postPageState createState() => _postPageState(
      displayNamecurrentUser: displayNamecurrentUser,
      PostUrl: PostUrl,
      uidX: uidX,
      delete: delete);
}

class _postPageState extends State<postPage> {
  bool isLoading = true;
  bool _liked = false;
  bool loading = false;
  bool isEditable = false;
  final String displayNamecurrentUser;
  final String PostUrl;
  final String uidX;
  final bool delete;

  _postPageState(
      {this.displayNamecurrentUser, this.PostUrl, this.uidX, this.delete});
  String loadingMessage = "Loading Profile Data";
  TextEditingController emailController,
      urlController,
      descriptionController,
      displayNameController,
      photoUrlController,
      timestampController,
      likesController,
      uidController;
  int posts;
  List<DocumentSnapshot> list;

  List<bool> likess = List.filled(10000, false);

  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
  User currUser;

  ScrollController scrollController = new ScrollController();
  Posts currentpost;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    emailController = TextEditingController();
    likesController = TextEditingController();
    uidController = TextEditingController();
    displayNameController = TextEditingController();
    photoUrlController = TextEditingController();

    super.initState();
    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));
    fetchPosts();
    fetchProfileData();

//    fetchLikes();

    //print("widget bhaiyya");
    //print(widget.uid);
  }

  Stream<QuerySnapshot> postsStream;
  final timelineReference = FirebaseFirestore.instance.collection('posts');
  String postIdX;

  fetchPosts() async {
    getPosts().then((val) {
      setState(() {
        postsStream = val;
      });
    });
  }

  deletePost(String displayNamecurrent, String displayName, String postId,
      String uidX) async {
    //print(displayNamecurrent)

    if (displayName == displayNamecurrentUser) {
      print("delte click");

      DatabaseService().PostD(uidX, posts);
      print(postId);
      print(displayName);
      print(uidX);
      print("halelula");
      print(displayNamecurrentUser);
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uidX)
          .collection('posts')
          .doc(postId)
          .delete();

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => HomePage(
                initialindexg: 3,
              )));
    } else {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('You are not the owner of this post'),
              actions: <Widget>[],
            );
          });
    }
  }

  getPosts() async {
    print(PostUrl);
    return FirebaseFirestore.instance
        .collection("posts")
        .where('url', isEqualTo: PostUrl)
        .where("displayName", isEqualTo: displayNamecurrentUser)
        .where("uid", isEqualTo: uidX)
        .snapshots();
  }

  getlikes(String displayNamecurrent, String postId, int index) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(uidController.text)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          //likeint = int.parse(postId);
          //_liked = true;
          likess[index] = true;
          print("baabu baabi");
          //like[likeint] = "true";
        });
      } else {
        setState(() {
          likess[index] = false;
        });
      }
    });
  }

  fetchLikes() async {
    currUser = FirebaseAuth.instance.currentUser;
    try {
      docSnap = await FirebaseFirestore.instance
          .collection("likes")
          .doc(currUser.uid)
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
    currUser = FirebaseAuth.instance.currentUser;
    try {
      docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUser.uid)
          .get();
      emailController.text = docSnap["email"];
      likesController.text = docSnap["likes"];
      uidController.text = docSnap["uid"];
      displayNameController.text = docSnap["displayName"];
      photoUrlController.text = docSnap["photoURL"];
      posts = docSnap["posts"];

      setState(() {
        isLoading = false;
        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  var time = "s";
  User currentUser;

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
//    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      if (diff.inHours > 0) {
        time = "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
      } else if (diff.inSeconds == 0 || diff.inSeconds < 60) {
        time = "just now";
      } else if (diff.inMinutes > 0) {
        time =
        "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
      }
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

  File _image;
  bool upload;
  Timer timer;

  createAlertDialog(context, url) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure you want to delete post?'),
            actions: <Widget>[
              MaterialButton(
                  child: Text('Yes'),
                  onPressed: () {
                    // return Firestore.instance.collection("posts")
                    //     .document(url)
                    //     .delete();

                    FirebaseFirestore.instance
                        .collection("posts")
                        .doc(url)
                        .get()
                        .then((doc) {
                      if (doc.exists) {
                        doc.reference.delete();

                        Navigator.pop(context);
                      }
                    });
                    // DatabaseService()
                    //     .postReference
                    //     .document(widget.postId)
                    //     .get()
                    //     .then((doc) {
                    //   if (doc.exists) {
                    //     doc.reference.delete();
                    //
                    //     Navigator.pop(context);
                    //   }
                    // });
                  }),
            ],
          );
        });
  }

  Future pickImage() async {
    await ImagePicker().getImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = File(image.path);
        upload = true;
      });
    });
    (_image != null)
        ? Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UploadImage(
            file: _image,
          )),
    )
        : Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(
            initialindexg: 3,
          )),
    );
    print("Done..");
  }

  doubletaplike(int likes, String postId) async {
    if (_liked = false) {
      setState(() {
        _liked = true;
      });
      await DatabaseService()
          .likepost(likes, postId, uidX, displayNameController.text);
    } else {
      print("jhj");
    }
  }

  String urlx;

  TransformationController _controller = TransformationController();

  @override
  Widget build(BuildContext context) {
//    fetchdimensions(String url) async {
//      File image = new File(url);
//      var decodedImage = await decodeImageFromList(image.readAsBytesSync());
//      print(decodedImage.width);
//      print(decodedImage.height);
//    }

    //print(displayNameController.text);

    // TODO: implement build
    return GestureDetector(
      onTap: () {
        print("hello");
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "Posts",
            style: TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.normal),
          ),
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        key: _scaffoldKey,
        body: StreamBuilder(
          stream: postsStream,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Column(
              children: [
                new Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      int len = snapshot.data.docs.length;

                      postIdX = snapshot.data.docs[index]['postId'];

                      String email =
                      snapshot.data.docs[index]['email'];

                      String description =
                      snapshot.data.docs[index]['description'];

                      String displayName =
                      snapshot.data.docs[index]['displayName'];

                      String photoUrl =
                      snapshot.data.docs[index]['photoURL'];

                      String OwnerDisplayName;
                      String OwnerPhotourl;
                      String OwnerUid;
                      bool shared;


                      if(snapshot.data.docs[index].data().containsKey('OwnerDisplayName') == null){
                        OwnerDisplayName = snapshot
                            .data.docs[index]['OwnerDisplayName'];

                        OwnerPhotourl =
                        snapshot.data.docs[index]['OwnerPhotourl'];

                        OwnerUid =
                        snapshot.data.docs[index]['OwnerUid'];

                        shared =
                        snapshot.data.docs[index]['shared'];
                      }


                      String uid = snapshot.data.docs[index]["uid"];

                      int shares =
                      snapshot.data.docs[index]["shares"];


                      Timestamp timestamp =
                      snapshot.data.docs[index]['timestamp'];

                      String url = snapshot.data.docs[index]['url'];

                      int cam = snapshot.data.docs[index]['cam'];

                      String postId =
                      snapshot.data.docs[index]['postId'];

                      int likes = snapshot.data.docs[index]['likes'];

                      int comments =
                      snapshot.data.docs[index]['comments'];

                      print("yaha pe bhi nahi aara");

                      Timestamp OwnerTimeStamp;
                      String OwnerDescription;


                      if(snapshot.data.docs[index].data().containsKey('OwnerTimeStamp') == null){
                        OwnerTimeStamp = snapshot
                            .data.docs[index]['OwnerTimeStamp'];

                        OwnerDescription = snapshot
                            .data.docs[index]['OwnerDescription'];
                      }

                      readTimestamp(timestamp.seconds);

                      getlikes(displayNamecurrentUser, postId, index);

//                        if(likes == 0){
//
//                          _likes[index] = true;
////
//                        }

                      return (shared == true)
                          ? Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 0.0,
                              width: 0.0,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OtherUserProfile(
                                          uid: uid,
                                          displayNamecurrentUser:
                                          displayNameController
                                              .text,
                                          displayName: displayName,
                                          uidX: uidController.text,
                                        )),
                              ),
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: 10,
                                  left: 10,
                                  right: 10.0,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            ClipRRect(
                                              borderRadius:
                                              BorderRadius
                                                  .circular(40),
                                              child: Image(
                                                image: NetworkImage(
                                                    photoUrl),
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              displayName,
                                              style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                        (delete != true)
                                            ? Container()
                                            : IconButton(
                                          icon: Icon(
                                              Icons.delete),
                                          onPressed: () {
                                            (displayName ==
                                                displayNamecurrentUser)
                                                ? showDialog(
                                                context:
                                                context,
                                                builder:
                                                    (BuildContext
                                                context) {
                                                  return AlertDialog(
                                                    backgroundColor:
                                                    Colors.white,
                                                    title:
                                                    Text("Delete post ?"),
                                                    content: Text(
                                                        "Are you sure you wanna delete this post.",
                                                        style: TextStyle(color: Colors.deepPurple)),
                                                    actions: <
                                                        Widget>[
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 120.0),
                                                        child: Column(
                                                          children: [
                                                            MaterialButton(
                                                              child: Text(
                                                                "yes",
                                                                style: TextStyle(
                                                                  color: Colors.red,
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                deletePost(displayNamecurrentUser, displayName, postId, uidX);
                                                                Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HomePage(initialindexg: 3)));
                                                              },
                                                            ),
                                                            MaterialButton(
                                                              child: Text(
                                                                "No",
                                                                style: TextStyle(
                                                                  color: Colors.black,
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                            )
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  );
                                                })
                                                : showDialog(
                                                context:
                                                context,
                                                builder:
                                                    (context) {
                                                  return AlertDialog(
                                                    title:
                                                    Text('You are not the owner of this post'),
                                                    actions: <
                                                        Widget>[],
                                                  );
                                                });
                                            //deletePost(displayNamecurrentUser, displayName, postId, uidX);
                                            //Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Padding(
                            //   padding: const EdgeInsets.only(bottom: 1.0),
                            //   child: Container(
                            //     height: 50.0,
                            //     color: Colors.grey.shade50,
                            //     child: Padding(
                            //       padding: const EdgeInsets.only(left: 15.0,right: 15.0,),
                            //       child: Row(
                            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //         children: <Widget>[
                            //           Row(
                            //             children: <Widget>[
                            //               ClipRRect(
                            //                 borderRadius: BorderRadius.circular(40),
                            //                 child: Image(
                            //                   image: NetworkImage(OwnerPhotourl),
                            //                   width: 30,
                            //                   height: 30,
                            //                   fit: BoxFit.cover,
                            //                 ),
                            //               ),
                            //               SizedBox(
                            //                 width: 10,
                            //               ),
                            //               Text(OwnerDisplayName,style: TextStyle(
                            //                 fontWeight: FontWeight.bold,
                            //                 fontSize: 12.0,
                            //               ),),
                            //             ],
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ),
                            // ),

                            GestureDetector(
                              onDoubleTap: () {
                                if (likess[index] == false) {
                                  setState(() {
                                    likess[index] = true;
                                  });

                                  DatabaseService().likepost(
                                      likes,
                                      postId,
                                      uidX,
                                      displayNameController.text);
                                }
                              },
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => postPage(
                                          displayNamecurrentUser:
                                          OwnerDisplayName,
                                          PostUrl: url,
                                          uidX: OwnerUid,
                                          delete: false)),
                                  // MaterialPageRoute(builder: (context) => postPage(PostUrl: url,)),
                                );
                              },
                              child: Container(
                                //height: 350.0,
                                width: MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.95,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      child: (cam == 1)
                                          ? Transform(
                                        alignment:
                                        Alignment.center,
                                        transform:
                                        Matrix4.rotationY(
                                            math.pi),
                                        child: (url == null)
                                            ? Container()
                                            : CachedNetworkImage(
                                            imageUrl:
                                            url),
                                        //image: NetworkImage("posts[i].postImage"),
                                      )
                                          : (url == null)
                                          ? Container()
                                          : CachedNetworkImage(
                                          imageUrl: url),
                                    ),
                                    // GestureDetector(
                                    //
                                    //   child : (cam == 1)? Transform(
                                    //     alignment: Alignment.center,
                                    //     transform: Matrix4.rotationY(math.pi),
                                    //     child: FadeInImage(
                                    //       image: NetworkImage(url),
                                    //       fit: BoxFit.cover,
                                    //       //image: NetworkImage("posts[i].postImage"),
                                    //       placeholder: AssetImage("assets/images/loading.gif"),
                                    //       width: MediaQuery.of(context).size.width,
                                    //     ),
                                    //   ):FadeInImage(
                                    //     image: NetworkImage(url),
                                    //     fit: BoxFit.cover,
                                    //     //image: NetworkImage("posts[i].postImage"),
                                    //     placeholder: AssetImage("assets/images/loading.gif"),
                                    //     width: MediaQuery.of(context).size.width,
                                    //   ),
                                    // ),
                                    Container(
                                        width:
                                        MediaQuery.of(context)
                                            .size
                                            .width,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            // top: BorderSide(width: 2.0, color: Colors.grey),
                                            //left: BorderSide(width: 2.0, color: Colors.grey),
                                            //right: BorderSide(width: 2.0, color: Colors.grey)
                                            // bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                          ),
                                        ),
                                        // margin: EdgeInsets.symmetric(
                                        //   horizontal: 14,
                                        // ),
                                        child: Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              top: 5.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(
                                                        context)
                                                        .size
                                                        .width *
                                                        0.8,
                                                    child: RichText(
                                                      textAlign:
                                                      TextAlign
                                                          .start,
                                                      softWrap:
                                                      true,
                                                      overflow:
                                                      TextOverflow
                                                          .visible,
                                                      text:
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text: "  " +
                                                                OwnerDisplayName +
                                                                " ",
                                                            style: TextStyle(
                                                                color:
                                                                Colors.grey.shade800,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 15.0),
                                                          ),
                                                          TextSpan(
                                                            text:
                                                            OwnerDescription,
                                                            style: TextStyle(
                                                                color:
                                                                Colors.grey.shade800,
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 12.0),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              (OwnerTimeStamp ==
                                                  null)
                                                  ? Container()
                                                  : Container(
                                                margin: EdgeInsets
                                                    .only(
                                                    top:
                                                    8,
                                                    left:
                                                    8),
                                                alignment:
                                                Alignment
                                                    .topLeft,
                                                child: Text(
                                                  (OwnerTimeStamp ==
                                                      null)
                                                      ? ""
                                                      : readTimestamp(
                                                      OwnerTimeStamp.seconds),
                                                  textAlign:
                                                  TextAlign
                                                      .start,
                                                  style:
                                                  TextStyle(
                                                    color: Colors
                                                        .grey,
                                                    fontSize:
                                                    10.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ),

                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    IconButton(
                                      padding:
                                      EdgeInsets.only(left: 10),
                                      onPressed: (likess[index] ==
                                          true)
                                          ? () {
                                        if (timer?.isActive ??
                                            false)
                                          timer
                                              .cancel(); //cancel if [timer] is null or running
                                        timer = Timer(
                                          const Duration(
                                              milliseconds:
                                              340),
                                              () {
                                            setState(() {
                                              likess[index] =
                                              false;
                                              loading = true;
                                            });
                                            DatabaseService()
                                                .unlikepost(
                                                likes,
                                                postId,
                                                uidController
                                                    .text,
                                                displayNameController
                                                    .text);
                                          },
                                        );
                                      }
                                          : () {
                                        if (timer?.isActive ??
                                            false)
                                          timer
                                              .cancel(); //cancel if [timer] is null or running
                                        timer = Timer(
                                          const Duration(
                                              milliseconds:
                                              340),
                                              () {
                                            setState(() {
                                              likess[index] =
                                              true;
                                              loading = true;
                                            });
                                            DatabaseService()
                                                .likepost(
                                                likes,
                                                postId,
                                                uidController
                                                    .text,
                                                displayNameController
                                                    .text);
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.thumb_up),
                                      iconSize: 25,
                                      color: (likess[index] == true)
                                          ? Colors.deepPurple
                                          : Colors.grey,
                                    ),
                                    Text(
                                      likes.toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          top: 3.0),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (context) {
                                                    return CommentsPage(
                                                        comments: comments,
                                                        postId: postId,
                                                        uid: uid,
                                                        postImageUrl: url,
                                                        timestamp:
                                                        timestamp,
                                                        displayName:
                                                        displayName,
                                                        photoUrl:
                                                        photoUrlController
                                                            .text,
                                                        displayNamecurrentUser:
                                                        displayNameController
                                                            .text);
                                                  }));
                                        },
                                        icon: Icon(
                                            Icons.insert_comment,
                                            color: Colors
                                                .deepPurpleAccent),
                                      ),
                                    ),
                                    Text(comments.toString()),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UploadImage(
                                                    ownerPostId:
                                                    postIdX,
                                                    file: File(url),
                                                    sharedurl: url,
                                                    ownerdiscription:
                                                    description,
                                                    ownerphotourl:
                                                    photoUrl,
                                                    ownerdisplayname:
                                                    displayName,
                                                    shared: true,
                                                    cam: cam,
                                                    ownerTimeStamp:
                                                    OwnerTimeStamp,
                                                  )),
                                        );
                                      },
                                      icon: Icon(
                                          FontAwesomeIcons.share,
                                          color: Colors
                                              .deepPurpleAccent),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            Container(
                                width: MediaQuery.of(context)
                                    .size
                                    .width,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width:
                                          MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.90,
                                          child: RichText(
                                            textAlign:
                                            TextAlign.start,
                                            softWrap: true,
                                            overflow: TextOverflow
                                                .visible,
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text:
                                                  displayName +
                                                      "  ",
                                                  style: TextStyle(
                                                      color: Colors
                                                          .black,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold,
                                                      fontSize:
                                                      18.0),
                                                ),
                                                TextSpan(
                                                  text: description,
                                                  style: TextStyle(
                                                      color: Colors
                                                          .black,
                                                      fontWeight:
                                                      FontWeight
                                                          .normal,
                                                      fontSize:
                                                      15.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),

                            Container(
                              width:
                              MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                            ),

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
                      )
                          : Container(
                        color: Colors.white,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 0.0,
                              width: 0.0,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        OtherUserProfile(
                                          uid: uid,
                                          displayNamecurrentUser:
                                          displayNameController
                                              .text,
                                          displayName: displayName,
                                          uidX: uidController.text,
                                        )),
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(
                                              40),
                                          child: Image(
                                            image: NetworkImage(
                                                photoUrl),
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          displayName,
                                          style: TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    (delete != true && displayName !=
                                        displayNamecurrentUser)
                                        ? Container()
                                        : IconButton(
                                      icon:
                                      Icon(SimpleLineIcons.options_vertical),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          elevation: 100,
                                          context: context,
                                          builder:(context){
                                            return Container(
                                              color: Colors.white,
                                              child: Column(
                                                children: [
                                                  Center(child:
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Container(
                                                      width: MediaQuery.of(context).size.width * 0.1,
                                                      decoration: BoxDecoration(border: Border.all(color: Colors.black12),
                                                        borderRadius: BorderRadius.circular(5),
                                                        color: Colors.black,)
                                                    ),
                                                  )),
                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                                                  ListTile(
                                                    title: Text('Share Post',style: TextStyle(fontWeight: FontWeight.bold)),
                                                    subtitle: Text('Share this post to your friends'),
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                                                  ListTile(
                                                    title: Text('Delete Post',style: TextStyle(fontWeight: FontWeight.bold)),
                                                    subtitle: Text('This will delete your post permanently'),
                                                    onTap: (){
                                                      showDialog(
                                                             context:
                                                             context,
                                                             builder:
                                                                 (BuildContext
                                                             context) {
                                                               return AlertDialog(
                                                                 backgroundColor:
                                                                 Colors
                                                                     .white,
                                                                 title: Text(
                                                                     "Are you sure you want to Delete this post?"),
                                                                 actions: <
                                                                     Widget>[
                                                                   Padding(
                                                                     padding:
                                                                     const EdgeInsets.only(right: 120.0),
                                                                     child:
                                                                     Column(
                                                                       children: [
                                                                         MaterialButton(
                                                                           child: Text(
                                                                             "yes",
                                                                             style: TextStyle(
                                                                               color: Colors.red,
                                                                             ),
                                                                           ),
                                                                           onPressed: () {
                                                                             deletePost(displayNamecurrentUser, displayName, postId, uidX);
                                                                             Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HomePage(initialindexg: 3)));
                                                                           },
                                                                         ),
                                                                         MaterialButton(
                                                                           child: Text(
                                                                             "No",
                                                                             style: TextStyle(
                                                                               color: Colors.black,
                                                                             ),
                                                                           ),
                                                                           onPressed: () {
                                                                             Navigator.pop(context);
                                                                           },
                                                                         )
                                                                       ],
                                                                     ),
                                                                   )
                                                                 ],
                                                               );
                                                             });
                                                    }
                                                  ),
                                                  SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                                                  ListTile(
                                                    title: Text('Turn off commenting',style: TextStyle(fontWeight: FontWeight.bold)),
                                                    subtitle: Text('No one can comment on your post'),
                                                  ),
                                                ],
                                              )
                                            );
                                          }
                                        );
                                         // showDialog(
                                         //    context:
                                         //    context,
                                         //    builder:
                                         //        (BuildContext
                                         //    context) {
                                         //      return AlertDialog(
                                         //        backgroundColor:
                                         //        Colors
                                         //            .white,
                                         //        title: Text(
                                         //            "Select Option"),
                                         //        actions: <
                                         //            Widget>[
                                         //          Padding(
                                         //            padding:
                                         //            const EdgeInsets.only(right: 120.0),
                                         //            child:
                                         //            Column(
                                         //              children: [
                                         //                MaterialButton(
                                         //                  child: Text(
                                         //                    "yes",
                                         //                    style: TextStyle(
                                         //                      color: Colors.red,
                                         //                    ),
                                         //                  ),
                                         //                  onPressed: () {
                                         //                    deletePost(displayNamecurrentUser, displayName, postId, uidX);
                                         //                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HomePage(initialindexg: 3)));
                                         //                  },
                                         //                ),
                                         //                MaterialButton(
                                         //                  child: Text(
                                         //                    "No",
                                         //                    style: TextStyle(
                                         //                      color: Colors.black,
                                         //                    ),
                                         //                  ),
                                         //                  onPressed: () {
                                         //                    Navigator.pop(context);
                                         //                  },
                                         //                )
                                         //              ],
                                         //            ),
                                         //          )
                                         //        ],
                                         //      );
                                         //    });
                                        //deletePost(displayNamecurrentUser, displayName, postId, uidX);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                              onDoubleTap: () async {
                                if (likess[index] == false) {
                                  setState(() {
                                    likess[index] = true;
                                    //print(_liked);
                                  });

                                  await DatabaseService().likepost(
                                      likes,
                                      postId,
                                      uidX,
                                      displayNameController.text);
                                }
                              },
                              onTap: null,
                              child: Container(
                                height: 350.0,
                                child: GestureDetector(
                                  child: (cam == 1)
                                      ? Transform(
                                    alignment:
                                    Alignment.center,
                                    transform:
                                    Matrix4.rotationY(
                                        math.pi),
                                    child: FadeInImage(
                                      image:
                                      NetworkImage(url),
                                      fit: BoxFit.cover,
                                      //image: NetworkImage("posts[i].postImage"),
                                      placeholder: AssetImage(
                                          "assets/images/loading.gif"),
                                      width: MediaQuery.of(
                                          context)
                                          .size
                                          .width,
                                    ),
                                  )
                                      : FadeInImage(
                                    image: NetworkImage(
                                      url,
                                    ),
                                    fit: BoxFit.cover,
                                    placeholder: AssetImage(
                                        "assets/images/loading.gif"),
                                    width:
                                    MediaQuery.of(context)
                                        .size
                                        .width,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    IconButton(
                                      padding:
                                      EdgeInsets.only(left: 10),

                                      onPressed: (likess[index] ==
                                          true)
                                          ? () {
                                        if (timer?.isActive ??
                                            false)
                                          timer
                                              .cancel(); //cancel if [timer] is null or running
                                        timer = Timer(
                                          const Duration(
                                              milliseconds:
                                              340),
                                              () {
                                            setState(() {
                                              likess[index] =
                                              false;
                                              loading = true;
                                            });
                                            DatabaseService()
                                                .unlikepost(
                                                likes,
                                                postId,
                                                uidController
                                                    .text,
                                                displayNameController
                                                    .text);
                                          },
                                        );
                                      }
                                          : () {
                                        if (timer?.isActive ??
                                            false)
                                          timer
                                              .cancel(); //cancel if [timer] is null or running
                                        timer = Timer(
                                          const Duration(
                                              milliseconds:
                                              340),
                                              () {
                                            setState(() {
                                              likess[index] =
                                              true;
                                              loading = true;
                                            });
                                            DatabaseService()
                                                .likepost(
                                                likes,
                                                postId,
                                                uidController
                                                    .text,
                                                displayNameController
                                                    .text);
                                          },
                                        );
                                      },
                                      icon: Icon(Icons.thumb_up),
                                      iconSize: 25,
                                      color: (likess[index] == true)
                                          ? Colors.deepPurple
                                          : Colors.grey,
                                    ),
                                    Text(
                                      likes.toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          top: 3.0),
                                      child: IconButton(
                                        onPressed: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (context) {
                                                    return CommentsPage(
                                                        comments: comments,
                                                        postId: postId,
                                                        uid: uid,
                                                        postImageUrl: url,
                                                        timestamp:
                                                        timestamp,
                                                        displayName:
                                                        displayName,
                                                        photoUrl:
                                                        photoUrlController
                                                            .text,
                                                        displayNamecurrentUser:
                                                        displayNameController
                                                            .text);
                                                  }));
                                        },
                                        icon: Icon(
                                            Icons.insert_comment,
                                            color: Colors
                                                .deepPurpleAccent),
                                      ),
                                    ),
                                    Text(comments.toString()),
                                    IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => UploadImage(
                                                  ownerPostId:
                                                  postId,
                                                  shares: shares,
                                                  file: File(url),
                                                  sharedurl: url,
                                                  ownerdiscription:
                                                  description,
                                                  ownerphotourl:
                                                  photoUrl,
                                                  ownerdisplayname:
                                                  displayName,
                                                  shared: true,
                                                  cam: cam,
                                                  ownerTimeStamp:
                                                  timestamp)),
                                        );
                                      },
                                      icon: Icon(
                                          FontAwesomeIcons.share,
                                          color: Colors
                                              .deepPurpleAccent),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                                width: MediaQuery.of(context)
                                    .size
                                    .width,
                                margin: EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.90,
                                      child: RichText(
                                        textAlign: TextAlign.start,
                                        softWrap: true,
                                        overflow:
                                        TextOverflow.visible,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: displayName +
                                                  "  ",
                                              style: TextStyle(
                                                  color:
                                                  Colors.black,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  fontSize: 18.0),
                                            ),
                                            TextSpan(
                                              text: description,
                                              style: TextStyle(
                                                  color:
                                                  Colors.black,
                                                  fontWeight:
                                                  FontWeight
                                                      .normal,
                                                  fontSize: 15.0),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            Container(
                              width:
                              MediaQuery.of(context).size.width,
                              margin: EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                            ),
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
                      );
                    },
                  ),
                ),
              ],
            )
                : Container();
          },
        ),
      ),
    );
  }

//  displayComments(BuildContext context, {String postId, String uid, String url,Timestamp timestamp, String displayName, String photoUrl,String displayNamecurrentUser}){
//    Navigator.push(context, MaterialPageRoute(builder: (context){
//    return CommentsPage(postId: postId, uid: uid, postImageUrl: url,timestamp: timestamp,displayName: displayName,photoUrl: photoUrl,displayNamecurrentUser: displayNamecurrentUser);
//    }));
//  }
}