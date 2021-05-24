import 'dart:async';
import 'dart:math' as math;
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/services/database.dart';
import 'package:techstagram/ui/Otheruser/other_aboutuser.dart';
import 'package:techstagram/ui/Otheruser/otherfollowerlist.dart';
import 'package:techstagram/ui/ProfileEdit.dart';
import 'package:techstagram/ui/post.dart';
import 'package:techstagram/utils/utils.dart';

import '../HomePage.dart';
import '../aboutuser.dart';

class OtherUserProfile extends StatefulWidget {
  final String uid;
  final String uidX;
  final String displayNamecurrentUser;
  final String displayName;

  OtherUserProfile(
      {this.uid, this.displayNamecurrentUser, this.displayName, this.uidX});

  @override
  _OtherUserProfileState createState() => _OtherUserProfileState(
      uid: uid,
      displayNamecurrentUser: displayNamecurrentUser,
      displayName: displayName,
      uidX: uidX);
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  final String uid;
  final String uidX;
  final String displayNamecurrentUser;
  final String displayName;

  _OtherUserProfileState(
      {this.uid, this.displayNamecurrentUser, this.displayName, this.uidX});

  bool followed = false;

  ScrollController scrollController = new ScrollController();

  TextEditingController uidControllerX, followingControllerX;

  DocumentSnapshot docSnap;
  User user;
  User currUser;
  Timer timer;

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
    //photoUrlX = TextEditingController();
    super.initState();
    fetchProfileData();
    getUserPosts(uid);
    fetchOProfileData();
    checkPrivate();
  }

  int followingX;
  String photoUrlX;
  final image = Image.asset(
    AvailableImages.emptyState['assetPath'],
  );

  final notificationHeader = Container(
    padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
    child: Text(
      "No Posts Yet !",
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
    ),
  );

  getUserPosts(String uidX) async {
    getPostsUser(uidX).then((val) {
      setState(() {
        userPostsStream = val;
      });
    });
  }

  getPostsUser(String uidX) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uidX)
        .collection('posts')
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  // fetchMyProfileData() async {
  //   currUser = await FirebaseAuth.instance.currentUser();
  //   try {
  //     docSnap = await Firestore.instance
  //         .collection("users")
  //         .document(currUser.uid)
  //         .get();
  //
  //     displayNameController.text = docSnap.data["displayName"];
  //     uidController.text = docSnap.data["uid"];
  //     emailController.text = docSnap.data["email"];
  //     photoUrlController.text = docSnap.data["photoURL"];
  //     phonenumberController.text = docSnap.data["phonenumber"];
  //     bioController.text = docSnap.data["bio"];
  //     followers = docSnap.data["followers"];
  //     following  = docSnap.data["following"];
  //     posts  = docSnap.data["posts"];
  //
  //     setState(() {
  //       isLoading = false;
  //       isEditable = false;
  //     });
  //
  //     //getUserPosts(uidController.text);
  //   } on PlatformException catch (e) {
  //     print("PlatformException in fetching user profile. E  = " + e.message);
  //   }
  // }

  bool private;

  fetchProfileData() async {
    currUser =  FirebaseAuth.instance.currentUser;
    try {
      docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUser.uid)
          .get();

      uidControllerX.text = docSnap["uid"];
      followingX = docSnap["following"];
      photoUrlX = docSnap["photoURL"];
      print("fg");
      print(currUser.uid);

      setState(() {
//        isLoading = false;
//        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  bool show;

  checkPrivate() async {
    if (private == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('followers')
          .doc(displayNamecurrentUser)
          .get()
          .then((value) {
        if (value.exists) {
          print(uidX);
          print("if me aaya");
          setState(() {
            show = true;
          });
        } else {
          print("else me aaya");
          setState(() {
            show = false;
          });
        }
      });
    } else if (private == false) {
      print("private nahi hai");
      setState(() {
        show = true;
      });
    } else {
      setState(() {
        show = true;
      });
    }
  }

  fetchOProfileData() async {
    currUser =FirebaseAuth.instance.currentUser;
    try {
      docSnap =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      private = docSnap["private"];
      print("fgd");
      print(private);

      setState(() {
//        isLoading = false;
//        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  getFollowers() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(displayNamecurrentUser)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          followed = true;
          print(followed);
        });
      } else {
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

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
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

  getfollowers(String displayNamecurrentUser, String uid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('followers')
        .doc(displayNamecurrentUser)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          followed = true;
        });
      }
    });
  }

  Future<bool> _onWillPop() {
    Navigator.pop(context);
  }

  getlikes(String displayName, String postId) {
    // print("postid");
    // print(postId);
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(displayName)
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

  DeleteNotification() async {
    print("amios");
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('notification')
        //.where('displayName','==',displayName);
        .doc(uidX)
        .delete();
  }

  String NotificationId;
  Notification(String displayNameCurrUser, int followers) async {
    print(displayNameCurrUser);
    print(displayNamecurrentUser);
    print("911");

    setState(() {
      // file = null;
      NotificationId = Uuid().v4();
    });

    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("notification")
        .doc(uidX)
        .set({
      "followers": followers + 1,
      "notificationId": NotificationId,
      "username": displayNameCurrUser,
      //"comment": commentTextEditingController.text,

      "timestamp": DateTime.now(),
      "url": photoUrlX,
      "uid": uidX,
      "status": "Follow",
    });
  }

  List<DocumentSnapshot> list;

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    Stream userQuery;

    userQuery = FirebaseFirestore.instance
        .collection('users')
        .where('displayName', isEqualTo: displayName)
        .snapshots();

    String displayNameX = displayName;

    print("cv");
    print(displayNameX);
    print("434");

    // TODO: implement build
    return WillPopScope(
      onWillPop: () => _onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            displayNameX,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: StreamBuilder(
          stream: userQuery,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
//                DocumentSnapshot sd = snapshot.data.documents[index];
                      String photoUrl =
                          snapshot.data.documents[index]["photoURL"];
                      String coverPhotoUrl =
                          snapshot.data.documents[index]["coverPhotoUrl"];
                      String uid = snapshot.data.documents[index]["uid"];
                      String displayName =
                          snapshot.data.documents[index]["displayName"];
                      String bio = snapshot.data.documents[index]["bio"];
                      int followers =
                          snapshot.data.documents[index]["followers"];
                      String firstName =
                          snapshot.data.documents[index]["fname"];
                      String lastName =
                          snapshot.data.documents[index]["surname"];

                      if (followers == 0) {
                        followed = false;
                      }
                      int following =
                          snapshot.data.documents[index]["following"];
                      print(following);
                      int posts = snapshot.data.documents[index]["posts"];
                      if (followers == 0) {
                        followed = false;
                      }

                      getfollowers(displayNamecurrentUser, uid);
                      return (uid != null)
                          ? SingleChildScrollView(
                              child: SafeArea(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Stack(
                                    children: [
                                      (coverPhotoUrl == null)
                                          ? Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.20,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      'assets/images/nocover.png'),
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              //color: Colors.lightBlueAccent,
                                            )
                                          : Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.20,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      coverPhotoUrl),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),

                                      // opar neeche start
                                      Align(
                                        alignment: Alignment.center,
                                        child: SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                height: deviceHeight * 0.22,
                                              ),
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.35,
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,

                                                // margin: EdgeInsets.only(top:200, bottom: 70,left: 20,right: 20),
                                                child: Column(
                                                  //mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.30,
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.70,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: <
                                                                  Widget>[
                                                                _buildStatItem(
                                                                    "POSTS",
                                                                    posts
                                                                        .toString()),
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      Navigator
                                                                          .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            OtherFollowersList(
                                                                              displayName: displayName,
                                                                              uid: uid,
                                                                              displayNamecurrentUser: displayNamecurrentUser,
                                                                              uidX: uidX,
                                                                            )),
                                                                  ),
                                                                  child: _buildStatItem(
                                                                      "FOLLOWERS",
                                                                      followers
                                                                          .toString()),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () =>
                                                                      Navigator
                                                                          .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            OtherFollowersList(
                                                                              displayName: displayName,
                                                                              uid: uid,
                                                                              displayNamecurrentUser: displayNamecurrentUser,
                                                                              uidX: uidX,
                                                                            )),
                                                                  ),
                                                                  child: _buildStatItem(
                                                                      "FOLLOWING",
                                                                      following
                                                                          .toString()),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 30,
                                                      width: 300,
                                                      // child: Divider(
                                                      //   color: Colors.teal.shade700,
                                                      // ),
                                                    ),
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.13,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.90,
                                                      margin: EdgeInsets.only(
                                                          top: 8.0),

                                                      //display name thing
                                                      child: Row(
                                                        children: [
                                                          Column(
                                                            children: [
                                                              (firstName !=
                                                                          null &&
                                                                      lastName !=
                                                                          null)
                                                                  ? Container(
                                                                      width: deviceWidth *
                                                                          0.80,
                                                                      child:
                                                                          Text(
                                                                        firstName +
                                                                            " " +
                                                                            lastName,
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              26.0,
                                                                          color:
                                                                              Colors.black,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontFamily:
                                                                              'Pacifico',
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(
                                                                      width: deviceWidth *
                                                                          0.80,
                                                                      child:
                                                                          Text(
                                                                        displayName,
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              26.0,
                                                                          color:
                                                                              Colors.black,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontFamily:
                                                                              'Pacifico',
                                                                        ),
                                                                      ),
                                                                    ),
                                                              SizedBox(
                                                                height: 5.0,
                                                              ),
                                                              Container(
                                                                width:
                                                                    deviceWidth *
                                                                        0.80,
                                                                child: Text(
                                                                  displayName,
                                                                  textAlign:
                                                                      TextAlign
                                                                          .left,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        15.0,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        'Pacifico',
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 5.0,
                                                              ),
                                                              (bio != null)
                                                                  ? Container(
                                                                      width: deviceWidth *
                                                                          0.80,
                                                                      child:
                                                                          Text(
                                                                        bio,
                                                                        textAlign:
                                                                            TextAlign.left,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Source Sans Pro',
                                                                          fontSize:
                                                                              15.0,
                                                                          color:
                                                                              Colors.grey,
                                                                          letterSpacing:
                                                                              2.5,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Text("")
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              (displayNamecurrentUser !=
                                                                      displayName)
                                                                  ? Padding(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .only(
                                                                        top:
                                                                            10.0,
                                                                      ),
                                                                      child:
                                                                          Align(
                                                                        alignment:
                                                                            Alignment.topRight,
                                                                        child:
                                                                            SizedBox(
                                                                          width:
                                                                              30,
                                                                          height:
                                                                              30.0,
                                                                          child:
                                                                              Ink(
                                                                            decoration:
                                                                                const ShapeDecoration(
                                                                              color: Colors.black,
                                                                              shape: CircleBorder(),
                                                                            ),
                                                                            child: IconButton(
                                                                                color: Colors.white,
                                                                                icon: Icon(
                                                                                  FontAwesomeIcons.rocketchat,
                                                                                  size: 15,
                                                                                ),
                                                                                onPressed: () {}),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                              SizedBox(
                                                                height: 5.0,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                  top: 10.0,
                                                                ),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .topRight,
                                                                  child:
                                                                      SizedBox(
                                                                    width: 30,
                                                                    height:
                                                                        30.0,
                                                                    child: Ink(
                                                                      decoration:
                                                                          const ShapeDecoration(
                                                                        color: Colors
                                                                            .black,
                                                                        shape:
                                                                            CircleBorder(),
                                                                      ),
                                                                      child: (displayName ==
                                                                              displayNamecurrentUser)
                                                                          ? IconButton(
                                                                              color: Colors.white,
                                                                              icon: Icon(
                                                                                FontAwesomeIcons.userEdit,
                                                                                size: 15,
                                                                              ),
                                                                              onPressed: () {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(builder: (context) => ProfilePage()),
                                                                                );
                                                                              })
                                                                          : IconButton(
                                                                              color: Colors.white,
                                                                              icon: Icon(
                                                                                FontAwesomeIcons.user,
                                                                                size: 15,
                                                                              ),
                                                                              onPressed: () {
                                                                                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutOtherUser(uid: uid)));
                                                                              }),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.85,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                SizedBox(
                                                                  width: 120,
                                                                  child: (displayName ==
                                                                          displayNamecurrentUser)
                                                                      ? MaterialButton(
                                                                          color: Colors
                                                                              .purple,
                                                                          child:
                                                                              new Text(
                                                                            "About me",
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => AboutUser(
                                                                                        uid: uidX,
                                                                                      )),
                                                                            );
                                                                          },
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            side:
                                                                                BorderSide(color: Colors.purple, width: 2.5),
                                                                            borderRadius:
                                                                                BorderRadius.circular(30.0),
                                                                          ))
                                                                      : MaterialButton(
                                                                          color: Colors
                                                                              .white,
                                                                          child:
                                                                              new Text(
                                                                            (followed == false)
                                                                                ? "Follow"
                                                                                : "Unfollow",
                                                                            style:
                                                                                TextStyle(
                                                                              color: (followed == false) ? Colors.purple : Colors.red,
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () {
                                                                            if (followed ==
                                                                                false) {
                                                                              if (timer?.isActive ?? false)
                                                                                timer.cancel(); //cancel if [timer] is null or running
                                                                              timer = Timer(const Duration(milliseconds: 1500), () {
                                                                                setState(() {
                                                                                  //getFollowers();
                                                                                  followed = true;
                                                                                });

                                                                                DatabaseService().followUser(followers, uid, displayNamecurrentUser, uidControllerX.text, photoUrlX);
                                                                                Notification(displayNamecurrentUser, followers);
                                                                                // DatabaseService().followingUser(following,uid, displayNamecurrentUser);
                                                                                DatabaseService().increaseFollowing(uidX, followingX, displayNamecurrentUser, displayNameX, uid, photoUrl);
                                                                              });
                                                                            } else {
                                                                              if (timer?.isActive ?? false)
                                                                                timer.cancel(); //cancel if [timer] is null or running
                                                                              timer = Timer(const Duration(milliseconds: 1500), () {
                                                                                DatabaseService().unfollowUser(followers, uid, displayNamecurrentUser);

                                                                                DeleteNotification();

                                                                                DatabaseService().decreaseFollowing(uidX, followingX, displayNamecurrentUser, displayNameX, uid);
                                                                                setState(() {
                                                                                  //getFollowers();
                                                                                  followed = false;
                                                                                });
                                                                              });
                                                                            }
                                                                          },
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            side:
                                                                                BorderSide(color: (followed == false) ? Colors.purple : Colors.red, width: 2),
                                                                            borderRadius:
                                                                                BorderRadius.circular(30.0),
                                                                          )),
                                                                ),

//
                                                              ]),
                                                          SizedBox(
                                                            height: 10,
                                                            width: deviceWidth,
                                                            child: Divider(
                                                              thickness: 2.0,
                                                              color: Colors.teal
                                                                  .shade700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height -
                                                    300,
                                                width: 340.0,

                                                child: StreamBuilder(
                                                    stream: userPostsStream,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.data ==
                                                          null) {
                                                        return Container();
                                                      }
                                                      int itemCount = snapshot
                                                          .data
                                                          .documents
                                                          .length;
                                                      return (posts != 0)
                                                          ? Column(
                                                              children: [
                                                                new Expanded(
                                                                    child: GridView.builder(
                                                                        shrinkWrap: true,
                                                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 10.0, mainAxisSpacing: 10.0),
                                                                        controller: ScrollController(),
                                                                        itemCount: itemCount,
                                                                        itemBuilder: (context, index) {
                                                                          String
                                                                              postIdX =
                                                                              snapshot.data.documents[index]['email'];
                                                                          String
                                                                              email =
                                                                              snapshot.data.documents[index]['email'];
                                                                          String
                                                                              description =
                                                                              snapshot.data.documents[index]['description'];
                                                                          String
                                                                              displayName =
                                                                              snapshot.data.documents[index]['displayName'];
                                                                          String
                                                                              photoUrl =
                                                                              snapshot.data.documents[index]['photoURL'];
                                                                          String
                                                                              uid =
                                                                              snapshot.data.documents[index]["uid"];

                                                                          Timestamp
                                                                              timestamp =
                                                                              snapshot.data.documents[index]['timestamp'];
                                                                          String
                                                                              url =
                                                                              snapshot.data.documents[index]['url'];
                                                                          int cam = snapshot
                                                                              .data
                                                                              .documents[index]['cam'];
                                                                          String
                                                                              postId =
                                                                              snapshot.data.documents[index]['postId'];
                                                                          int likes = snapshot
                                                                              .data
                                                                              .documents[index]['likes'];
                                                                          readTimestamp(
                                                                              timestamp.seconds);
                                                                          checkPrivate();

                                                                          getlikes(
                                                                              displayName,
                                                                              postId);
                                                                          if (likes < 0 ||
                                                                              likes == 0) {
                                                                            liked =
                                                                                false;
                                                                          }
                                                                          return (show == null)
                                                                              ? Container()
                                                                              : (show)
                                                                                  ? Container(
                                                                                      child: Container(
                                                                                        color: Colors.white,
                                                                                        child: Column(
                                                                                          children: <Widget>[
                                                                                            Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                              children: [
                                                                                                GestureDetector(
                                                                                                  onTap: () {
                                                                                                    Navigator.push(
                                                                                                      context,
                                                                                                      MaterialPageRoute(
                                                                                                          builder: (context) => postPage(
                                                                                                                displayNamecurrentUser: displayName,
                                                                                                                PostUrl: url,
                                                                                                                uidX: uid,
                                                                                                                delete: false,
                                                                                                              )),
                                                                                                    );
                                                                                                  },
                                                                                                  child: ClipRRect(
                                                                                                    borderRadius: BorderRadius.only(
                                                                                                      topLeft: Radius.circular(8.0),
                                                                                                      topRight: Radius.circular(8.0),
                                                                                                      bottomLeft: Radius.circular(8.0),
                                                                                                      bottomRight: Radius.circular(8.0),
                                                                                                    ),
                                                                                                    child: (cam == 1)
                                                                                                        ? Transform(
                                                                                                            alignment: Alignment.center,
                                                                                                            transform: Matrix4.rotationY(math.pi),
                                                                                                            child: Image.network(
                                                                                                              url,
                                                                                                              // width: 300,
                                                                                                              height: 104,
                                                                                                              fit: BoxFit.cover,
                                                                                                            ),
                                                                                                          )
                                                                                                        : Image.network(
                                                                                                            url,
                                                                                                            // width: 300,
                                                                                                            height: 104,
                                                                                                            fit: BoxFit.cover,
                                                                                                          ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      // height: 150.0,
                                                                                      // width: 150.0,
                                                                                      //child: Image.network(url),
                                                                                    )
                                                                                  : Container();
                                                                        })),
                                                              ],
                                                            )
                                                          : Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .only(
                                                                top: 5.0,
                                                                left: 30.0,
                                                                right: 30.0,
                                                                bottom: 5.0,
                                                              ),
                                                              //height: 200,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.20,
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.20,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  //pageTitle,
                                                                  // SizedBox(
                                                                  //   height: deviceHeight * 0.1,
                                                                  // ),
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      image,
                                                                      notificationHeader,
                                                                      //notificationText,
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                    }),

                                                //child: Image.network(uidCurrUser),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Container(
                                          height: deviceHeight * 0.31,
                                          width: deviceWidth * 0.96,
                                          padding: const EdgeInsets.only(
                                              right: 250.0),
                                          child: (photoUrl != null)
                                              ? Align(
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                        //borderRadius: BorderRadius.circular(100),
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 5,
                                                        ),
                                                      ),
                                                      child: Container(
                                                        height: 100,
                                                        width: 100.0,
                                                        child: Image(
                                                          image: NetworkImage(
                                                              photoUrl),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        //backgroundImage: NetworkImage(photoUrlController.text)
                                                      )
                                                      // child: CircleAvatar(
                                                      //   radius: 50,
                                                      //   backgroundImage: NetworkImage(photoUrlController.text),
                                                      //
                                                      //   backgroundColor: Colors.transparent,
                                                      // ),
                                                      ),
                                                )
                                              : Container(
                                                  child: IconButton(
                                                      icon: Icon(
                                                        FontAwesomeIcons
                                                            .userCircle,
                                                        color:
                                                            Colors.deepPurple,
                                                      ),
                                                      onPressed: () {
                                                        print("hello");
                                                      }),
                                                ),
                                        ),
                                      ),

                                      // Padding(
                                      //   padding: const EdgeInsets.only(top: 145,right: 250.0),
                                      //   child:(photoUrl!=null)?Align(
                                      //     alignment: Alignment.center,
                                      //     child: Container(
                                      //       decoration: BoxDecoration(
                                      //         borderRadius: BorderRadius.circular(100),
                                      //         border: Border.all(
                                      //           color: Colors.white,
                                      //           width: 5,
                                      //         ),
                                      //       ),
                                      //       child: CircleAvatar(
                                      //         radius: 50,
                                      //         backgroundImage: NetworkImage(photoUrl),
                                      //
                                      //         backgroundColor: Colors.transparent,
                                      //       ),
                                      //     ),
                                      //   ): CircleAvatar(
                                      //     radius: 50,
                                      //     child: IconButton(icon:
                                      //     Icon(FontAwesomeIcons.userCircle,
                                      //       color: Colors.deepPurple,), onPressed: (){print("hello");}),
                                      //     backgroundColor: Colors.transparent,
                                      //   ),
                                      // ),

                                      // (photoUrl!=null)?Padding(
                                      //   padding: const EdgeInsets.only(
                                      //       top: 80, left: 140.0, right: 140.0),
                                      //   child:Align(
                                      //     alignment: Alignment.center,
                                      //     child: CircleAvatar(
                                      //       radius: 35,
                                      //       backgroundImage: NetworkImage(photoUrl),
                                      //
                                      //       backgroundColor: Colors.transparent,
                                      //     ),
                                      //   ),
                                      // ):Padding(
                                      //   padding: const EdgeInsets.only(
                                      //       top: 70, left: 110.0,right: 110.0),
                                      //   child: CircleAvatar(
                                      //     radius: 50,
                                      //     child: IconButton(icon:
                                      //     Icon(FontAwesomeIcons.userCircle,
                                      //       color: Colors.deepPurple,
                                      //       size: 100.0,), onPressed: null),
                                      //     backgroundColor: Colors.white60,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : Container();
                    },
                  )
                : Container();
          },
        ),
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
