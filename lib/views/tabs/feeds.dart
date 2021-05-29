import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:techstagram/Widget/Fab.dart';
import 'package:techstagram/models/posts.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/resources/uploadimage.dart';
import 'package:techstagram/services/database.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/ui/Otheruser/other_user.dart';
import 'package:techstagram/ui/post.dart';
import 'package:techstagram/utils/utils.dart';
import 'package:techstagram/views/tabs/comments_screen.dart';
import 'package:techstagram/yammerly_gallery/gallery.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:uuid/uuid.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:cached_network_image/cached_network_image.dart';

class FeedsPage extends StatefulWidget {
  final String displayNamecurrentUser;

  @override
  FeedsPage({
    this.displayNamecurrentUser,
  });

  @override
  _FeedsPageState createState() =>
      _FeedsPageState(displayNamecurrentUser: displayNamecurrentUser);
}

class _FeedsPageState extends State<FeedsPage> {
  final String displayNamecurrentUser;
  List<Posts> posts;
  List<DocumentSnapshot> list;
  Map<String, dynamic> _profile;
  bool _loading = false;
  DocumentSnapshot docSnap;
  User currUser;
  ScrollController scrollController = new ScrollController();
  Posts currentpost;
  List<bool> likess = List.filled(10000, false);

  double _scale = 1.0;
  double _previousScale;
  var yOffset = 400.0;
  var xOffset = 50.0;
  var rotation = 0.0;
  var lastRotation = 0.0;
  var time = "s";
  User currentUser;
  String NotificationId = Uuid().v4();

  File _image;
  bool upload;
  int likescount;
  bool loading = false;
  int Plength;

  Stream<QuerySnapshot> postsStream;
  final timelineReference = FirebaseFirestore.instance.collection('posts');
  String postIdX;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController emailController,
      urlController,
      descriptionController,
      displayNameController,
      photoUrlController,
      timestampController,
      likesController,
      uidController,
      cpurlController,
      cdisplayNameController;

  _FeedsPageState({this.displayNamecurrentUser, this.postIdX});

  @override
  void initState() {
    emailController = TextEditingController();
    likesController = TextEditingController();
    uidController = TextEditingController();
    displayNameController = TextEditingController();
    photoUrlController = TextEditingController();
    cpurlController = TextEditingController();
    cdisplayNameController = TextEditingController();

    //videoPlayerController = VideoPlayerController.network('');

    super.initState();

    // BetterPlayerDataSource betterPlayerDataSource;
    //
    // _betterPlayerController = BetterPlayerController(
    //     BetterPlayerConfiguration(),
    //     betterPlayerDataSource: betterPlayerDataSource);

    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));
    fetchPosts();
    fetchProfileData();
    fetchLikes();
    //getPostCount();
  }

  File crop;
  Timer timer; //declare timer variable

  // getPostCount() async {
  //   await DatabaseService().getPosts().then((val){
  //     setState(() {
  //       Plength = val;
  //     });
  //   });
  //   print("yaha ai bhai length");
  //   print(Plength);
  // }

  Future pickImage() async {
    if (_image == null) {
      // ignore: deprecated_member_use
      await ImagePicker().getImage(source: ImageSource.gallery).then((image) {
        setState(() async {
          if (image != null) {
            crop = await ImageCropper.cropImage(
                sourcePath: image.path,
                aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
                compressQuality: 100,
                maxWidth: 700,
                maxHeight: 700,
                compressFormat: ImageCompressFormat.jpg,
                androidUiSettings: AndroidUiSettings(
                  toolbarColor: Colors.white,
                  toolbarTitle: "AIO Cropper",
                  activeControlsWidgetColor: Colors.purple,
                  toolbarWidgetColor: Colors.deepPurple,
                  statusBarColor: Colors.purple,
                  backgroundColor: Colors.white,
                  showCropGrid: false,
                  dimmedLayerColor: Colors.black54,
                ));
            upload = true;
            _image = crop;
            if (_image != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UploadImage(isVideo: false, file: _image),
                  ));
            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(initialindexg: 1),
                  ));
            }
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(initialindexg: 1),
                ));
          }
        });
      });
      if (_image != null) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploadImage(isVideo: false, file: _image),
            ));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(initialindexg: 1),
            ));
      }
    } else if (crop == null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(initialindexg: 1),
          ));
    }

//    Navigator.push(
//      context,
//      MaterialPageRoute(builder: (context) => UploadImage(file: _image,)),
//    );
    print("Done..");
  }

  fetchPosts() async {
    await DatabaseService().getPosts().then((val) {
      setState(() {
        postsStream = val;
      });
    });

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
          likess[index] = true;
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
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  fetchProfileData() async {
    currUser =  FirebaseAuth.instance.currentUser;
    try {
      docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUser.uid)
          .get();
      emailController.text = (docSnap.data()as Map<String,dynamic>)["email"];
      likesController.text = (docSnap.data()as Map<String,dynamic>)["likes"];
      uidController.text = (docSnap.data()as Map<String,dynamic>)["uid"];
      displayNameController.text = (docSnap.data()as Map<String,dynamic>)["displayName"];
      photoUrlController.text = (docSnap.data()as Map<String,dynamic>)["photoURL"];
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  List<String> cpurl = new List<String>(10000);
  List<String> cdisplayName = new List<String>(10000);

  //bool cloading = false;
  List<bool> cloading = List.filled(10000, false);

  Fetchprofile(String uid, int index) async {
    docSnap = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    cpurlController.text = (docSnap.data()as Map<String,dynamic>)['photoURL'];
    cdisplayNameController.text = (docSnap.data()as Map<String,dynamic>)['displayName'];
    setState(() {
      cpurl[index] = cpurlController.text;
      cdisplayName[index] = cdisplayNameController.text;
      cloading[index] = true;
    });
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
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

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final image = Image.asset(
      AvailableImages.emptyState['assetPath'],
    );

    final notificationHeader = Container(
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
      child: Text(
        "No Posts",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
      ),
    );

    addStringToSF(String displayName, String displayNameCurrUser, String postId,
        int comments) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('displayName', displayName);
      prefs.setString('displayNameCurrUser', displayNameCurrUser);
      prefs.setString('postId', postId);
      prefs.setInt('commCount', 0);
      prefs.setInt('comments', comments);
    }

    return Scaffold(
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
                          print(len);
                          print("length batar hai");
                          //postIdX = snapshot.data.docs[index]['postId'];

                          var aja = snapshot.data.docs[index];

                          String email =
                              aja['email'];

                          String description =
                              aja['description'];


                          String displayName =
                              aja['displayName'];

                          String photoUrl =
                          aja['photoURL'];

                          String OwnerDisplayName = aja['OwnerDisplayName'];

                          String OwnerPhotourl =
                          aja['OwnerPhotourl'];

                          String OwnerDescription = aja['OwnerDescription'];

                          bool shared =
                          aja['shared'];

                          String uid = aja["uid"];

                          int shares = aja["shares"];

                          Timestamp timestamp =
                          aja['timestamp'];

                          String url = aja['url'];

                          int cam = aja['cam'];

                          String postId =
                          aja['postId'];

                          int likes = aja['likes'];

                          int comments =
                          aja['comments'];

                          Timestamp OwnertimeStamp =
                          aja['OwnerTimeStamp'];

                          String OwnerUid =
                          aja['OwnerUid'];

                          bool isVideo =
                          aja['isVideo'];

                          if (isVideo == null) {
                            isVideo = false;
                          }

                          bool button = true;

                          // setState(() async {
                          //   SharedPreferences prefs = await SharedPreferences.getInstance();
                          //   button = prefs.getBool("button" ?? true);
                          // });

                          readTimestamp(timestamp.seconds);

                          Fetchprofile(uid, index);

                          if (likes == 0 || likes < 0) {
                            likess[index] == false;
                            likes = 0;
                          }

                          getlikes(displayNamecurrentUser, postId, index);

                          ShareNotification(String displayNameCurrUser) async {
                            print(displayNameCurrUser);
                            print(displayNamecurrentUser);
                            print("911");

                            if (displayName != displayNameCurrUser) {
                              setState(() {
                                // file = null;
                                NotificationId = Uuid().v4();
                              });

                              return await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(uid)
                                  .collection("notification")
                                  .doc(NotificationId)
                                  .set({
                                "share": shares + 1,
                                "notificationId": NotificationId,
                                //"comment": commentTextEditingController.text,

                                "timestamp": DateTime.now(),
                                "uid": uidController.text,
                                "status": "share",
                                "postId": postId,
                              });
                            }

                            // return await FirebaseFirestore.instance.collection("users")
                            //     .doc(uid).collection("notification")
                            //     .doc(NotificationId)
                            //     .setData({"share" : shares+1,
                            //   "notificationId" : NotificationId,
                            //   "username": displayNamecurrentUser,
                            //   //"comment": commentTextEditingController.text,
                            //   "timestamp": DateTime.now(),
                            //   "url": photoUrl,
                            //   "uid": uid,
                            //   "status" : "Share",
                            //   "postId" : postId,
                            //   "postUrl" : url,
                            // });
                          }

                          Notification() async {
                            // print(displayNameCurrUser);
                            // print(displayNamecurrentUser);
                            print("911");

                            if (displayName != displayNamecurrentUser) {
                              print("911");

                              setState(() {
                                // file = null;
                                NotificationId = Uuid().v4();
                              });

                              print(uid);
                              print(uidController.text);
                              print("912");
                              return await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(uid)
                                  .collection("notification")
                                  .doc(NotificationId)
                                  .set({
                                "likes": likes + 1,
                                "notificationId": NotificationId,
                                //"comment": commentTextEditingController.text,

                                "timestamp": DateTime.now(),
                                "uid": uidController.text,
                                "status": "like",
                                "postId": postId,
                              });
                            }

                            // return await FirebaseFirestore.instance.collection("users")
                            //     .doc(uid).collection("notification")
                            //     .doc(NotificationId)
                            //     .setData({"likes" : likes+1,
                            //   "notificationId" : NotificationId,
                            //   "username": displayNameCurrUser,
                            //   //"comment": commentTextEditingController.text,
                            //
                            //   "timestamp": DateTime.now(),
                            //   "url": photoUrl,
                            //   "uid": uid,
                            //   "status" : "like",
                            //   "postId" : postId,
                            //   "postUrl" : url,
                            // });
                          }

                          DeleteNotification(String displayName) {
                            FirebaseFirestore.instance
                                .collection("users")
                                .doc(uid)
                                .collection('notification')
                                //.where('displayName','==',displayName);
                                .doc(displayName)
                                .delete();
                          }

                          return (shared == true)
                              ? Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                          width: 10.0, color: Colors.grey[100]),
                                    ),
                                    color: Colors.white,
                                  ),
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
                                              bottom: 5.0),
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
                                                          image: (cpurl[
                                                                      index] !=
                                                                  null)
                                                              ? (cloading[
                                                                      index])
                                                                  ? NetworkImage(
                                                                      cpurl[
                                                                          index])
                                                                  : NetworkImage(
                                                                      "url")
                                                              : NetworkImage(
                                                                  "https://w7.pngwing.com/pngs/281/431/png-transparent-computer-icons-avatar-user-profile-online-identity-avatar.png"),
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      (cloading[index])
                                                          ? Text(
                                                              cdisplayName[
                                                                  index],
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18.0,
                                                              ),
                                                            )
                                                          : Container(
                                                              child: Text(
                                                                  "Loading...")),
                                                    ],
                                                  ),
                                                  IconButton(
                                                    icon: Icon(SimpleLineIcons
                                                        .options),
                                                    onPressed: () {},
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 0.0),
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => postPage(
                                                    displayNamecurrentUser:
                                                        OwnerDisplayName,
                                                    PostUrl: url,
                                                    uidX: OwnerUid,
                                                    delete: false)),
                                            // MaterialPageRoute(builder: (context) => postPage(PostUrl: url,)),
                                          ),
                                          child: Container(
                                            width: deviceWidth * 0.95,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                    width: 1.0,
                                                    color: Colors.grey),
                                                //left: BorderSide(width: 1.0, color: Colors.grey),
                                                //right: BorderSide(width: 1.0, color: Colors.grey)
                                                //bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15.0,
                                                  right: 15.0,
                                                  top: 10.0,
                                                  bottom: 5.0),
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
                                                                    .circular(
                                                                        40),
                                                            child: Image(
                                                              image: NetworkImage(
                                                                  OwnerPhotourl),
                                                              width: 30,
                                                              height: 30,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            OwnerDisplayName,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12.0,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 8.0),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.8,
                                                          child: RichText(
                                                            textAlign:
                                                                TextAlign.start,
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .visible,
                                                            text: TextSpan(
                                                              children: [
                                                                // TextSpan(
                                                                //   text: "  "+OwnerDisplayName + " ",
                                                                //   style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,
                                                                //       fontSize: 18.0),
                                                                // ),
                                                                TextSpan(
                                                                  text:
                                                                      OwnerDescription,
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
                                                        (OwnertimeStamp == null)
                                                            ? Container()
                                                            : Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        top: 3),
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
                                                                        //text: readTimestamp(OwnerTimeStamp.seconds),
                                                                        text: readTimestamp(
                                                                            OwnertimeStamp.seconds),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey,
                                                                            fontWeight: FontWeight.normal,
                                                                            fontSize: 8.0),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onDoubleTap: () {
                                          if (likess[index] == false) {
                                            setState(() {
                                              likess[index] = true;
                                            });

                                            DatabaseService().likepost(
                                                likes,
                                                postId,
                                                uidController.text,
                                                displayNameController.text);
                                          }
                                        },
                                        onTap: null,
                                        child: GestureDetector(
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => postPage(
                                                    displayNamecurrentUser:
                                                        OwnerDisplayName,
                                                    PostUrl: url,
                                                    uidX: OwnerUid,
                                                    delete: false)),
                                          ),
                                          child: Container(
                                            //height: 450.0,
                                            width: deviceWidth,

                                            decoration: BoxDecoration(
                                                // border: Border(
                                                //     bottom: BorderSide(width: 2.0, color: Colors.grey),
                                                //     left: BorderSide(width: 2.0, color: Colors.grey),
                                                //     right: BorderSide(width: 2.0, color: Colors.grey)
                                                //   //bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                                // ),
                                                ),
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
                                                              : (!cloading[
                                                                      index])
                                                                  ? Container()
                                                                  : CachedNetworkImage(
                                                                      imageUrl:
                                                                          url),
                                                          //image: NetworkImage("posts[i].postImage"),
                                                        )
                                                      : (url == null)
                                                          ? Container()
                                                          : (!cloading[index])
                                                              ? Container()
                                                              : CachedNetworkImage(
                                                                  imageUrl:
                                                                      url),
                                                ),
                                                // GestureDetector(
                                                //   child : (cam == 1)? Transform(
                                                //     alignment: Alignment.center,
                                                //     transform: Matrix4.rotationY(math.pi),
                                                //     child: (url==null)?Container():(!cloading[index])?Container():FadeInImage.memoryNetwork(
                                                //       image: url,
                                                //       fit: BoxFit.cover,
                                                //       //image: NetworkImage("posts[i].postImage"),
                                                //       placeholder: kTransparentImage,//AssetImage("assets/images/loading.gif"),
                                                //       width: MediaQuery.of(context).size.width,
                                                //     ),
                                                //   ):(url==null)?Container():(!cloading[index])?Container():FadeInImage.memoryNetwork(
                                                //     image: url,//NetworkImage(url),
                                                //     fit: BoxFit.cover,
                                                //     //image: NetworkImage("posts[i].postImage"),
                                                //     placeholder: kTransparentImage,//AssetImage("assets/images/loading.gif"),
                                                //     width: MediaQuery.of(context).size.width,
                                                //   ),
                                                // ),

                                                Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.95,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                          width: 1.0,
                                                          color: Colors.grey),
                                                      //left: BorderSide(width: 1.0, color: Colors.grey),
                                                      //right: BorderSide(width: 1.0, color: Colors.grey)
                                                      //bottom: BorderSide(width: 16.0, color: Colors.lightBlue.shade900),
                                                    ),
                                                  ),
                                                  // margin: EdgeInsets.symmetric(
                                                  //   horizontal: 14,
                                                  // ),
                                                )
                                              ],
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
                                                            DeleteNotification(
                                                                displayNamecurrentUser);
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
                                                            Notification();
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
                                                padding: const EdgeInsets.only(
                                                    top: 3.0),
                                                child: IconButton(
                                                  onPressed: () {
                                                    Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return CommentsPage(
                                                          currUser:
                                                              uidController
                                                                  .text,
                                                          comments: comments,
                                                          postId: postId,
                                                          uid: uid,
                                                          postImageUrl: url,
                                                          timestamp: timestamp,
                                                          displayName:
                                                              cdisplayName[
                                                                  index],
                                                          photoUrl:
                                                              photoUrlController
                                                                  .text,
                                                          displayNamecurrentUser:
                                                              displayNameController
                                                                  .text);
                                                    }));

                                                    addStringToSF(
                                                        cdisplayName[index],
                                                        displayNameController
                                                            .text,
                                                        postId,
                                                        comments);
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
                                                  ShareNotification(
                                                      displayNamecurrentUser);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => UploadImage(
                                                            isVideo: false,
                                                            ownerPostId:
                                                                postIdX,
                                                            file: File(url),
                                                            sharedurl: url,
                                                            ownerdiscription:
                                                                OwnerDescription,
                                                            ownerphotourl:
                                                                OwnerPhotourl,
                                                            ownerdisplayname:
                                                                OwnerDisplayName,
                                                            shared: true,
                                                            cam: cam,
                                                            ownerUid:
                                                                OwnerUid)),
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
                                      (description == null)
                                          ? null
                                          : Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              margin: EdgeInsets.symmetric(
                                                horizontal: 14,
                                              ),
                                              child: Row(
                                                children: [
                                                  (description != null)
                                                      ? Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.9,
                                                          child: RichText(
                                                            textAlign:
                                                                TextAlign.start,
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
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
                                                                  text:
                                                                      description,
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
                                                        )
                                                      : Container(),
                                                ],
                                              )),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 5),
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

                                  // post container
                                )
                              : (isVideo)
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              width: 10.0,
                                              color: Colors.grey[100]),
                                        ),
                                        color: Colors.white,
                                      ),
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
                                                        displayName:
                                                            displayName,
                                                        uidX:
                                                            uidController.text,
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
                                                            BorderRadius
                                                                .circular(40),
                                                        child: Image(
                                                          image: (cpurl != null)
                                                              ? (cloading[
                                                                      index])
                                                                  ? NetworkImage(
                                                                      cpurl[
                                                                          index])
                                                                  : NetworkImage(
                                                                      "https://w7.pngwing.com/pngs/281/431/png-transparent-computer-icons-avatar-user-profile-online-identity-avatar.png")
                                                              : NetworkImage(
                                                                  "https://w7.pngwing.com/pngs/281/431/png-transparent-computer-icons-avatar-user-profile-online-identity-avatar.png"),
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      (cloading[index])
                                                          ? Text(
                                                              cdisplayName[
                                                                  index],
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18.0,
                                                              ),
                                                            )
                                                          : Container(
                                                              child: Text(
                                                                  "Loading...")),
                                                    ],
                                                  ),
                                                  IconButton(
                                                    icon: Icon(SimpleLineIcons
                                                        .options),
                                                    onPressed: () {},
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

                                                await DatabaseService()
                                                    .likepost(
                                                        likes,
                                                        postId,
                                                        uidController.text,
                                                        displayNameController
                                                            .text);
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
                                                        child: (url == null)
                                                            ? Container()
                                                            : (!cloading[index])
                                                                ? Container()
                                                                : Container(
                                                                    height: 500,
                                                                    margin: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            2.5),
                                                                    child:
                                                                        AspectRatio(
                                                                      aspectRatio:
                                                                          1,
                                                                      //
                                                                      //
                                                                      child: Text(
                                                                          "hello"),
                                                                      // ChatsPage(
                                                                      //   betterPlayerDataSource = BetterPlayerDataSource(
                                                                      //     BetterPlayerDataSourceType.NETWORK,
                                                                      //     'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
                                                                      //   ),
                                                                      //   key: Key('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'.hashCode.toString()),
                                                                      //   playFraction: 1,
                                                                      //   autoPause: true,
                                                                      //   autoPlay: true,
                                                                      //   configuration: BetterPlayerConfiguration(
                                                                      //     fit: BoxFit.cover,
                                                                      //     aspectRatio: 0.5,
                                                                      //     looping: true,
                                                                      //     autoPlay: true,
                                                                      //     showPlaceholderUntilPlay: true,
                                                                      //     // placeholder: Container(
                                                                      //     //   height: 500,
                                                                      //     //   width: double.infinity,
                                                                      //     //   decoration: BoxDecoration(
                                                                      //     //     // gradient: LinearGradient(
                                                                      //     //     //   colors: [
                                                                      //     //     //     Colors.blue,
                                                                      //     //     //     Colors.red,
                                                                      //     //     //   ],
                                                                      //     //     //   begin: Alignment.topLeft,
                                                                      //     //     //   end: Alignment.bottomRight,
                                                                      //     //     // ),
                                                                      //     //     color: Colors.purple,
                                                                      //     //   ),
                                                                      //     // ),
                                                                      //     controlsConfiguration: BetterPlayerControlsConfiguration(
                                                                      //       enableProgressBar: false,
                                                                      //       controlBarColor: Colors.white54,
                                                                      //       enableFullscreen: false,
                                                                      //       enableOverflowMenu: false,
                                                                      //       enablePlayPause: true,
                                                                      //     ),
                                                                      //     errorBuilder: (context, errorMessage) {
                                                                      //       return Center(
                                                                      //         child: Column(
                                                                      //           children: [
                                                                      //             Icon(
                                                                      //               Icons.error,
                                                                      //               color: Colors.white,
                                                                      //               size: 60,
                                                                      //             ),
                                                                      //             Text(
                                                                      //               errorMessage,
                                                                      //               style: TextStyle(color: Colors.white54),
                                                                      //             ),
                                                                      //           ],
                                                                      //         ),
                                                                      //       );
                                                                      //     },
                                                                      //   ),
                                                                      // ),
                                                                    ),
                                                                  ),
                                                      )
                                                    : (url == null)
                                                        ? Container()
                                                        : (!cloading[index])
                                                            ? Container()
                                                            : AspectRatio(
                                                                aspectRatio:
                                                                    16 / 9,
                                                                //
                                                                //

                                                                child: Text(
                                                                    "hello"),
                                                                // BetterPlayerListVideoPlayer(
                                                                //   BetterPlayerDataSource(
                                                                //     BetterPlayerDataSourceType.NETWORK,
                                                                //     'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
                                                                //   ),
                                                                //   key: Key('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'.hashCode.toString()),
                                                                //   playFraction: 1,
                                                                //   autoPause: true,
                                                                //   autoPlay: true,
                                                                //   configuration: BetterPlayerConfiguration(
                                                                //     fit: BoxFit.cover,
                                                                //     aspectRatio: 0.5,
                                                                //     looping: true,
                                                                //     autoPlay: true,
                                                                //     showPlaceholderUntilPlay: true,
                                                                //     // placeholder: Container(
                                                                //     //   height: 500,
                                                                //     //   width: double.infinity,
                                                                //     //   decoration: BoxDecoration(
                                                                //     //     // gradient: LinearGradient(
                                                                //     //     //   colors: [
                                                                //     //     //     Colors.blue,
                                                                //     //     //     Colors.red,
                                                                //     //     //   ],
                                                                //     //     //   begin: Alignment.topLeft,
                                                                //     //     //   end: Alignment.bottomRight,
                                                                //     //     // ),
                                                                //     //     color : Colors.purple,
                                                                //     //   ),
                                                                //     // ),
                                                                //     controlsConfiguration: BetterPlayerControlsConfiguration(
                                                                //       enableProgressBar: false,
                                                                //       controlBarColor: Colors.white54,
                                                                //       enableFullscreen: false,
                                                                //       enableOverflowMenu: false,
                                                                //       enablePlayPause: true,
                                                                //     ),
                                                                //     errorBuilder: (context, errorMessage) {
                                                                //       return Center(
                                                                //         child: Column(
                                                                //           children: [
                                                                //             Icon(
                                                                //               Icons.error,
                                                                //               color: Colors.white,
                                                                //               size: 60,
                                                                //             ),
                                                                //             Text(
                                                                //               errorMessage,
                                                                //               style: TextStyle(color: Colors.white54),
                                                                //             ),
                                                                //           ],
                                                                //         ),
                                                                //       );
                                                                //     },
                                                                //   ),
                                                                // ),
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
                                                  (button == true)
                                                      ? IconButton(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          onPressed:
                                                              (likess[index] ==
                                                                      true)
                                                                  ? () {
                                                                      if (timer
                                                                              ?.isActive ??
                                                                          false)
                                                                        timer
                                                                            .cancel(); //cancel if [timer] is null or running
                                                                      timer =
                                                                          Timer(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                340),
                                                                        () {
                                                                          setState(
                                                                              () {
                                                                            likess[index] =
                                                                                false;
                                                                            loading =
                                                                                true;
                                                                          });
                                                                          DatabaseService().unlikepost(
                                                                              likes,
                                                                              postId,
                                                                              uidController.text,
                                                                              displayNameController.text);
                                                                          DeleteNotification(
                                                                              displayNamecurrentUser);
                                                                        },
                                                                      );
                                                                    }
                                                                  : () {
                                                                      if (timer
                                                                              ?.isActive ??
                                                                          false)
                                                                        timer
                                                                            .cancel(); //cancel if [timer] is null or running
                                                                      timer =
                                                                          Timer(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                340),
                                                                        () {
                                                                          setState(
                                                                              () {
                                                                            likess[index] =
                                                                                true;
                                                                            loading =
                                                                                true;
                                                                          });
                                                                          DatabaseService().likepost(
                                                                              likes,
                                                                              postId,
                                                                              uidController.text,
                                                                              displayNameController.text);
                                                                          Notification();
                                                                        },
                                                                      );
                                                                    },
                                                          icon: Icon(
                                                              Icons.thumb_up),
                                                          iconSize: 25,
                                                          color: (likess[
                                                                      index] ==
                                                                  true)
                                                              ? Colors
                                                                  .deepPurple
                                                              : Colors.grey,
                                                        )
                                                      : Container(
                                                          color: Colors.red),
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
                                                              currUser:
                                                                  uidController
                                                                      .text,
                                                              comments:
                                                                  comments,
                                                              postId: postId,
                                                              uid: uid,
                                                              postImageUrl: url,
                                                              timestamp:
                                                                  timestamp,
                                                              displayName:
                                                                  cdisplayName[
                                                                      index],
                                                              photoUrl:
                                                                  photoUrlController
                                                                      .text,
                                                              displayNamecurrentUser:
                                                                  displayNameController
                                                                      .text);
                                                        }));
                                                        addStringToSF(
                                                            cdisplayName[index],
                                                            displayNameController
                                                                .text,
                                                            postId,
                                                            comments);
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
                                                      ShareNotification(
                                                          displayNamecurrentUser);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => UploadImage(
                                                                isVideo: false,
                                                                ownerUid: uid,
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
                                          (description != null)
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.9,
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
                                                                text:
                                                                    description,
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
                                                      )
                                                    ],
                                                  ))
                                              : Container(
                                                  height: 1.0,
                                                ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 5.0),
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
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              width: 10.0,
                                              color: Colors.grey[100]),
                                        ),
                                        color: Colors.white,
                                      ),
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
                                                        displayName:
                                                            displayName,
                                                        uidX:
                                                            uidController.text,
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
                                                            BorderRadius
                                                                .circular(40),
                                                        child: Image(
                                                          image: (cpurl != null)
                                                              ? (cloading[
                                                                      index])
                                                                  ? NetworkImage(
                                                                      cpurl[
                                                                          index])
                                                                  : NetworkImage(
                                                                      "https://w7.pngwing.com/pngs/281/431/png-transparent-computer-icons-avatar-user-profile-online-identity-avatar.png")
                                                              : NetworkImage(
                                                                  "https://w7.pngwing.com/pngs/281/431/png-transparent-computer-icons-avatar-user-profile-online-identity-avatar.png"),
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      (cloading[index])
                                                          ? Text(
                                                              cdisplayName[
                                                                  index],
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18.0,
                                                              ),
                                                            )
                                                          : Container(
                                                              child: Text(
                                                                  "Loading...")),
                                                    ],
                                                  ),
                                                  IconButton(
                                                    icon: Icon(SimpleLineIcons
                                                        .options),
                                                    onPressed: () {},
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

                                                await DatabaseService()
                                                    .likepost(
                                                        likes,
                                                        postId,
                                                        uidController.text,
                                                        displayNameController
                                                            .text);
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
                                                        child: (url == null)
                                                            ? Container()
                                                            : (!cloading[index])
                                                                ? Container()
                                                                : FadeInImage
                                                                    .memoryNetwork(
                                                                    image:
                                                                        url, //NetworkImage(url),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    //image: NetworkImage("posts[i].postImage"),
                                                                    placeholder:
                                                                        kTransparentImage, //AssetImage("assets/images/loading.gif"),
                                                                    width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width,
                                                                  ),
                                                      )
                                                    : (url == null)
                                                        ? Container()
                                                        : (!cloading[index])
                                                            ? Container()
                                                            : FadeInImage
                                                                .memoryNetwork(
                                                                image:
                                                                    url, //NetworkImage(url,),
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder:
                                                                    kTransparentImage, //AssetImage("assets/images/loading.gif"),
                                                                width: MediaQuery.of(
                                                                        context)
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
                                                  (button == true)
                                                      ? IconButton(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10),
                                                          onPressed:
                                                              (likess[index] ==
                                                                      true)
                                                                  ? () {
                                                                      if (timer
                                                                              ?.isActive ??
                                                                          false)
                                                                        timer
                                                                            .cancel(); //cancel if [timer] is null or running
                                                                      timer =
                                                                          Timer(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                340),
                                                                        () {
                                                                          setState(
                                                                              () {
                                                                            likess[index] =
                                                                                false;
                                                                            loading =
                                                                                true;
                                                                          });
                                                                          DatabaseService().unlikepost(
                                                                              likes,
                                                                              postId,
                                                                              uidController.text,
                                                                              displayNameController.text);
                                                                          DeleteNotification(
                                                                              displayNamecurrentUser);
                                                                        },
                                                                      );
                                                                    }
                                                                  : () {
                                                                      if (timer
                                                                              ?.isActive ??
                                                                          false)
                                                                        timer
                                                                            .cancel(); //cancel if [timer] is null or running
                                                                      timer =
                                                                          Timer(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                340),
                                                                        () {
                                                                          setState(
                                                                              () {
                                                                            likess[index] =
                                                                                true;
                                                                            loading =
                                                                                true;
                                                                          });
                                                                          DatabaseService().likepost(
                                                                              likes,
                                                                              postId,
                                                                              uidController.text,
                                                                              displayNameController.text);
                                                                          Notification();
                                                                        },
                                                                      );
                                                                    },
                                                          icon: Icon(
                                                              Icons.thumb_up),
                                                          iconSize: 25,
                                                          color: (likess[
                                                                      index] ==
                                                                  true)
                                                              ? Colors
                                                                  .deepPurple
                                                              : Colors.grey,
                                                        )
                                                      : Container(
                                                          color: Colors.red),
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
                                                              currUser:
                                                                  uidController
                                                                      .text,
                                                              comments:
                                                                  comments,
                                                              postId: postId,
                                                              uid: uid,
                                                              postImageUrl: url,
                                                              timestamp:
                                                                  timestamp,
                                                              displayName:
                                                                  cdisplayName[
                                                                      index],
                                                              photoUrl:
                                                                  photoUrlController
                                                                      .text,
                                                              displayNamecurrentUser:
                                                                  displayNameController
                                                                      .text);
                                                        }));
                                                        addStringToSF(
                                                            cdisplayName[index],
                                                            displayNameController
                                                                .text,
                                                            postId,
                                                            comments);
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
                                                      ShareNotification(
                                                          displayNamecurrentUser);
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) => UploadImage(
                                                                isVideo: false,
                                                                ownerUid: uid,
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
                                          (description != null)
                                              ? Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  margin: EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.9,
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
                                                                text:
                                                                    description,
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
                                                      )
                                                    ],
                                                  ))
                                              : Container(
                                                  height: 1.0,
                                                ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 5.0),
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
              : Container(
                  padding: EdgeInsets.only(
                    top: 40.0,
                    left: 30.0,
                    right: 30.0,
                    bottom: 30.0,
                  ),
                  height: deviceHeight,
                  width: deviceWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //pageTitle,
                      SizedBox(
                        height: deviceHeight * 0.1,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          image,
                          notificationHeader,
                          //notificationText,
                        ],
                      ),
                    ],
                  ),
                );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(
          CupertinoIcons.add,
          color: Colors.purple,
          size: 40.0,
        ),
        onPressed: () {
          // pickImage();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => gallery()),
          );
        },
      ),
    );
  }
}
