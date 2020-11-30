import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/models/posts.dart';
//import 'package:techstagram/models/users.dart';
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
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'dart:math' as math;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class Feed extends StatefulWidget {

  final displayNamecurrentUser;
  @override

  Feed({
    this.displayNamecurrentUser,
  });
  _FeedState createState() => _FeedState(displayNamecurrentUser: displayNamecurrentUser);
}

class _FeedState extends State<Feed> {
  Stream<QuerySnapshot> postsStream;
  final String displayNamecurrentUser;
  final timelineReference = Firestore.instance.collection('posts');
  ScrollController scrollController = new ScrollController();
  String postIdX;


  // retrieveTimeline() async {
  //   DatabaseService().getPosts().then((val) {
  //     setState(() {
  //       postsStream = val;
  //     });
  //   });
  // }

  Widget feedList() {
    return StreamBuilder(
      stream: postsStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
            controller: scrollController,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) {

              String email = snapshot.data.documents[index]['email'];

              String description = snapshot.data.documents[index]['description'];

              String displayName = snapshot.data.documents[index]['displayName'];

              String photoUrl = snapshot.data.documents[index]['photoURL'];

              String OwnerDisplayName = snapshot.data.documents[index]['OwnerDisplayName'];

              String OwnerPhotourl = snapshot.data.documents[index]['OwnerPhotourl'];

              bool shared = snapshot.data.documents[index]['shared'];

              String uid = snapshot.data.documents[index]["uid"];

              int shares = snapshot.data.documents[index]["shares"];

              Timestamp timestamp = snapshot.data.documents[index]['timestamp'];

              String url = snapshot.data.documents[index]['url'];

              int cam = snapshot.data.documents[index]['cam'];

              String postId = snapshot.data.documents[index]['postId'];

              int likes = snapshot.data.documents[index]['likes'];

              int comments = snapshot.data.documents[index]['comments'];

              //readTimestamp(timestamp.seconds);
              print("aya bhai");

              return FeedTile(
                description: description,
                timestamp: timestamp,
                url: url,
                postId: postId,
                likes: likes,
                email: email,
                displayName: displayName,
                photoUrl: photoUrl,
                OwnerDisplayName: OwnerDisplayName,
                OwnerPhotourl: OwnerPhotourl,
                shared: shared,
                uid: uid,
                shares: shares,
                cam: cam,
                comments: comments,
              );
            })
            : Container();
      },
    );
  }

  @override
  _FeedState({this.displayNamecurrentUser,this.postIdX});

  void initState() {
    //retrieveTimeline();
    super.initState();
    fetchPosts();
  }

  fetchPosts() async {

    await DatabaseService().getPosts().then((val){
      setState(() {
        postsStream = val;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, height: 869, width: 414, allowFontScaling: true);
    //final wiggles = Provider.of<List<Wiggle>>(context) ?? [];
    final user = Provider.of<User>(context);
    return StreamBuilder(
        stream: postsStream,
        builder: (context, snapshot) {
          //UserData userData = snapshot.data;
          return Scaffold(
            body: feedList(),
          );
          // RefreshIndicator(
          //     child: createTimeLine(), onRefresh: () => retrieveTimeline()));
        });
  }
}

class FeedTile extends StatefulWidget {
  final Timestamp timestamp;
  final String description;
  final String url;
  final String postId;
  final int likes;
  final String email;
  final String displayName;
  final String photoUrl;
  final String OwnerDisplayName;
  final String OwnerPhotourl;
  final bool shared;
  final String uid;
  final int shares;
  final int cam;
  final int comments;


  FeedTile(
      { this.uid,
        this.shares,
        this.cam,
        this.comments,
        this.shared,
        this.OwnerPhotourl,
        this.OwnerDisplayName,
        this.photoUrl,
        this.displayName,
        this.email,
        this.timestamp,
        this.description,
        this.url,
        this.postId,
        this.likes});

  @override
  _FeedTileState createState() => _FeedTileState();
}

class _FeedTileState extends State<FeedTile> {
  final f = new DateFormat('h:mm a');
  Stream<QuerySnapshot> postsStream;
  int likeint;
  bool _liked;
  var like = new List();
  bool shared = false;
  FirebaseUser currUser;
  DocumentSnapshot docSnap;
  bool loading =  true;

  TextEditingController emailController,urlController,descriptionController,
      displayNameController,photoUrlController,
      timestampController,likesController,uidController;


  bool check;
  //bool liked = false;
  @override
  void initState() {
    emailController = TextEditingController();
    likesController = TextEditingController();
    uidController = TextEditingController();
    displayNameController = TextEditingController();
    photoUrlController = TextEditingController();


    getlikes();
    // TODO: implement initState
    super.initState();
    fetchPosts();
  }

  fetchPosts() async {

    await DatabaseService().getPosts().then((val){
      setState(() {
        postsStream = val;
      });
    });
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
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  getlikes() async {

    await Firestore.instance.collection('posts')
        .document(widget.postId)
        .collection('likes')
        .document(widget.displayName)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          likeint = int.parse(widget.postId);
          _liked = true;
          like[likeint] = "true";
        });
      }else{
        setState(() {
          likeint = int.parse(widget.postId);
          _liked = false;
          like[likeint] = "false";
        });
      }
    });
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
//    var format = DateFormat('HH:mm a');
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print("or andar aa gaya");
    print(widget.uid);

    return StreamBuilder(
        stream: postsStream,
        builder: (context, snapshot) {
         // UserData userData = snapshot.data;
          return snapshot.hasData
              ? Column(
            children: [

                    // if(likes == 0){
                    //
                    //   _liked = false;
                    //   like[likeint] = "false";
                    // }

                    (shared==true)?Container(
                      color: Colors.white,
                      child: Column(
                        children: <Widget>[
                          Container(height: 0.0,width: 0.0,),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => OtherUserProfile(uid: widget.uid,displayNamecurrentUser: displayNameController.text,displayName: widget.displayName,uidX: uidController.text,)),
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[

                                      Row(
                                        children: <Widget>[

                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(40),
                                            child: Image(
                                              image: NetworkImage(widget.photoUrl),
                                              width: 40,
                                              height: 40,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(widget.displayName,style: TextStyle(
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
                              color: Colors.grey.shade50,
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
                                            image: NetworkImage(widget.OwnerPhotourl),
                                            width: 30,
                                            height: 30,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(widget.OwnerDisplayName,style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12.0,
                                        ),),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),


                          GestureDetector(
                            onDoubleTap: () {

                              if (_liked == false) {
                                setState(() {
                                  _liked = true;
                                });

                                DatabaseService().likepost(
                                    widget.likes, widget.postId,
                                    displayNameController.text);
                              }
                            },
                            onTap: null,

                            child: Container(
                              height: 350.0,
                              child: GestureDetector(
                                child : (widget.cam == 1)? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(math.pi),
                                  child: FadeInImage(
                                    image: NetworkImage(widget.url),
                                    fit: BoxFit.cover,
                                    //image: NetworkImage("posts[i].postImage"),
                                    placeholder: AssetImage("assets/images/loading.gif"),
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                ):FadeInImage(
                                  image: NetworkImage(widget.url),
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

                                  IconButton(
                                    padding: EdgeInsets.only(left: 10),
                                    onPressed: (like[likeint] == "true")
                                        ? () {
                                      setState(() {
                                        _liked = false;
                                        like[likeint] = "false";
                                        loading = true;
                                      });

                                      DatabaseService().unlikepost(
                                          widget.likes, widget.postId,displayNameController.text);

                                      setState(() {
                                        loading = false;
                                      });
                                    }
                                        : () {
                                      setState(() {
                                        _liked = true;
                                        like[likeint] = "true";
                                        loading = true;
                                      });

                                      DatabaseService().likepost(
                                          widget.likes, widget.postId,displayNameController.text);

                                      setState(() {
                                        loading = false;
                                      });
                                    },
                                    icon: Icon(Icons.thumb_up),
                                    iconSize: 25,
                                    color: (like[likeint] == "true") ? Colors.deepPurple : Colors.grey,
                                  ),

                                  Text(
                                    widget.likes.toString(),style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.0),
                                    child: IconButton(

                                      onPressed: () {

                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                          return CommentsPage(comments: widget.comments,postId: widget.postId, uid: widget.uid, postImageUrl: widget.url,timestamp: widget.timestamp,displayName: widget.displayName,photoUrl: photoUrlController.text,displayNamecurrentUser: displayNameController.text);
                                        }));

                                      },


                                      icon: Icon(Icons.insert_comment,color: Colors.deepPurpleAccent),
                                    ),
                                  ),

                                  Text(widget.comments.toString()),

                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => UploadImage(ownerPostId: widget.postId,file: File(widget.url),sharedurl: widget.url,ownerdiscription: widget.description,ownerphotourl: widget.photoUrl,ownerdisplayname: widget.displayName,shared: true,cam: widget.cam,)),
                                      );
                                    },
                                    icon: Icon(FontAwesomeIcons.share,color: Colors.deepPurpleAccent),
                                  ),
                                ],
                              ),
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
                                            text: widget.displayName + "  ",
                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,
                                                fontSize: 18.0),
                                          ),
                                          TextSpan(
                                            text: widget.description,
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
                              readTimestamp(widget.timestamp.seconds),
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

                          Container(
                            height: 0.0,width: 0.0,
                          ),

                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => OtherUserProfile(uid: widget.uid,displayNamecurrentUser: displayNameController.text,displayName: widget.displayName,uidX: uidController.text,)),
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
                                          image: NetworkImage(widget.photoUrl),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(widget.displayName,style: TextStyle(
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
                                    widget.likes, widget.postId,
                                    displayNameController.text);
                              }
                            },
                            onTap: null,

                            child: Container(
                              height: 350.0,
                              child: GestureDetector(

                                child :(widget.cam == 1)?Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.rotationY(math.pi),
                                  child: FadeInImage(
                                    image: NetworkImage(widget.url),
                                    fit: BoxFit.cover,
                                    //image: NetworkImage("posts[i].postImage"),
                                    placeholder: AssetImage("assets/images/loading.gif"),
                                    width: MediaQuery.of(context).size.width,
                                  ),

                                ):FadeInImage(
                                  image: NetworkImage(widget.url,),
                                  fit: BoxFit.cover,
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
                                      onPressed: (like[likeint] == "true")
                                          ? () {
                                        setState(() {
                                          _liked = false;
                                          like[likeint] = "false";
                                          loading = true;
//                                              likes--;
                                          DatabaseService().unlikepost(
                                              widget.likes, widget.postId,displayNameController.text);
                                          loading = false;
                                        });
                                      }
                                          : () {
                                        setState(() {
                                          _liked = true;
                                          like[likeint] = "true";
                                          loading = true;
                                          DatabaseService().likepost(
                                              widget.likes, widget.postId,displayNameController.text);
                                          loading = false;
                                        });
                                      },
                                      icon: Icon(Icons.thumb_up),
                                      iconSize: 25,
                                      color: (like[likeint] == "true") ? Colors.deepPurple : Colors.grey,
                                    ),
                                  ),

                                  Text(
                                    widget.likes.toString(),style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  ),

                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.0),
                                    child: IconButton(

                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context){
                                          return CommentsPage(comments: widget.comments,postId: widget.postId, uid: widget.uid, postImageUrl: widget.url,timestamp: widget.timestamp,displayName: widget.displayName,photoUrl: photoUrlController.text,displayNamecurrentUser: displayNameController.text);
                                        }));
                                      },
                                      icon: Icon(Icons.insert_comment,color: Colors.deepPurpleAccent),
                                    ),
                                  ),

                                  Text(widget.comments.toString()),

                                  IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => UploadImage(ownerPostId: widget.postId,shares: widget.shares,file: File(widget.url),sharedurl: widget.url,ownerdiscription: widget.description,ownerphotourl: widget.photoUrl,ownerdisplayname: widget.displayName,shared: true,cam: widget.cam,)),
                                      );
                                    },
                                    icon: Icon(FontAwesomeIcons.share,color: Colors.deepPurpleAccent),
                                  ),
                                ],
                              ),
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
                                            text: widget.displayName + "  ",
                                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,
                                                fontSize: 18.0),
                                          ),
                                          TextSpan(
                                            text: widget.description,
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
                              readTimestamp(widget.timestamp.seconds),
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



            ],
          )
              : Container(color: Colors.red,);
          // return GestureDetector(
          //   onTap: () {
          //     // Navigator.of(context).pushAndRemoveUntil(
          //     //     FadeRoute(
          //     //       page: ConversationScreen(
          //     //         wiggles: wiggles,
          //     //         wiggle: wiggle,
          //     //         userData: userData,
          //     //       ),
          //     //     ),
          //     //     ModalRoute.withName('ConversationScreen'));
          //   },
          //   child: Padding(
          //     padding: EdgeInsets.only(bottom: 12),
          //     child: Column(
          //       mainAxisSize: MainAxisSize.min,
          //       children: <Widget>[
          //         createPostHead(context, userData),
          //         createPostPicture(userData),
          //         SizedBox(
          //           height: 10,
          //         ),
          //         createPostFooter(context, userData),
          //       ],
          //     ),
          //   ),
          // );
        });

  }
}
