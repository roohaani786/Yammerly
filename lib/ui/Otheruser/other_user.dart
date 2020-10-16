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
import 'dart:math' as math;
import 'package:techstagram/ui/Otheruser/other_aboutuser.dart';
import 'package:techstagram/ui/post.dart';
import 'package:techstagram/views/tabs/comments_screen.dart';

import '../aboutuser.dart';

class OtherUserProfile extends StatefulWidget{

  final String uid;
  final String uidX;
  final String displayNamecurrentUser;
  final String displayName;

  OtherUserProfile({this.uid,this.displayNamecurrentUser,this.displayName,this.uidX});
  @override
  _OtherUserProfileState createState() => _OtherUserProfileState(uid: uid,displayNamecurrentUser: displayNamecurrentUser,displayName: displayName,uidX: uidX);
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
    //photoUrlX = TextEditingController();
    super.initState();
    fetchProfileData();
    getUserPosts(uid);
  }

  int followingX;
  String photoUrlX;

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

  fetchProfileData() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {
      docSnap = await Firestore.instance
          .collection("users")
          .document(currUser.uid)
          .get();

      uidControllerX.text = docSnap.data["uid"];
      followingX = docSnap.data["following"];
      photoUrlX = docSnap.data["photoURL"];
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

  getfollowers( String displayNamecurrentUser, String uid) {


    Firestore.instance.collection('users')
        .document(uid)
        .collection('followers')
        .document(displayNamecurrentUser)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          followed = true;

        });
      }
    });

  }

  getlikes( String displayName, String postId) {

    // print("postid");
    // print(postId);
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



    Stream userQuery;

    userQuery = Firestore.instance.collection('users')

        .where('displayName', isEqualTo: displayName)

        .snapshots();

    String displayNameX = displayName;

    print("cv");
    print(displayNameX);
    print("434");

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(displayNameX,style: TextStyle(
          fontWeight: FontWeight.bold,
        ),),
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

              if(followers == 0){
                  followed = false;
              }
              int following = snapshot.data.documents[index]["following"];
              print(following);
              int posts = snapshot.data.documents[index]["posts"];
              if(followers == 0){

                followed = false;
              }

              getfollowers(displayNamecurrentUser,uid);
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
                                              textAlign: TextAlign.center,
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
                                                            OtherFollowersList(displayName: displayName,uid: uid,displayNamecurrentUser: displayNamecurrentUser,uidX: uidX,)
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
                                                            OtherFollowersList(displayName: displayName,uid: uid,displayNamecurrentUser: displayNamecurrentUser,uidX: uidX,)
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
                                                      SizedBox(
                                                        width: 120,
                                                        child: (displayName == displayNamecurrentUser)?FlatButton(
                                                          color: Colors.white,
                                                            child: new Text(
                                                              "About me",
                                                              style: TextStyle(
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                              onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(builder: (context) => AboutUser()),
                                                              );
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color: Colors.purple,
                                                                  width: 2.5),
                                                              borderRadius: BorderRadius
                                                                  .circular(30.0),
                                                            )
                                                        ):FlatButton(
                                                          color: Colors.white,
                                                          child: new Text(
                                                            (followed == false)?"Follow":"Unfollow",
                                                            style: TextStyle(
                                                              color: (followed == false)?Colors.purple:Colors.red,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            if(followed == false){
                                                              setState(() {
                                                                //getFollowers();
                                                               followed = true;
                                                              });

                                                              DatabaseService().followUser(followers, uid, displayNamecurrentUser,uidControllerX.text,photoUrlX);

                                                              // DatabaseService().followingUser(following,uid, displayNamecurrentUser);
                                                              DatabaseService().increaseFollowing(uidX,followingX,displayNamecurrentUser,displayNameX,uid,photoUrl);
                                                            }else{
                                                              DatabaseService()
                                                                  .unfollowUser(
                                                                  followers, uid,
                                                                  displayNamecurrentUser);

                                                              DatabaseService()
                                                                  .decreaseFollowing(uidX,followingX,displayNamecurrentUser,displayNameX,uid);
                                                              setState(() {
                                                                //getFollowers();
                                                                followed = false;
                                                              });
                                                            }
                                                              },
                                                          shape: RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                  color: (followed == false)?Colors.purple:Colors.red,
                                                                  width: 2),
                                                              borderRadius: BorderRadius
                                                                  .circular(30.0),
                                                            )),
                                                        ),



//                                                       (followed == false)?SizedBox(
//                                                         width: 120,
//
//                                                         child: (displayName == displayNamecurrentUser)?FlatButton(
//                                                             color: Colors.white,
//                                                             child: new Text(
//                                                               "About me",
//                                                               style: TextStyle(
//                                                                 color: Colors.black,
//                                                               ),
//                                                             ),
//                                                             onPressed: () {
//
//                                                               Navigator.push(
//                                                                 context,
//                                                                 MaterialPageRoute(builder: (context) => AboutUser()),
//                                                               );
//                                                             },
//
//                                                             shape: RoundedRectangleBorder(
//                                                               side: BorderSide(
//                                                                   color: Colors.purple,
//                                                                   width: 2.5),
//                                                               borderRadius: BorderRadius
//                                                                   .circular(30.0),
//                                                             )):FlatButton(
//
//                                                             color: Colors.white,
//                                                             child: new Text(
//                                                               "Follow",
//                                                               style: TextStyle(
//                                                                 color: Colors.purple,
//                                                               ),
//                                                             ),
//                                                             onPressed: () {
//
//                                                               setState(() {
//                                                                 getFollowers();
// //                                                                followed = true;
//                                                               });
//
//                                                               DatabaseService().followUser(followers, uid, displayNamecurrentUser,uidControllerX.text,photoUrlX);
//
//                                                               // DatabaseService().followingUser(following,uid, displayNamecurrentUser);
//                                                               DatabaseService().increaseFollowing(uidX,followingX,displayNamecurrentUser,displayNameX,uid,photoUrl);
//                                                             },
//                                                             shape: RoundedRectangleBorder(
//                                                               side: BorderSide(
//                                                                   color: Colors.purple,
//                                                                   width: 2),
//                                                               borderRadius: BorderRadius
//                                                                   .circular(30.0),
//                                                             )),
//                                                       ): SizedBox(
//                                                         width: 120,
//                                                         child: FlatButton(
//                                                             color: Colors.white,
//                                                             child: new Text(
//                                                               "Unfollow",
//                                                               style: TextStyle(
//                                                                 color: Colors.redAccent,
//                                                               ),
//                                                             ),
//                                                             onPressed: () {
//
//                                                               DatabaseService()
//                                                                   .unfollowUser(
//                                                                   followers, uid,
//                                                                   displayNamecurrentUser);
//
//                                                               DatabaseService()
//                                                                   .decreaseFollowing(uidX,followingX,displayNamecurrentUser,displayNameX,uid);
//                                                               setState(() {
//                                                                 followed = false;
//                                                               });
//                                                             },
//                                                             shape: RoundedRectangleBorder(
//                                                               side: BorderSide(
//                                                                   color: Colors.red,
//                                                                   width: 2),
//                                                               borderRadius: BorderRadius
//                                                                   .circular(30.0),
//                                                             )),
//                                                       ),



                                                      (displayName != displayNamecurrentUser)?Padding(
                                                        padding: const EdgeInsets.only(left: 20.0),
                                                        child: SizedBox(
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
                                                      ):FlatButton(
                                                          color: Colors.transparent,
                                                          //color: Colors.white,
                                                          child: new Text(
                                                            "Edit Profile",
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              //color: Color(0xffed1e79),
                                                            ),
                                                          ),
                                                          onPressed: () {

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => ProfilePage()),
                                                            );
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                            side: BorderSide(
                                                                color: Colors.purple,
                                                                //color: Color(0xffed1e79),
                                                                width: 2.5),
                                                            borderRadius: BorderRadius.circular(30.0),
                                                          )),
                                                    ]
                                                ),
                                                (displayName != displayNamecurrentUser)?SizedBox(
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

                                                ):Container(),

                                              ],
                                            ),
                                          )

                                        ],
                                      ),

                                  ),
                                  Container(
                                    height: MediaQuery.of(context).size.height-300,
                                    width: 340.0,

                                      child: StreamBuilder(
                                          stream: userPostsStream,
                                          builder: (context, snapshot) {
                                            return snapshot.hasData
                                                ? Column(
                                              children: [
                                                new Expanded(
                                                    child: GridView.builder(
                                                        shrinkWrap: true,
                                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                            crossAxisCount: 3,
                                                            crossAxisSpacing: 10.0,
                                                            mainAxisSpacing: 10.0),
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
                                                          int cam = snapshot.data.documents[index]['cam'];
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


                                                                  Column(
                                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                    children: [

                                                                      GestureDetector(
                                                                        onTap: () {
                                                                          Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(builder: (context) => postPage(PostUrl: url)),
                                                                          );
                                                                        },
                                                                        child: ClipRRect(
                                                                          borderRadius: BorderRadius.only(
                                                                            topLeft: Radius.circular(8.0),
                                                                            topRight: Radius.circular(8.0),
                                                                            bottomLeft: Radius.circular(8.0),
                                                                            bottomRight: Radius.circular(8.0),
                                                                          ),
                                                                    
                                                                        child: (cam == 1)?Transform(
                                                                          alignment: Alignment.center,
                                                                          transform: Matrix4.rotationY(math.pi),
                                                                          child: Image.network(
                                                                              url,
                                                                              // width: 300,
                                                                              height: 104,
                                                                              fit:BoxFit.cover,

                                                                          ),
                                                                        ):Image.network(
                                                                          url,
                                                                          // width: 300,
                                                                          height: 104,
                                                                          fit:BoxFit.cover,

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
                                                          );
                                                        }
                                                    )
                                                ),
                                              ],
                                            ): Container(
                                              height: MediaQuery.of(context).size.height,
                                              color: Colors.white,
                                            );
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