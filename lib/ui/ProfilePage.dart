import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/ui/messagingsystem.dart';

import 'HomePage.dart';
import 'ProfileEdit.dart';

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
      displaynameController,
      phoneNumberController,
  bioController;

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
    bioController = TextEditingController();
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
      setState(() {
        isLoading = false;
        isEditable = false;
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
        key: _scaffoldKey,
        body: new Column(
          children: <Widget>[
            _appBar(),
            _profilex(),
            _centerButtons(),
            _displayImages()
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return new Container(
      color: Colors.white,
      padding: new EdgeInsets.only(top: 25.0),
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Padding(
                padding: new EdgeInsets.only(left: 10.0),
                child: new Text(
                  emailController.text,
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new IconButton(
                      icon: new Icon(Icons.update),
                      iconSize: 25.0,
                      onPressed: () {}),
                  new IconButton(
                      icon: new Icon(Icons.person_add),
                      iconSize: 25.0,
                      onPressed: () {}),
                  new IconButton(
                      icon: new Icon(Icons.format_list_bulleted),
                      iconSize: 25.0,
                      onPressed: () {}),
                  new IconButton(
                      icon: new Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                      ),
                      onPressed: () {
                        FirebaseAuth.instance
                            .signOut()
                            .then((result) =>
                            Navigator.push(context, new MaterialPageRoute(
                                builder: (context) =>
                                new LoginScreen())
                            ))
                            .catchError((err) => print(err));
                      }),
                ],
              )
            ],
          ),
          new Container(
            margin: new EdgeInsets.only(top: 2.0),
            height: 1.5,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _post() {
    return new GestureDetector(
      child: new Column(
        children: <Widget>[
          new Text(
            "72",
            style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          new Padding(
            padding: new EdgeInsets.only(top: 3.0),
            child: new Text(
              "posts",
              style: new TextStyle(color: Colors.grey, fontSize: 16.0),
            ),
          )
        ],
      ),
    );
  }

  Widget _followers() {
    return new Container(
      margin: new EdgeInsets.only(left: 10.0),
      child: new GestureDetector(
        child: new Column(
          children: <Widget>[
            new Text(
              "352",
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 3.0),
              child: new Text(
                "followers",
                style: new TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _following() {
    return new Container(
      margin: new EdgeInsets.only(left: 10.0),
      child: new GestureDetector(
        child: new Column(
          children: <Widget>[
            new Text(
              "580",
              style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            new Padding(
              padding: new EdgeInsets.only(top: 3.0),
              child: new Text(
                "following",
                style: new TextStyle(color: Colors.grey, fontSize: 16.0),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _profilex() {
    return new Container(
      height: 150.0,
      margin: new EdgeInsets.only(top: 5.0),
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new Column(
                children: <Widget>[
                  new Image.asset(
                    "assets/cod.png",
                    height: 100.0,
                  ),
                  new Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 5.0),
                    alignment: Alignment.bottomLeft,
                    child: new Text(
                      firstNameController.text,
                      style: new TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              new Container(
                margin: EdgeInsets.only(bottom: 25.0),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: new Row(
                        children: <Widget>[_post(), _followers(), _following(),
                        ],
                      ),
                    ),
                    new GestureDetector(
                      child: new Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius:
                            BorderRadius.all(Radius.circular(5.0))),
                        margin: EdgeInsets.only(top: 7.0),
                        height: 30.0,
                        width: 200.0,
                        child: new Text(
                          "Edit Profile",
                          style: new TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (
                            context) {
                          return ProfilePage();
                        },));
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
          new Container(
            margin: new EdgeInsets.only(top: 10.0),
            height: 0.5,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _centerButtons() {
    return Container(
      child: new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              new IconButton(
                  icon: new Icon(
                    Icons.grid_on,
                    size: 30.0,
                  ),
                  onPressed: () {}),
              new IconButton(
                  icon: new Icon(
                    Icons.crop_original,
                    size: 30.0,
                  ),
                  onPressed: () {}),
              new IconButton(
                  icon: new Icon(
                    Icons.perm_contact_calendar,
                    size: 30.0,
                  ),
                  onPressed: () {}),
              new IconButton(
                  icon: new Icon(
                    Icons.bookmark_border,
                    size: 30.0,
                  ),
                  onPressed: () {}),

            ],
          ),
          new Container(
            height: 0.5,
            color: Colors.grey[300],
          )
        ],
      ),
    );
  }

  Widget _displayImages() {
    return Flexible(
        child: new Container(
          child: new GridView.builder(
              itemCount: 16,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                return new Container(
                  margin: EdgeInsets.all(2.0),
                  color: Colors.grey,
                  child: new Image.asset("assets/cod.png"),
//                    $picindex
                );
              }),
        ));
  }
}