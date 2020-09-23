import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/constants.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/ui/aboutuser.dart';
import 'package:techstagram/ui/messagingsystem.dart';

import 'HomePage.dart';
import 'ProfileEdit.dart';
import 'profilesettings.dart';

class AccountBottomIconScreen extends StatefulWidget {
  final User user;

  const AccountBottomIconScreen({this.user, Key key}) : super(key: key);

  @override
  _AccountBottomIconScreenState createState() =>
      _AccountBottomIconScreenState();
}

class _AccountBottomIconScreenState extends State<AccountBottomIconScreen> {

  bool isLoading = true;
  bool isEditable = false;
  String loadingMessage = "Loading Profile Data";
  TextEditingController firstNameController,
      lastNameController,
      emailController,
      phoneNumberController,
      bioController,genderController,linkController,photoUrlController,
      displayNameController,workController,educationController,
      currentCityController,homeTownController,relationshipController,
  followersController,followingController,pinCodeController;

  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
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


    super.initState();
    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));

    fetchProfileData();
  }


  fetchProfileData() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {
      docSnap = await Firestore.instance
          .collection("users")
          .document(currUser.uid)
          .get();
      firstNameController.text = docSnap.data["fname"];
      lastNameController.text = docSnap.data["surname"];
      phoneNumberController.text = docSnap.data["phonenumber"];
      emailController.text = docSnap.data["email"];
      bioController.text = docSnap.data["bio"];
      genderController.text = docSnap.data["gender"];
      linkController.text = docSnap.data["link"];
      photoUrlController.text = docSnap.data["photoURL"];
      displayNameController.text = docSnap.data["displayName"];
      workController.text = docSnap.data["work"];
      educationController.text = docSnap.data["education"];
      currentCityController.text = docSnap.data["currentCity"];
      homeTownController.text = docSnap.data["homeTown"];
      relationshipController.text = docSnap.data["relationship"];
      pinCodeController.text = docSnap.data["pincode"];
      followersController.text = docSnap.data["followers"];
      followingController.text = docSnap.data["following"];
      setState(() {
        isLoading = false;
        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) =>
          _onHorizontalDrag(details),
      onTap: () => Navigator.of(context).pop(true),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        backgroundColor: Colors.grey.shade200,
        body:  SingleChildScrollView(
          child: SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: Stack(
                  children: [
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
                                          _buildStatItem("FOLLOWERS", followersController.text),
                                          _buildStatItem("POSTS", _posts),
                                          _buildStatItem("FOLLOWING", followingController.text),
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
                                                          photoUrlController.text,
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

                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 110,left: 145.0,right: 130.0),
                      child: (photoUrlController!=null)?CircleAvatar(
                        radius: 20,
                        backgroundImage:
                        NetworkImage(photoUrlController.text),
                        backgroundColor: Colors.transparent,
                      ): CircleAvatar(
                        radius: 20,
                        child: IconButton(icon:
                        Icon(Icons.supervised_user_circle,
                          color: Colors.deepPurple,), onPressed: null),
                        backgroundColor: Colors.transparent,
                      ),
                      // child: CircleAvatar(
                      //   radius: 50,
                      //   backgroundImage:
                      //   NetworkImage(photoUrlController.text),
                      //   backgroundColor: Colors.transparent,
                      // ),
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
  final String _posts = "24";
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



