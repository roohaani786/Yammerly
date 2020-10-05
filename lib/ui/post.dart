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
import 'package:techstagram/models/wiggle.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/ui/Otheruser/other_user.dart';
import 'package:techstagram/ui/ProfileEdit.dart';
import 'package:techstagram/ui/ProfilePage.dart';
import 'package:techstagram/views/tabs/comments_screen.dart';
//import 'package:techstagram/services/database.dart';
//import 'package:techstagram/ui/Otheruser/other_aboutuser.dart';
//
//import '../../constants3.dart';


class postPage extends StatefulWidget {


  @override

  final String PostUrl;
  final String displayNamecurrentUser;
  final Wiggle wiggle;
  final List<Wiggle> wiggles;
  final Timestamp timestamp;
  final String description;
  final String url;
  final String postId;
  final int likes;
  final String uid;
  final String uidX;

  postPage(
      {this.PostUrl,
        this.wiggles,
        this.wiggle,
        this.timestamp,
        this.description,
        this.url,
        this.uid,
        this.postId,
        this.displayNamecurrentUser,
        this.likes,
        this.uidX
      });

  @override
  _postPageState createState() => _postPageState(displayNamecurrentUser: displayNamecurrentUser,PostUrl: PostUrl,uidX: uidX);
}

class _postPageState extends State<postPage> {

  bool isLoading = true;
  bool liked = false;
  bool isEditable = false;
  final String displayNamecurrentUser;
  final String PostUrl;
  final String uidX;

  _postPageState({this.displayNamecurrentUser,this.PostUrl,this.uidX});
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
  final timelineReference = Firestore.instance.collection('posts');
  String postIdX;

  fetchPosts() async {

    getPosts().then((val){
      setState(() {
        postsStream = val;
      });
    });
  }

  deletePost( String displayNamecurrent, String displayName, String postId, String uidX) async {
    //print(displayNamecurrent)


    if(displayName == displayNamecurrentUser){
      print(postId);
      print(displayName);
      print(uidX);
      print("halelula");
      print(displayNamecurrentUser);
      await Firestore.instance.collection('posts').document(postId).delete();
      await Firestore.instance.collection('users').document(uidX)
      .collection('posts').document(postId).delete();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 4,)),
      );

    }else{
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('You are not the owner of this post'),
              actions: <Widget>[
                // FlatButton(
                //     child: Text('Yes'),
                //     onPressed: () {
                //       // return Firestore.instance.collection("posts")
                //       //     .document(url)
                //       //     .delete();
                //
                //       Firestore.instance.collection('posts').document(postId).delete();
                //       // DatabaseService()
                //       //     .postReference
                //       //     .document(widget.postId)
                //       //     .get()
                //       //     .then((doc) {
                //       //   if (doc.exists) {
                //       //     doc.reference.delete();
                //       //
                //       //     Navigator.pop(context);
                //       //   }
                //       // });
                //     }),
              ],
            );
          });
    }
  }


  getPosts() async {
    print(PostUrl);
    return Firestore.instance
        .collection("posts")
        .where('url', isEqualTo: PostUrl)
        .snapshots();
  }



//  void _onHorizontalDrag(DragEndDetails details) {
//    if (details.primaryVelocity == 0)
//      // user have just tapped on screen (no dragging)
//      return ;
//
//    if (details.primaryVelocity.compareTo(0) == -1) {
////      dispose();
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 3)),
//      );
//    }
//    else {
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 1)),
//      );
//    }
//  }


  getlikes( String displayNamecurrent, String postId) {


    Firestore.instance.collection('posts')
        .document(postId)
        .collection('likes')
        .document(displayNameController.text)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          liked = true;

        });
      }
    });

  }

  fetchLikes() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {
      docSnap = await Firestore.instance
          .collection("likes")
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
      displayNameController.text = docSnap.data["displayName"];
      photoUrlController.text = docSnap.data["photoURL"];


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


  File _image;
  bool upload;

  createAlertDialog(context,url) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Are you sure you want to delete post?'),
            actions: <Widget>[
              FlatButton(
                  child: Text('Yes'),
                  onPressed: () {
                    // return Firestore.instance.collection("posts")
                    //     .document(url)
                    //     .delete();

                    Firestore.instance.collection("posts").document(url).get()
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
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
        upload = true;
      });
    });
    (_image!=null)?
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UploadImage(file: _image,)),
    ):Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage(initialindexg: 2,)),
    );
    print("Done..");
  }

  doubletaplike(int likes, String postId){
    if(liked = false) {
      DatabaseService().likepost(
          likes, postId,
          displayNameController.text);
      setState(() {
        liked = true;
        print(liked);
      });
    }
    else if (liked = true){
      DatabaseService().unlikepost(
          likes, postId,
          displayNameController.text);
      setState(() {
        liked = false;
        print(liked);
      });

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
          title: Text("Post", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.normal),),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.black,), onPressed: (){
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
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {

                        postIdX = snapshot.data.documents[index]['email'];
                        String email = snapshot.data.documents[index]['email'];
                        String description =
                        snapshot.data.documents[index]['description'];
                        String displayName =
                        snapshot.data.documents[index]['displayName'];
                        String photoUrl =
                        snapshot.data.documents[index]['photoURL'];
                        String uid = snapshot.data.documents[index]["uid"];

                        Timestamp timestamp =
                        snapshot.data.documents[index]['timestamp'];
                        String url = snapshot.data.documents[index]['url'];
                        String postId = snapshot.data.documents[index]['postId'];
                        int likes = snapshot.data.documents[index]['likes'];
                        int comments = snapshot.data.documents[index]['comments'];
                        readTimestamp(timestamp.seconds);


                        getlikes(displayNameController.text,postId);
//                        fetchdimensions(url);




                        if(likes == 0){

                          liked = false;
                        }

                        //getlikes(displayNameController.text,postId);

                        return Container(
                          child: Container(
                            color: Colors.white,
                            child: Column(
                              children: <Widget>[
                                (index == 0)?Container(
                                  color: Colors.transparent,
                                  // child: Row(
                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                  //   children: [
                                  //     FlatButton(
                                  //       onPressed:
                                  //           (){
                                  //         pickImage();
                                  //         if (upload == true){
                                  //           Navigator.push(
                                  //               context,
                                  //               MaterialPageRoute(builder: (context) => UploadImage(file: _image),));
                                  //         }else{
                                  //           Navigator.push(
                                  //               context,
                                  //               MaterialPageRoute(builder: (context) => HomePage(initialindexg: 2,),));
                                  //         }
                                  //       },
                                  //       color: Colors.transparent,
                                  //       child: Row(
                                  //         children: [
                                  //           Icon(FontAwesomeIcons.plus,color: Colors.deepPurpleAccent,),
                                  //           Padding(
                                  //             padding: const EdgeInsets.all(8.0),
                                  //             child: Text("Add Post",style:
                                  //             TextStyle(
                                  //               color: Colors.deepPurpleAccent,
                                  //             ),),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //
                                  //     Padding(
                                  //       padding: const EdgeInsets.only(left: 100.0),
                                  //     ),
                                  //     FlatButton(onPressed: (){},
                                  //       color: Colors.transparent,
                                  //       child: Row(
                                  //         children: [
                                  //           Icon(FontAwesomeIcons.star,color: Colors.deepPurpleAccent,),
                                  //           Padding(
                                  //             padding: const EdgeInsets.all(8.0),
                                  //             child: Text("Rate us",style:
                                  //             TextStyle(
                                  //               color: Colors.deepPurpleAccent,
                                  //             ),),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
                                ):
                                Container(height: 0.0,width: 0.0,),

                                // GestureDetector(
                                //   onTap: () => Navigator.push(
                                //     context,
                                //     MaterialPageRoute(builder: (context) => OtherUserProfile(uid: uid,displayNamecurrentUser: displayNamecurrentUser,displayName: displayName)),
                                // ),
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
                                          icon: Icon(Icons.delete_outline, color: Colors.purple,),
                                          //onPressed: () => createAlertDialog(context,url),
                                          onPressed: () => deletePost(displayNamecurrentUser, displayName,postId,uidX),

                                        ),
                                      ],
                                    ),
                                  ),
                                //),


                                GestureDetector(
                                  onDoubleTap: (){
                                    print("double tap");
                                    print(liked);
                                    doubletaplike(likes,postId);
                                    print("double tap again");
                                    print(liked);
                                  },
                                  onTap: null,

                                  child: InteractiveViewer(
                                    transformationController: _controller,
                                    onInteractionEnd: (value){
                                      _controller.value = Matrix4.identity();
                                    },
                                    child: FadeInImage(
                                      image: NetworkImage(url),
                                      //image: NetworkImage("posts[i].postImage"),
                                      placeholder: AssetImage("assets/images/loading.gif"),
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),

                                ),


                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        (liked == false)?IconButton(
                                          onPressed: () {
                                            DatabaseService().likepost(
                                                likes, postId, displayNameController.text);
                                            setState(() {
                                              liked = true;
                                            });
                                          },
                                          icon: Icon(FontAwesomeIcons.thumbsUp),
                                          color: Colors.deepPurple,
                                          // onPressed: () {
                                          // },
                                          // icon: Icon(FontAwesome.thumbs_up,color: Colors.deepPurple,),
                                        ):IconButton(

                                          onPressed: () {
                                            DatabaseService().unlikepost(
                                                likes, postId, displayNameController.text);
                                            setState(() {
                                              liked = false;
                                            });
                                          },

                                          icon: Icon(FontAwesomeIcons.solidThumbsUp),

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

                                        Padding(
                                          padding: const EdgeInsets.only(top: 3.0),
                                          child: IconButton(

                                            onPressed: () { print(displayNameController.text);
                                            Navigator.push(context, MaterialPageRoute(builder: (context){
                                              return CommentsPage(comments: comments,postId: postId, uid: uid, postImageUrl: url,timestamp: timestamp,displayName: displayName,photoUrl: photoUrlController.text,displayNamecurrentUser: displayNameController.text);
                                              //return CommentsPage(postId: postId, uid: uid, postImageUrl: url,timestamp: timestamp,displayName: displayName,photoUrl: photoUrlController.text,displayNamecurrentUser: displayNameController.text);
                                            }));
                                            },
                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: ((context) => CommentsScreen())));

                                            icon: Icon(Icons.insert_comment,color: Colors.deepPurpleAccent),
                                          ),
                                        ),
                                        Text(comments.toString()),
                                        // IconButton(
                                        //   onPressed: () {},
                                        //   icon: Icon(Icons.share,color: Colors.deepPurpleAccent),
                                        // ),
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
                                    child: Row(
                                      children: [
                                        Container(
                                          child: RichText(
                                            softWrap: true,
                                            overflow: TextOverflow.visible,
                                            text: TextSpan(
                                              text: displayName,
                                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,),
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.only(left: 3.0),
                                          child: Container(

                                            constraints: BoxConstraints(maxWidth: 250),
                                            child: RichText(
                                              softWrap: true,
                                              overflow: TextOverflow.visible,
                                              text: TextSpan(
                                                text: description,
                                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                                    fontSize: 15.0),

                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
      ),
    );
  }

//  displayComments(BuildContext context, {String postId, String uid, String url,Timestamp timestamp, String displayName, String photoUrl,String displayNamecurrentUser}){
//    Navigator.push(context, MaterialPageRoute(builder: (context){
//    return CommentsPage(postId: postId, uid: uid, postImageUrl: url,timestamp: timestamp,displayName: displayName,photoUrl: photoUrl,displayNamecurrentUser: displayNamecurrentUser);
//    }));
//  }
}


