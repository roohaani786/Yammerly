import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/models/posts.dart';
import 'package:uuid/uuid.dart';
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
import 'package:techstagram/views/tabs/comments_screen.dart';
//import 'package:techstagram/services/database.dart';
//import 'package:techstagram/ui/Otheruser/other_aboutuser.dart';
//
//import '../../constants3.dart';
import 'dart:convert';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'dart:math' as math;


class FeedsPage extends StatefulWidget {
  final displayNamecurrentUser;
  @override

  final Wiggle wiggle;
  final List<Wiggle> wiggles;
  final Timestamp timestamp;
  final String description;
  final String url;
  final String postId;
  final int likes;
  final String uid;

  FeedsPage(
      {this.wiggles,
        this.wiggle,
        this.timestamp,
        this.description,
        this.url,
        this.uid,
        this.postId,
        this.displayNamecurrentUser,
        this.likes});

  @override
  _FeedsPageState createState() => _FeedsPageState(displayNamecurrentUser: displayNamecurrentUser);
}

class _FeedsPageState extends State<FeedsPage> {

  bool isLoading = true;
  bool isEditable = false;
  final String displayNamecurrentUser;

  _FeedsPageState({this.displayNamecurrentUser,this.postIdX});
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


  double _scale = 1.0;
  double _previousScale;
  var yOffset = 400.0;
  var xOffset = 50.0;
  var rotation = 0.0;
  var lastRotation = 0.0;

//   savePostInfoToFirestore(String url, String description, String ownerphotourl, String ownerdisplayname, bool shared) {
//     String postId = Uuid().v4();
//
//     Firestore.instance.collection("posts").document(postId).setData({
//       "OwnerPhotourl" : ownerphotourl,
//       "OwnerDisplayName" : ownerdisplayname,
//       "shared" : shared,
//       "postId": postId,
//       "uid" : uidController.text,
//       "displayName": displayNameController.text,
//       "timestamp": Timestamp.now(),
//       "email": emailController.text,
//       "photoURL" :photoUrlController.text,
// //      "email": widget.userData.email,
//       "description": descriptionController.text,
//       "cam": cam,
//       "likes": 0,
//       "comments": 0,
//       "url": url,
// //      "photourl": widget.userData.photoUrl,
//     });
//
//   }




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
    fetchLikes();
  }


  Stream<QuerySnapshot> postsStream;
  final timelineReference = Firestore.instance.collection('posts');
  String postIdX;
  bool postliked = false;
  bool _liked = false;

  fetchPosts() async {

    await DatabaseService().getPosts().then((val){
      setState(() {
        postsStream = val;
      });
    });
  }



  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0)
      // user have just tapped on screen (no dragging)
      return ;

    if (details.primaryVelocity.compareTo(0) == -1) {
//      dispose();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 3)),
      );
    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 1)),
      );
    }
  }


  getlikes( String displayNamecurrent, String postId) async {

    print(displayNamecurrent);
    print(postId);

    await Firestore.instance.collection('posts')
        .document(postIdX)
        .collection('likes')
        .document(displayNamecurrent)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          _liked = true;
          print(_liked);
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
      if (diff.inHours > 0) {
        time = "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
      }

      else if (diff.inSeconds <= 0) {
        time = "just now";
      }


      else if (diff.inMinutes > 0) {
        time = "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
      }
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    }



    else {
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
  int likescount;
  bool loading = false;

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

//  doubletaplike(int likes, String postId)  {
//
//
//
//    if(_liked == false) {
//      setState(() {
//        _liked = true;
//      });
//      DatabaseService().likepost(
//          likes, postId,
//          displayNameController.text);
//
//    }else{
//      print("ghg");
//    }
//
//  }
  String urlx;

  TransformationController _controller = TransformationController();



  @override
  Widget build(BuildContext context) {


    // TODO: implement build
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) =>
          _onHorizontalDrag(details),
      onTap: () {
        print("hello");
      },
      child: Scaffold(
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

                        postIdX = snapshot.data.documents[index]['postId'];
                        getlikes(displayNameController.text, postIdX);
                        String email = snapshot.data.documents[index]['email'];
                        String description =
                        snapshot.data.documents[index]['description'];
                        String displayName =
                        snapshot.data.documents[index]['displayName'];
                        String photoUrl =
                        snapshot.data.documents[index]['photoURL'];
                        String OwnerDisplayName = snapshot.data.documents[index]['OwnerDisplayName'];
                        String OwnerPhotourl = snapshot.data.documents[index]['OwnerPhotourl'];
                        bool shared = snapshot.data.documents[index]['shared'];
                        String uid = snapshot.data.documents[index]["uid"];

                        Timestamp timestamp =
                        snapshot.data.documents[index]['timestamp'];
                        String url = snapshot.data.documents[index]['url'];
                        int cam = snapshot.data.documents[index]['cam'];
                        String postId = snapshot.data.documents[index]['postId'];
                        int likes = snapshot.data.documents[index]['likes'];
                        int counter = snapshot.data.documents[index]['likes'];
                        int comments = snapshot.data.documents[index]['comments'];
                        likescount = likes;
                        readTimestamp(timestamp.seconds);

//                        getlikes(displayNameController.text, postId);





                        if(likes == 0){

                          _liked = false;
                        }
                     return (shared==true)?Container(

                              color: Colors.white,
                     child: Column(
                              children: <Widget>[
                               Container(height: 0.0,width: 0.0,),

                                GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OtherUserProfile(uid: uid,displayNamecurrentUser: displayNameController.text,displayName: displayName,uidX: uidController.text,)),
                                ),
                                child: Container(
                                  padding: EdgeInsets.only(
                                    top: 10,
                                    left: 10,
                                    right: 10.0,
                                  ),
                                  // padding: EdgeInsets.symmetric(
                                  //   horizontal: 10,
                                  //   vertical: 10,
                                  // ),
                                  child: Column(
                                    children: [
                                      Row(
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
                                              Text(displayName,style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18.0,
                                              ),),
                                            ],
                                          ),
                                          IconButton(
                                            icon: Icon(SimpleLineIcons.options),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),

                                    ],
                                  ),

                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 1.0),
                                child: Container(
                                  height: 50.0,
                                  color: Colors.white54,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 15.0,right: 15.0,),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(40),

                                              child: Image(
                                                image: NetworkImage(OwnerPhotourl),
                                                width: 30,
                                                height: 30,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(OwnerDisplayName,style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(SimpleLineIcons.options,size: 20.0,),
                                          onPressed: () {},
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),


                              GestureDetector(
                                onDoubleTap: () async {


                                  if (_liked == false) {
                                    setState(() {
                                      _liked = true;
                                      print(_liked);
                                    });
                                    await DatabaseService().likepost(
                                        likes, postId,
                                        displayNameController.text);

//                                     return liked;
                                  } else {
                                    print("nahi");
                                  }
                                },
                                onTap: null,

                                child: Container(
                                  height: 350.0,
                                  child: GestureDetector(

                                    child :(cam == 1)?Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: FadeInImage(

                                        image: NetworkImage(url),
                                        fit: BoxFit.cover,
                                        //image: NetworkImage("posts[i].postImage"),
                                        placeholder: AssetImage("assets/images/loading.gif"),
                                        width: MediaQuery.of(context).size.width,

                                      ),
                                    ):FadeInImage(

                                      image: NetworkImage(url),
                                      fit: BoxFit.cover,
                                      //image: NetworkImage("posts[i].postImage"),
                                      placeholder: AssetImage("assets/images/loading.gif"),
                                      width: MediaQuery.of(context).size.width,



                                    ),
                                  ),
                                ),
                              ),





                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[

                                      IgnorePointer(
                                        ignoring: (loading == true)?true:false,
                                        ignoringSemantics: true,
                                        child: IconButton(
                                          padding: EdgeInsets.only(left: 10),
                                          onPressed: (_liked == true)
                                              ? () {
                                            setState(() {
                                              _liked = false;
                                              loading = true;
//                                              likes--;
                                              DatabaseService().unlikepost(
                                                  likes, postId,displayNameController.text);
                                              loading = false;
                                            });
                                          }
                                              : () {
                                            setState(() {
                                              _liked = true;
                                              loading = true;
//                                              likes++;
                                              DatabaseService().likepost(
                                                  likes, postId,displayNameController.text);
                                              loading = false;
                                            });
                                          },
                                          icon: Icon(Icons.thumb_up),
                                          iconSize: 25,
                                          color: (_liked == true) ? Colors.deepPurple : Colors.grey,
                                        ),
                                      ),

                                      Text(
                                        likes.toString(),style: TextStyle(
                                        color: Colors.black,
                                      ),

                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(top: 3.0),
                                        child: IconButton(

                                          onPressed: () { //print(displayNameController.text);
                                            Navigator.push(context, MaterialPageRoute(builder: (context){
                                              return CommentsPage(comments: comments,postId: postId, uid: uid, postImageUrl: url,timestamp: timestamp,displayName: displayName,photoUrl: photoUrlController.text,displayNamecurrentUser: displayNameController.text);
                                            }));
                                          },


                                          icon: Icon(Icons.insert_comment,color: Colors.deepPurpleAccent),
                                        ),
                                      ),
                                      Text(comments.toString()),

                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => UploadImage(file: File(url),sharedurl: url,ownerdiscription: description,ownerphotourl: photoUrl,ownerdisplayname: displayName,shared: true,cam: cam,)),
                                          );

                                          //savePostInfoToFirestore(url,description,photoUrl,displayName,true);
                                        },
                                        icon: Icon(FontAwesomeIcons.share,color: Colors.deepPurpleAccent),
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
                                  child: Row(
                                    children: [
                                      Container(
                                        child: RichText(
                                          textAlign: TextAlign.start,
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: displayName + "  ",
                                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,
                                                    fontSize: 18.0),
                                              ),
                                              TextSpan(
                                                text: description,
                                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                                    fontSize: 15.0),
                                              ),
                                            ],
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
                        ):Container(
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              Container(height: 0.0,width: 0.0,),

                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => OtherUserProfile(uid: uid,displayNamecurrentUser: displayNameController.text,displayName: displayName,uidX: uidController.text,)),
                                ),
                                child: Container(
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
                                          Text(displayName,style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.0,
                                          ),),
                                        ],
                                      ),
                                      IconButton(
                                        icon: Icon(SimpleLineIcons.options),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ),


                              GestureDetector(
                                onDoubleTap: () async {


                                  if (_liked == false) {
                                    setState(() {
                                      _liked = true;
                                      print(_liked);
                                    });
                                    await DatabaseService().likepost(
                                        likes, postId,
                                        displayNameController.text);

//                                     return liked;
                                  } else {
                                    print("nahi");
                                  }
                                },
                                onTap: null,

                                child: Container(
                                  height: 350.0,
                                  child: GestureDetector(

                                    child :(cam == 1)?Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(math.pi),
                                      child: FadeInImage(

                                        image: NetworkImage(url),
                                        fit: BoxFit.cover,
                                        //image: NetworkImage("posts[i].postImage"),
                                        placeholder: AssetImage("assets/images/loading.gif",),
//                                        width: MediaQuery.of(context).size.width,



                                      ),
                                    ):FadeInImage(

                                      image: NetworkImage(url,),
                                      fit: BoxFit.cover,

                                      //image: NetworkImage("posts[i].postImage"),
                                      placeholder: AssetImage("assets/images/loading.gif"),
                                      width: MediaQuery.of(context).size.width,



                                    ),
                                  ),
                                ),
                              ),






                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[

                                      IgnorePointer(
                                        ignoring: (loading == true)?true:false,
                                        ignoringSemantics: true,
                                        child: IconButton(
                                          padding: EdgeInsets.only(left: 10),
                                          onPressed: (_liked == true)
                                              ? () {
                                            setState(() {
                                              _liked = false;
                                              loading = true;
//                                              likes--;
                                              DatabaseService().unlikepost(
                                                  likes, postId,displayNameController.text);
                                              loading = false;
                                            });
                                          }
                                              : () {
                                            setState(() {
                                              _liked = true;
                                              loading = true;
//                                              likes++;
                                              DatabaseService().likepost(
                                                  likes, postId,displayNameController.text);
                                              loading = false;
                                            });
                                          },
                                          icon: Icon(Icons.thumb_up),
                                          iconSize: 25,
                                          color: (_liked == true) ? Colors.deepPurple : Colors.grey,
                                        ),
                                      ),

                                      Text(
                                        likes.toString(),style: TextStyle(
                                        color: Colors.black,
                                      ),

                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(top: 3.0),
                                        child: IconButton(

                                          onPressed: () { //print(displayNameController.text);
                                            Navigator.push(context, MaterialPageRoute(builder: (context){
                                              return CommentsPage(comments: comments,postId: postId, uid: uid, postImageUrl: url,timestamp: timestamp,displayName: displayName,photoUrl: photoUrlController.text,displayNamecurrentUser: displayNameController.text);
                                            }));
                                          },


                                          icon: Icon(Icons.insert_comment,color: Colors.deepPurpleAccent),
                                        ),
                                      ),
                                      Text(comments.toString()),

                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => UploadImage(file: File(url),sharedurl: url,ownerdiscription: description,ownerphotourl: photoUrl,ownerdisplayname: displayName,shared: true,cam: cam,)),
                                          );

                                          //savePostInfoToFirestore(url,description,photoUrl,displayName,true);
                                        },
                                        icon: Icon(FontAwesomeIcons.share,color: Colors.deepPurpleAccent),
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
                                  child: Row(
                                    children: [
                                      Container(
                                        child: RichText(
                                          textAlign: TextAlign.start,
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: displayName + "  ",
                                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,
                                                    fontSize: 18.0),
                                              ),
                                              TextSpan(
                                                text: description,
                                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                                    fontSize: 15.0),
                                              ),
                                            ],
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
}

class Student {
  var name = 'foo';
  var year = '2018';
  var liked = false;

  Student(this.name);
}