import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/constants.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/services/database.dart';
import 'package:techstagram/ui/Otheruser/other_user.dart';
import 'package:techstagram/ui/aboutuser.dart';
import 'package:techstagram/ui/followerlist.dart';
import 'package:techstagram/ui/followinglist.dart';
import 'package:techstagram/ui/messagingsystem.dart';
import 'package:techstagram/views/tabs/comments_screen.dart';

import 'HomePage.dart';
import 'ProfileEdit.dart';
import 'profilesettings.dart';

class AccountBottomIconScreen extends StatefulWidget {
  final User user;
  final String uid;

  const AccountBottomIconScreen({this.user,this.uid, Key key}) : super(key: key);

  @override
  _AccountBottomIconScreenState createState() =>
      _AccountBottomIconScreenState(uid: uid);
}

class _AccountBottomIconScreenState extends State<AccountBottomIconScreen> {

  bool isLoading = true;
  bool isEditable = false;
  final String uid;
  _AccountBottomIconScreenState({this.uid});
  String loadingMessage = "Loading Profile Data";
  TextEditingController firstNameController,
      lastNameController,
      emailController,
      phoneNumberController,
      bioController,genderController,linkController,photoUrlController,
      displayNameController,workController,educationController,
      currentCityController,homeTownController,relationshipController,
      followersController,followingController,pinCodeController,userPostsController,uidController;

  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
  DocumentSnapshot postSnap;
  FirebaseUser currUser;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0)
      // user have just tapped on screen (no dragging)
      return;

    if (details.primaryVelocity.compareTo(0) == -1) {
//      dispose();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ConversationPage()),
      );
    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 3)),
      );
    }
  }

  ScrollController scrollController = new ScrollController();

  @override
  void initState() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    pinCodeController = TextEditingController();
    bioController = TextEditingController();
    genderController = TextEditingController();
    linkController = TextEditingController();
    photoUrlController = TextEditingController();
    displayNameController = TextEditingController();
    workController = TextEditingController();
    educationController = TextEditingController();
    currentCityController = TextEditingController();
    homeTownController = TextEditingController();
    relationshipController = TextEditingController();
    pinCodeController = TextEditingController();
    followersController = TextEditingController();
    followingController = TextEditingController();
    userPostsController = TextEditingController();
    uidController = TextEditingController();
    String uiduserX = uid;



    super.initState();
    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));

    fetchProfileData();
  }

//  String displayName;
//  String photoUrl;
//  String bio;
  int followers;
  int following;
  int posts;
  String uidCurrUser;
  String postIdX;

  Stream<QuerySnapshot> userPostsStream;

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


  // fetchUserPost() async{
  //   currUser = await FirebaseAuth.instance.currentUser();
  //   try {
  //     postSnap = Firestore.instance.collection('posts')
  //         .where('uid', isEqualTo: uidController)
  //         .getDocuments() as DocumentSnapshot;
  //     uidCurrUser = postSnap.data["url"];
  //   }  on PlatformException catch (e) {
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

      displayNameController.text = docSnap.data["displayName"];
      uidController.text = docSnap.data["uid"];
      photoUrlController.text = docSnap.data["photoURL"];
      bioController.text = docSnap.data["bio"];
      followers = docSnap.data["followers"];
      following  = docSnap.data["following"];
      posts  = docSnap.data["posts"];

      setState(() {
        isLoading = false;
        isEditable = false;
      });

      getUserPosts(uidController.text);
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
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
  List<DocumentSnapshot> list;

  getlikes( String displayName, String postId) {

    print("uid");
   print(uidController.text);
    Firestore.instance.collection('posts')
        .document(postId)
        .collection('likes')
        .document(displayName)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          liked = true;
          //print("haa");
        });
      }
    });

  }



  @override
  Widget build(BuildContext context) {
    //print("jhj");
    //print(followersController.text);
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) =>
          _onHorizontalDrag(details),
      onTap: () => null,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: Colors.grey.shade300,
        body:  SingleChildScrollView(
          child: SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Stack(
                  children: [
                    Image.asset(
                      "assets/images/social.jpg",
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.fitHeight,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 180.0),
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

                                        displayNameController.text,
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
                                      child: Text(

                                        bioController.text,
                                        style: TextStyle(
                                          fontFamily: 'Source Sans Pro',
                                          fontSize: 15.0,
                                          color: Colors.grey,
                                          letterSpacing: 2.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          GestureDetector(
                                          onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => FollowersList(displayNamecurrentUser:displayNameController.text,uidX: uidController.text,)),
                                    ),
                                              child: _buildStatItem("FOLLOWERS", followers.toString())
                                          ),
                                          _buildStatItem("POSTS", posts.toString()),
                                          GestureDetector(
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => FollowingList(displayNamecurrentUser:displayNameController.text,uidX: uidController.text,)),
                                              ),
                                              child: _buildStatItem("FOLLOWING", following.toString())
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: 120,
                                            child: RaisedButton(
                                                color: Color(0xffed1e79),
                                                child: new Text(
                                                  "About",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                onPressed: () {

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => AboutUser()),
                                                  );
                                                },
                                                shape: RoundedRectangleBorder(
                                                  //side: BorderSide(color: Colors.white, width: 2),
                                                  borderRadius: BorderRadius.circular(30.0),
                                                )),
                                          ),
                                          Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              children: [
                                                SizedBox(
                                                  width: 120,
                                                  child: RaisedButton(
                                                      color: Colors.white,
                                                      child: new Text(
                                                        "Edit Profile",
                                                        style: TextStyle(
                                                          color: Color(0xffed1e79),
                                                        ),
                                                      ),
                                                      onPressed: () {

                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => ProfilePage()),
                                                        );
                                                      },
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(color: Color(0xffed1e79), width: 2),
                                                        borderRadius: BorderRadius.circular(30.0),
                                                      )),
                                                ),



                                                SizedBox(
                                                  width: 120,
                                                  child: RaisedButton(

                                                      color: Colors.white,
                                                      child: new Text(
                                                        "Settings",
                                                        style: TextStyle(
                                                          color: Color(0xffed1e79),
                                                        ),
                                                      ),
                                                      onPressed: () {

                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(builder: (context) => ProfileSettings()),
                                                        );
                                                      },
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(color: Color(0xffed1e79), width: 2),
                                                        borderRadius: BorderRadius.circular(30.0),
                                                      )),
                                                ),
                                              ]
                                          ),
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
                              child: Card(
                                child: StreamBuilder(
                                    stream: userPostsStream,
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
                                                    readTimestamp(timestamp.seconds);

                                                    getlikes(displayNameController.text,postId);


                                                   // print(email);
                                                   // print(displayName);
//                for (int i = 0; i < posts.length; i++) {
//                  if (posts[i].email == email) {
//                    currentpost = posts[i];
//                  }
//                }

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
                                                                            likes, postId, displayNameController.text);
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
                                                                            likes, postId, displayNameController.text);
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
                                                                        var currentUser;
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
                                                  }
                                              )
                                          ),
                                        ],
                                      ): Container(color: Colors.deepPurple,);
                                    }
                                ),
                                //child: Image.network(uidCurrUser),
                              ),
                            )

                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 110,left: 145.0,right: 130.0),
                      child:(photoUrlController.text!=null)?CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(photoUrlController.text),

                        backgroundColor: Colors.transparent,
                      ): CircleAvatar(
                        radius: 20,
                        child: IconButton(icon:
                        Icon(FontAwesomeIcons.userCircle,
                          color: Colors.deepPurple,), onPressed: null),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ]
              ),
            ),
          ),
        ),

//        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//        floatingActionButton: FloatingActionButton(
//        child: Icon(Icons.add),onPressed: null),
      ),
    );
  }


  final String _followers = "17K";
//  final String _posts = "24";
  final String _following = "45K";


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



