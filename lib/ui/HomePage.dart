import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/ComeraV/Camera.dart';
import 'package:techstagram/ComeraV/camera_screen.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/resources/firebase_provider.dart';
import 'package:techstagram/resources/repository.dart';
import 'package:techstagram/ui/ProfilePage.dart';
import 'package:techstagram/views/tabs/chats.dart';
import 'package:techstagram/views/tabs/feeds.dart';
import 'package:techstagram/views/tabs/notifications.dart';

import 'messagingsystem.dart';
import 'searchlist.dart';


class HomePage extends StatefulWidget {

  HomePage({ Key key, this.title = "Yammerly",
    this.uid,this.initialindexg,
  }) : super(key: key); //update this to include the uid in the constructor

  final String title;
  final String uid;
  int initialindexg;
  FirebaseUser user;

  @override
  _HomePageState createState() => _HomePageState(initialindexg);
}

final PageController _pageController = PageController(initialPage: 1,keepPage: true);

class _HomePageState extends State<HomePage> {

  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;
  FirebaseUser currentUser;
  FirebaseProvider firebaseProvider;
  // Create the page controller in your widget

  _HomePageState(this.initialindexg);

  int initialindexg;
  TextEditingController emailController,urlController,descriptionController,
      displayNameController,uidController,photoUrlController,phonenumberController,
      bioController;
  int followers;
  int following;
  int posts;

  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
  FirebaseUser currUser;

  fetchProfileData() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {
      docSnap = await Firestore.instance
          .collection("users")
          .document(currUser.uid)
          .get();
      displayNameController.text = docSnap.data["displayName"];
      uidController.text = docSnap.data["uid"];
      emailController.text = docSnap.data["email"];
      photoUrlController.text = docSnap.data["photoURL"];
      phonenumberController.text = docSnap.data["phonenumber"];
      followers = docSnap.data["followers"];
      following  = docSnap.data["following"];
      posts  = docSnap.data["posts"];
      setState(() {
        displayNamecurrUser = displayNameController.text;

      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
    print(uidController.text);
    print("bajbaj");
  }
  PageView myPageView;

  String displayNamecurrUser;


  @override
  initState() {
    firebaseProvider = FirebaseProvider();
    taskTitleInputController = new TextEditingController();
    taskDescripInputController = new TextEditingController();
    emailController = TextEditingController();
    displayNameController = TextEditingController();
    uidController = TextEditingController();
    photoUrlController = TextEditingController();
    phonenumberController = TextEditingController();

    super.initState();
    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));

    fetchProfileData();
    this.getCurrentUser();


    myPageView = PageView(
      controller: _pageController,
      allowImplicitScrolling: true,
      children: <Widget>[
        CameraApp(cam: 0,check: true),
        //CameraExampleHome(),
        //CameraScreen(cam: 0, check: true),
        TabLayoutDemo(initialindexg),
        // Container(color: Colors.yellow),
      ],
    );
    super.initState();
  }

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    firebaseProvider.user = await Repository().retrieveUserDetails(currentUser);
    setState(() {});
    print(currentUser.displayName);
    print(currentUser.email);
    print(currentUser.uid);
  }

  List<CameraDescription> cameras = [];
  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Text("NO"),
          ),
          SizedBox(height: 16),
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: Text("YES"),
          ),
        ],
      ),
    ) ??
        false;
  }

  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
//    final user = Provider.of<User>(context);
//    _saveDeviceToken(user.uid);
    return GestureDetector(
      onTap: (){print("hu");},
//      onTap: () => Navigator.of(context).pop(HomePage()),
      child: Scaffold(
        body: myPageView,
      ),
    );
  }
}

List<CameraDescription> cameras = [];

class TabLayoutDemo extends StatefulWidget {
  TabLayoutDemo(this.initialindexg,);

  final int initialindexg;
  @override
  _TabLayoutDemoState createState() => _TabLayoutDemoState(initialindexg);
}

bool hideappbar = false;
bool hidebottombar = false;

class _TabLayoutDemoState extends State<TabLayoutDemo> with SingleTickerProviderStateMixin{
  _TabLayoutDemoState(this.initialindexg);
  TabController tabController;
  Map<String, dynamic> _profile;
  bool _loading = false;
  FirebaseUser currentUser;
  FirebaseProvider firebaseProvider;


  final int initialindexg;
  TextEditingController emailController,urlController,descriptionController,
      displayNameController,uidController,photoUrlController,phonenumberController,
      bioController;

  DocumentSnapshot docSnap;
  FirebaseUser currUser;

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    firebaseProvider.user = await Repository().retrieveUserDetails(currentUser);
    setState(() {});
    print(currentUser.displayName);
    print(currentUser.email);
    print(currentUser.uid);
  }


  fetchProfileData() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {
      docSnap = await Firestore.instance
          .collection("users")
          .document(currUser.uid)
          .get();
      displayNameController.text = docSnap.data["displayName"];
      uidController.text = docSnap.data["uid"];
      emailController.text = docSnap.data["email"];
      photoUrlController.text = docSnap.data["photoURL"];
      phonenumberController.text = docSnap.data["phonenumber"];
      int followers = docSnap.data["followers"];
      int following  = docSnap.data["following"];
      int posts  = docSnap.data["posts"];
      setState(() {
        String displayNamecurrUser = displayNameController.text;

      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
    print(uidController.text);
    print("bajbaj");
  }


  @override
  void initState() {
    firebaseProvider = FirebaseProvider();
    emailController = TextEditingController();
    displayNameController = TextEditingController();
    uidController = TextEditingController();
    photoUrlController = TextEditingController();
    phonenumberController = TextEditingController();

    super.initState();
    this.tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: (initialindexg == null) ? 1 : initialindexg,
    );
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));

    fetchProfileData();
    this.getCurrentUser();
  }

  DateTime currentBackPressTime;

  // Future<bool> onWillPop() {
  //   SystemNavigator.pop();
  //   print("hello");
  // }

  Future<bool> onWillPop() async {
    print("on will pop");
    if (tabController.index == 1) {
      await SystemNavigator.pop();
    }

    Future.delayed(Duration(milliseconds: 200), () {
      print("set index");
      tabController.index = 1;
    });

    print("return");
    return tabController.index == 1;
  }

  @override
  Widget build(BuildContext context) {
    // Local dragStartDetail.
    DragStartDetails dragStartDetails;
    // Current drag instance - should be instantiated on overscroll and updated alongside
    Drag drag;
    // TODO: implement build

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Yammerly',
            style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 20.0,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          leading: Row(
            children: [
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.camera,
                  color: Colors.deepPurple,
                  //size: 10.0,
                ),
                onPressed: () {
                  print("camera open");
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CameraScreen(cam: 0, check: true,),
                    ),
                  );
                },
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                FontAwesomeIcons.searchengin,
                color: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CloudFirestoreSearch(
                            displayNamecurrentUser: displayNameController.text,
                            uidX: uidController.text,
                          )),
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.textsms,
                color: Colors.deepPurple,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConversationPage()),
                );
              },
            ),
          ],
        ),
        body: DefaultTabController(
          length: 4,
          //initialIndex: (initialindexg == null) ? 1 : initialindexg,
          child: Scaffold(
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                new Container(
                  child: ChatsPage(),
                ),
                new Container(
                  child: FeedsPage(
                    displayNamecurrentUser: displayNameController.text,
                  ),
                ),
                new Container(
                  //child: FeedsPage(),
                  child: NotificationsPage(currUid: uidController.text),
                ),
                new Container(child: AccountBottomIconScreen()),
              ],
            ),
            bottomNavigationBar: new Container(
              height: 60.0,
              child: new TabBar(
                controller: tabController,
                tabs: [
                  Tab(
                    icon: new Icon(Icons.blur_circular, size: 30),
                  ),
                  Tab(
                    icon: new Icon(Icons.home, size: 30),
                  ),
                  Tab(
                    icon: new Icon(Icons.notifications, size: 30),
                    //text: new Text(curARRrUid),
                  ),
                  Tab(
                    icon: new Icon(Icons.account_circle, size: 30),
                  )
                ],
                labelColor: Colors.purple,
                unselectedLabelColor: Colors.deepPurple,
                indicatorSize: TabBarIndicatorSize.label,
                indicatorPadding: EdgeInsets.all(5.0),
                indicatorWeight: 3.0,
                indicatorColor: Colors.deepPurple,
              ),
            ),
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}