import 'dart:io';
import 'dart:math';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image/image.dart' as ImD;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/ui/followerlist.dart';
import 'package:techstagram/ui/followinglist.dart';
import 'package:techstagram/ui/post.dart';
import 'package:techstagram/utils/utils.dart';
import 'package:techstagram/yammerly_gallery/gallery.dart';

import '../constants.dart';
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
  bool emailVerify;
  final String uid;
  _AccountBottomIconScreenState({this.uid});
  String loadingMessage = "Loading Profile Data";
  TextEditingController firstNameController,
      lastNameController,
      emailController,
      bioController,genderController,linkController,photoUrlController,coverPhotoUrlController,
      displayNameController,workController,educationController,
      phonenumberController,
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
    null;
//      Navigator.push(
//        context,
//        MaterialPageRoute(builder: (context) => ConversationPage()),
//      );
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
    phonenumberController = TextEditingController();
    // emailVerificationController = TextEditingController();
    pinCodeController = TextEditingController();
    bioController = TextEditingController();
    genderController = TextEditingController();
    linkController = TextEditingController();
    photoUrlController = TextEditingController();
    coverPhotoUrlController = TextEditingController();
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
  bool private = false;
  String coverPhotoUrl;
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
      firstNameController.text = docSnap.data["fname"];
      lastNameController.text = docSnap.data["surname"];
      uidController.text = docSnap.data["uid"];
      emailController.text = docSnap.data["email"];
      photoUrlController.text = docSnap.data["photoURL"];
      phonenumberController.text = docSnap.data["phonenumber"];
      emailVerify = docSnap.data["emailVerified"];
      bioController.text = docSnap.data["bio"];
      followers = docSnap.data["followers"];
      following  = docSnap.data["following"];
      posts  = docSnap.data["posts"];
      private = docSnap.data["private"];
      coverPhotoUrlController.text = docSnap.data['coverPhotoUrl'];

      setState(() {
        isLoading = false;
        isEditable = false;
      });

      getUserPosts(uidController.text);
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  File _image;
  int itemCount;

  Future deleteCoverPhoto() async {
    await print(uidController.text);
  print("bababa");
  Firestore.instance
      .collection("users")
      .document(uidController.text)
      .updateData({'coverPhotoUrl': FieldValue.delete()});
  setState(() {
  coverPhotoUrlController.text = null;
  cover = true;
  });
  return AccountBottomIconScreen();
}

  Future pickImagefromCamera() async {
    await ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      setState(() {
        _image = image;
      });
    });
    uploadFile();
    return AccountBottomIconScreen();

  }

  Future pickImage() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
    uploadFile();
    return AccountBottomIconScreen();
  }

  bool isChanged = false;

  compressPhoto() async {
    setState(() {
      isChanged = true;
    });
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    ImD.Image mImageFile = ImD.decodeImage(_image.readAsBytesSync());
    final compressedImage = File('$path/img_$uidController.jpg')
      ..writeAsBytesSync(
        ImD.encodeJpg(mImageFile, quality: 30),
      );
    setState(() {
      _image = compressedImage;

    });
  }

  Future uploadFile() async {

    if(_image!=null){
      await compressPhoto();
    }

    Random randomno = new Random();

    StorageReference storageReference =

    FirebaseStorage.instance
        .ref()
        .child('users/${randomno.nextInt(5000).toString()}.jpg');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {

        coverPhotoUrlController.text = fileURL;
        cover = false;
        Purl = fileURL;
        print("lets see see");
        print(coverPhotoUrlController.text);
        savePostInfoToFirestore(coverPhotoUrlController.text,uidController.text);
      });
    });

  }

  final postReference = Firestore.instance.collection("users");

  savePostInfoToFirestore(String url,String uid) {
    // postReference.where('uid', isEqualTo: uid).getDocuments()
    //     .then((docs) {
    //   Firestore.instance.document(uid).setData({'coverPhotoUrl': url}).then((val) {
    //     print("update ho gaya");
    //   });
    // });

    print(url);
    print("babab");

    Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'coverPhotoUrl': url});

    setState(() {
      isChanged = false;
    });


    print("cover photo");
    print(coverPhotoUrlController.text);
    return AccountBottomIconScreen();
  }

  String Purl;

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

   // print("uid");
   //print(uidController.text);
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

  bool cover = false;


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height*0.20;

    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

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
    //print("jhj");
    //print(followersController.text);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      body:  SingleChildScrollView(
        child: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      print("check");
                      print(coverPhotoUrlController.text);
                      showDialog<void>(
                          context: context,// THIS WAS MISSING// user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Select option :-',style: TextStyle(
                                fontSize: 15.0,
                              ),),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: (){
                                        print("sent image");
                                        pickImage();
                                        // Navigator.push(
                                        //   context,
                                        //   MaterialPageRoute(builder: (context) => gallery()),
                                        // );
                                        Navigator.of(context, rootNavigator: true).pop(context);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(FontAwesomeIcons.images,color: kPrimaryColor,),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 20.0),
                                            child: Text('Set new cover photo'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: GestureDetector(
                                        onTap: (){
                                          pickImagefromCamera();
                                          Navigator.of(context, rootNavigator: true).pop(context);
                                        },
                                        child: Row(
                                          children: [
                                            Icon(FontAwesomeIcons.camera,color: kPrimaryColor,),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 20.0),
                                              child: Text('click from camera'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 20.0),
                                      child: GestureDetector(
                                        onTap: (){
                                          deleteCoverPhoto();
                                          Navigator.of(context, rootNavigator: true).pop(context);
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,color: kPrimaryColor,),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 20.0),
                                              child: Text('Delete cover photo'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                          });
                    },

                    child: Container(
                      height : MediaQuery.of(context).size.height*0.20,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: (coverPhotoUrlController.text == "" || cover == true)?
                          AssetImage('assets/images/gogo.png')
                              :
                          NetworkImage(
                              coverPhotoUrlController.text
                          ),

                          fit: BoxFit.cover,
                        ),
                      ),
                      //color: Colors.lightBlueAccent,
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15.0,top: 5.0),
                        child: Column(
                          children: [
                            Container(
                              height: 30.0,
                              width: 30.0,
                              decoration: const ShapeDecoration(
                                color: Colors.black,
                                shape: CircleBorder(),
                              ),
                              child: IconButton(
                                  color: Colors.white,
                                  //color: Colors.white,
                                  icon: new Icon(
                                      Icons.settings,
                                    size: 15.0,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ProfileSettings(emailController.text,phonenumberController.text,emailVerify,uidController.text)),
                                    );
                                  },
                                  ),
                            ),
                            SizedBox(
                              height: deviceHeight*0.11,
                            ),
                          ],
                        ),
                      ),
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        SizedBox(
                          height: deviceHeight*0.15,
                        ),
                        Container(
                          height: 270.0,
                          width: width,

                            // margin: EdgeInsets.only(top:200, bottom: 70,left: 20,right: 20),
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[

                                    Container(
                                      height: height*0.3,
                                      width: width,
                                      margin: EdgeInsets.only(top: 8.0),
                                      decoration: BoxDecoration(
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 120.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            _buildStatItem("POSTS", posts.toString()),
                                            GestureDetector(
                                                onTap: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) => FollowersList(displayNamecurrentUserX:displayNameController.text,uidX: uidController.text,)),
                                                ),
                                                child: _buildStatItem("FOLLOWERS", followers.toString())
                                            ),

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
                                    ),

                                    SizedBox(
                                      height: 10,
                                      width: 200,
                                    ),

                                    Container(
                                        width: deviceWidth,
                                        child: Row(
                                          children: [
                                            Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .only(
                                                      top: 25.0, left: 20),
                                                  child: Container(
                                                    width: deviceWidth*0.85,
                                                    child: Text(

                                                      firstNameController.text + " " + lastNameController.text,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontSize: 26.0,
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Pacifico',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .only(top: 5.0, left: 20),
                                                  child: Container(
                                                    width: deviceWidth*0.85,
                                                    child: Text(
                                                       displayNameController.text,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontFamily: 'Source Sans Pro',
                                                        fontSize: 15.0,
                                                        color: Colors.grey.shade700,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .only(top: 5.0, left: 20),
                                                  child: Container(
                                                    width: deviceWidth*0.85,
                                                    child: Text(

                                                      bioController.text,
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(
                                                        fontFamily: 'Source Sans Pro',
                                                        fontSize: 15.0,
                                                        color: Colors.grey.shade700,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // SizedBox(
                                            //   width: deviceWidth*0.05,
                                            // ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10.0,),
                                              child: Align(
                                                alignment: Alignment.topRight,
                                                child: SizedBox(
                                                  width: 30,
                                                  height: 30.0,
                                                  child: Ink(
                                                    decoration: const ShapeDecoration(
                                                      color: Colors.black,
                                                      shape: CircleBorder(),
                                                    ),
                                                    child: IconButton(
                                                        color: Colors.white,
                                                        icon: Icon(
                                                          FontAwesomeIcons.userEdit,
                                                          size: 15,
                                                        ),
                                                        //color: Colors.white,
                                                        // child: Padding(
                                                        //   padding: const EdgeInsets.only(right:50.0),
                                                        //   child: Icon(
                                                        //     FontAwesomeIcons.userEdit,
                                                        //     color: Colors.white,
                                                        //     size: 24.0,
                                                        //   ),
                                                        // ),
                                                        onPressed: () {

                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => ProfilePage()),
                                                          );
                                                        }
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                    )

                                  ],
                                ),

                              ],
                            ),
                        ),

                        SizedBox(
                          height: 30,
                          width: deviceWidth * 0.87,
                          child: Divider(
                            thickness: 2.0,
                            color: Colors.teal.shade700,
                          ),
                        ),



                        Container(
                          height: MediaQuery.of(context).size.height * 0.75,
                          //height: 200.0,
                          width: 340.0,

                            child: StreamBuilder(
                                stream: userPostsStream,
                                builder: (context, snapshot) {
                                  if(snapshot.data == null){return Container();}
                                  itemCount = snapshot.data.documents.length;
                                  return (posts != 0)
                                      ? Column(
                                    children: [
                                      new Expanded(
                                          child: GridView.builder(
                                              shrinkWrap: true,
                                             //controller: ScrollController(),
                                              itemCount: itemCount,
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 3,
                                                  crossAxisSpacing: 10.0,
                                                  mainAxisSpacing: 10.0),
                                              itemBuilder: (context, index) {

                                                postIdX = snapshot.data.documents[index]['postId'];

                                                String email = snapshot.data.documents[index]['email'];

                                                String description = snapshot.data.documents[index]['description'];

                                                String displayName = snapshot.data.documents[index]['displayName'];

                                                String photoUrl = snapshot.data.documents[index]['photoURL'];

                                                String uid = snapshot.data.documents[index]["uid"];

                                                int cam = snapshot.data.documents[index]['cam'];

                                                Timestamp timestamp = snapshot.data.documents[index]['timestamp'];

                                                String url = snapshot.data.documents[index]['url'];

                                                String postId = snapshot.data.documents[index]['postId'];

                                                int likes = snapshot.data.documents[index]['likes'];

                                                readTimestamp(timestamp.seconds);

                                                getlikes(displayNameController.text,postId);


                                                if(likes< 0 || likes == 0){
                                                  liked = false;
                                                }

                                                return Container(
                                                  color: Colors.grey.shade300,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(builder: (context) => postPage(displayNamecurrentUser: displayName,PostUrl: url,uidX: uid,delete: true,)),
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
                                                );
                                              }

                                          )
                                      ),
                                    ],
                                  ): Container(
                                    padding: EdgeInsets.only(
                                      top: 5.0,
                                      left: 30.0,
                                      right: 30.0,
                                      bottom: 5.0,
                                    ),
                                    //height: 200,
                                    height: deviceHeight * 0.20,
                                    width: deviceWidth,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        //pageTitle,
                                        // SizedBox(
                                        //   height: deviceHeight * 0.1,
                                        // ),
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
                                }
                            ),
                            //child: Image.network(uidCurrUser),
                        )

                      ],
                    ),
                  ),

                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      height: deviceHeight*0.31,
                      width: deviceWidth*0.96,
//                    padding: const EdgeInsets.only(right: 250.0),
                      child:(photoUrlController.text!=null)?Align(
                        alignment: Alignment.bottomLeft,
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
                              image: NetworkImage(photoUrlController.text),
                              fit: BoxFit.cover,
                            ),
                            //backgroundImage: NetworkImage(photoUrlController.text)
                          )
                        ),
                      ): Container(
                        child: IconButton(icon:
                        Icon(FontAwesomeIcons.userCircle,
                          color: Colors.deepPurple,), onPressed: (){print("hello");}),
                      ),
                    ),
                  ),
                ],
                  ),
          ),
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
      Flexible(
        child: Text(
          label,
          style: _statLabelTextStyle,
        ),
      ),
      Text(
        count,
        style: _statCountTextStyle,
      ),

    ],
  );
}



