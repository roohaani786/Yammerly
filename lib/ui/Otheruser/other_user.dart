import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/services/database.dart';
import 'package:techstagram/ui/Otheruser/otherfollowerlist.dart';
import 'package:techstagram/ui/ProfileEdit.dart';

import 'package:techstagram/ui/Otheruser/other_aboutuser.dart';
import 'package:techstagram/views/tabs/comments_screen.dart';

class OtherUserProfile extends StatefulWidget{

  final String uid;
  final String uidX;
  final String displayNamecurrentUser;
  final String displayName;

  OtherUserProfile({this.uid,this.displayNamecurrentUser,this.displayName,this.uidX});
  @override
  _OtherUserProfileState createState() => _OtherUserProfileState(uid: uid,displayNamecurrentUser: displayNamecurrentUser,displayName: displayName);
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  final String uid;
  final String uidX;
  final String displayNamecurrentUser;
  final String displayName;
  _OtherUserProfileState({this.uid,this.displayNamecurrentUser,this.displayName,this.uidX});

  bool followed = false;

  ScrollController scrollController = new ScrollController();


  TextEditingController uidControllerX,followingControllerX;

  DocumentSnapshot docSnap;
  User user;
  FirebaseUser currUser;

  Map<String, dynamic> _profile;
  bool _loading = false;

  Stream<QuerySnapshot> userPostsStream;



  @override
  void initState() {
    getFollowers();
    // TODO: implement initState
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));

    uidControllerX = TextEditingController();
    super.initState();
    fetchProfileData();
    getUserPosts(uid);
  }

  int followingX;

  getUserPosts(String uidX) async {
    getPostsUser(uidX).then((val){
      setState(() {
        userPostsStream = val;
      });
    });
  }

  getPostsUser(String uidX) async {
    return Firestore.instance.collection('users')
        .document(uidX)
        .collection('posts')
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  fetchProfileData() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {
      docSnap = await Firestore.instance
          .collection("users")
          .document(currUser.uid)
          .get();

      uidControllerX.text = docSnap.data["uid"];
      followingX = docSnap.data["following"];
      print("fg");
      print(followingX);

      setState(() {
//        isLoading = false;
//        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }


  getFollowers() {

    Firestore.instance.collection('users')
        .document(uid)
        .collection('followers')
        .document(displayNamecurrentUser)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          followed = true;
          print(followed);
        });
      }
      else{
        setState(() {
          followed = false;
        });
      }
    });
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    //var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
      //time = format.format(date);
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

  bool liked = false;

  getlikes( String displayName, String postId) {

    print("postid");
    print(postId);
    Firestore.instance.collection('posts')
        .document(postId)
        .collection('likes')
        .document(displayName)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          liked = true;
          print("haa");
        });
      }
    });

  }

  List<DocumentSnapshot> list;

  @override
  Widget build(BuildContext context) {
    //print("HAHA");
    //print(uidControllerX.text);


    Stream userQuery;

     userQuery = Firestore.instance.collection('users')
        .where('uid', isEqualTo: uid)
        .snapshots();

     String displayNameX = displayName;

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(displayNameX),
      ),
      body: StreamBuilder(
      stream: userQuery,
    builder: (context, snapshot) {
    return snapshot.hasData
    ?
    ListView.builder(
    itemCount: snapshot.data.documents.length,
    itemBuilder: (context, index) {
      DocumentSnapshot sd = snapshot.data.documents[index];
      String photoUrl = snapshot.data.documents[index]["photoURL"];
      String uid = snapshot.data.documents[index]["uid"];
      String displayName = snapshot.data.documents[index]["displayName"];
      String bio = snapshot.data.documents[index]["bio"];
      int followers = snapshot.data.documents[index]["followers"];
      int following = snapshot.data.documents[index]["following"];
      print(following);
      int posts = snapshot.data.documents[index]["posts"];
      return (uid != null) ?
      SingleChildScrollView(
        child: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 120.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              height: 300.0,
                              width: 340.0,
                              child: Card(
                                elevation: 5.0,
                                color: Colors.white,
                                // margin: EdgeInsets.only(top:200, bottom: 70,left: 20,right: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[

                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        displayName,
                                        style: TextStyle(
                                          fontSize: 26.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Pacifico',
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: (bio!=null)?Text(
                                        bio,
                                        style: TextStyle(
                                          fontFamily: 'Source Sans Pro',
                                          fontSize: 15.0,
                                          color: Colors.grey,
                                          letterSpacing: 2.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ):Text(""),
                                    ),
                                    SizedBox(
                                      height: 20,
                                      width: 200,
                                      child: Divider(
                                        color: Colors.teal.shade700,
                                      ),
                                    ),
                                    Container(
                                      height: 60.0,
                                      margin: EdgeInsets.only(top: 8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceAround,
                                        children: <Widget>[
                                          GestureDetector(
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OtherFollowersList(displayNamecurrentUser: displayName,uidX: uid,)
                                              ),
                                            ),
                                            child: _buildStatItem("FOLLOWERS",
                                                followers.toString()),
                                          ),
                                          _buildStatItem("POSTS", posts.toString()),
                                          GestureDetector(
                                            onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OtherFollowersList(displayNamecurrentUser: displayName,uidX: uid,)
                                              ),
                                            ),
                                            child: _buildStatItem("FOLLOWING",
                                                following.toString()),
                                          ),

                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceAround,
                                              children: [
                                                (followed == false)?SizedBox(
                                                  width: 120,
                                                  child: FlatButton(
                                                      color: Colors.white,
                                                      child: new Text(
                                                        "Follow",
                                                        style: TextStyle(
                                                          color: Colors.purple,
                                                        ),
                                                      ),
                                                      onPressed: () {


                                                        setState(() {
                                                          followed = true;
                                                        });
                                                     DatabaseService().followUser(followers, uid, displayNamecurrentUser);
                                                    // DatabaseService().followingUser(following,uid, displayNamecurrentUser);
                                                     DatabaseService().increaseFollowing(uid,followingX,displayNamecurrentUser,displayNameX,uidControllerX.text);
                                                      },
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color: Colors.purple,
                                                            width: 2),
                                                        borderRadius: BorderRadius
                                                            .circular(30.0),
                                                      )),
                                                ): SizedBox(
                                                  width: 120,
                                                  child: FlatButton(
                                                      color: Colors.white,
                                                      child: new Text(
                                                        "Unfollow",
                                                        style: TextStyle(
                                                          color: Colors.redAccent,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          followed = false;
                                                        });
                                                        DatabaseService()
                                                            .unfollowUser(
                                                            followers, uid,
                                                            displayNamecurrentUser);

                                                          DatabaseService()
                                                              .decreaseFollowing(uid,
                                                              1,
                                                              displayNamecurrentUser,
                                                              displayNameX,
                                                              uidControllerX
                                                                  .text);
                                                      },
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color: Colors.red,
                                                            width: 2),
                                                        borderRadius: BorderRadius
                                                            .circular(30.0),
                                                      )),
                                                ),


                                                SizedBox(
                                                  width: 120,
                                                  child: FlatButton(

                                                      color: Colors.white,
                                                      child: new Text(
                                                        "Message",
                                                        style: TextStyle(
                                                          color: Colors.purple,
                                                        ),
                                                      ),
                                                      onPressed: () {
//                                                      Navigator.push(
//                                                        context,
//                                                        MaterialPageRoute(
//                                                            builder: (
//                                                                context) =>
//                                                                ProfileSettings()),
//                                                      );
                                                      },
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                            color: Colors.purple,
                                                            width: 2),
                                                        borderRadius: BorderRadius
                                                            .circular(30.0),
                                                      )),
                                                ),
                                              ]
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: FlatButton(
                                                color: Colors.purple,
                                                child: new Text(
                                                  "About",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: () {
                                                 Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => AboutOtherUser(uid: uid,displayNamecurrentUser: displayNamecurrentUser,displayName: displayName)),
                                                  );
                                                },
                                                shape: RoundedRectangleBorder(
                                                  //side: BorderSide(color: Colors.white, width: 2),
                                                  borderRadius: BorderRadius
                                                      .circular(30.0),
                                                )),
                                          )
                                        ],
                                      ),
                                    )

                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 500.0,
                              width: 500.0,
                              child: StreamBuilder(
                                  stream: userPostsStream,
                                  builder: (context, snapshot) {
                                    return snapshot.hasData
                                        ? Column(
                                      children: [
                                        new Expanded(
                                            child: ListView.builder(
//                                                controller: scrollController,
                                                controller: ScrollController(),
                                                itemCount: snapshot.data.documents.length,
                                                itemBuilder: (context, index) {

                                                  String postIdX = snapshot.data.documents[index]['email'];
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
                                                  readTimestamp(timestamp.seconds);

                                                  getlikes(displayName,postId);


                                                  if(likes< 0 || likes == 0){
                                                    liked = false;
                                                  }
                                                  return Container(
                                                    child: Container(
                                                      color: Colors.white,
                                                      child: Column(
                                                        children: <Widget>[

                                                          GestureDetector(
                                                            // onTap: () => Navigator.push(
                                                            //   context,
                                                            //   MaterialPageRoute(builder: (context) => OtherUserProfile(uid: uid,displayNamecurrentUser: displayNamecurrentUser,displayName: displayName)),
                                                            // ),
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
                                                                  (liked == false)?IconButton(
                                                                    onPressed: () {
                                                                      DatabaseService().likepost(
                                                                          likes, postId, displayName);
                                                                      setState(() {
                                                                        liked = true;
                                                                      });
                                                                    },
                                                                    icon: Icon(FontAwesomeIcons.thumbsUp),
                                                                    iconSize: 25,
                                                                    color: Colors.deepPurple,
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

                                                                    icon: Icon(FontAwesomeIcons.solidThumbsUp),
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
                                                                      // var currentUser;
                                                                      // Navigator.push(
                                                                      //     context,
                                                                      //     MaterialPageRoute(
                                                                      //         builder: ((context) => CommentsScreen())));
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
//
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
                                                }
                                            )
                                        ),
                                      ],
                                    ): Container(color: Colors.deepPurple,);
                                  }
                              ),
                              //child: Image.network(uidCurrUser),

                            )
                          ],
                        ),
                      ),
                    ),
                  ),


                  (photoUrl!=null)?Padding(
                    padding: const EdgeInsets.only(
                        top: 80, left: 160.0, right: 160.0),
                    child:CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(photoUrl),

                      backgroundColor: Colors.transparent,
                    ),
                  ):Padding(
                    padding: const EdgeInsets.only(
                        top: 70, left: 110.0,right: 110.0),
                    child: CircleAvatar(
                      radius: 50,
                      child: IconButton(icon:
                      Icon(FontAwesomeIcons.userCircle,
                        color: Colors.deepPurple,
                        size: 100.0,), onPressed: null),
                      backgroundColor: Colors.white60,
                    ),
                  ),
                ],
            ),
          ),
        ),
      ) : Container();
    },
    ):Container();
    },
      ),
    );
  }
}

Widget _buildStatItem(String label, String count) {
  TextStyle _statLabelTextStyle = TextStyle(
    fontFamily: 'Roboto',
    color: Colors.grey,
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
  );

  TextStyle _statCountTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 22.0,
    fontWeight: FontWeight.bold,
  );

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      Text(
        label,
        style: _statLabelTextStyle,
      ),
      Text(
        count,
        style: _statCountTextStyle,
      ),

    ],
  );
}
