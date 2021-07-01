import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:techstagram/ComeraV/Camera.dart';
import 'package:techstagram/main.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/resources/firebase_provider.dart';
import 'package:techstagram/resources/repository.dart';
import 'package:techstagram/status/screens/status_screen.dart';
import 'package:techstagram/ui/ProfilePage.dart';
import 'package:techstagram/views/tabs/feeds.dart';
import 'package:techstagram/views/tabs/notifications.dart';
import 'package:video_player/video_player.dart';
//import 'dart:async';
import 'messagingsystem.dart';
import 'searchlist.dart';

class HomePage extends StatefulWidget {
  HomePage(
      {Key key,
      this.title = "Yammerly",
      this.uid,
      this.initialindexg,
      this.cam})
      : super(key: key); //update this to include the uid in the constructor

  final String title;
  final String uid;
  final int cam;
  int initialindexg;
  User user;
  static String dnu;

  @override
  _HomePageState createState() => _HomePageState(initialindexg, cam);
}

final PageController _pageController =
    PageController(initialPage: 1, keepPage: true);

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;
  User currentUser;
  FirebaseProvider firebaseProvider;
  // Create the page controller in your widget

  _HomePageState(this.initialindexg, this.cam);

  int initialindexg;
  int cam;
  TextEditingController emailController,
      urlController,
      descriptionController,
      displayNameController,
      uidController,
      photoUrlController,
      phonenumberController,
      bioController;
  int followers;
  int following;
  int posts;
  DateTime birthday;
  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
  User currUser;

  fetchProfileData() async {
    currUser = FirebaseAuth.instance.currentUser;
    try {
      docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUser.uid)
          .get();
      birthday = docSnap["Birthday"];
      displayNameController.text = docSnap["displayName"];
      uidController.text = docSnap["uid"];
      emailController.text = docSnap["email"];
      photoUrlController.text = docSnap["photoURL"];
      phonenumberController.text = docSnap["phonenumber"];
      followers = docSnap["followers"];
      following = docSnap["following"];
      posts = docSnap["posts"];
      setState(() {
        displayNamecurrUser = displayNameController.text;
        HomePage.dnu = displayNamecurrUser;
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
    WidgetsBinding.instance.addObserver(this);
    authService.loading.listen((state) => setState(() => _loading = state));

    fetchProfileData();
    this.getCurrentUser();

    if(birthday == DateTime.now()){

      flutterLocalNotificationsPlugin.show(
          0,
          "Testing ",
          "How you doin ?",
          NotificationDetails(
              android: AndroidNotificationDetails(channel.id, channel.name, channel.description,
                  importance: Importance.high,
                  color: Colors.deepPurple,
                  playSound: true,
                  icon: '@mipmap/ic_launcher')));

    }

    myPageView = PageView(
      controller: _pageController,
      allowImplicitScrolling: true,
      children: <Widget>[
        CameraExampleHome(cam: 0, check: true),
        //CameraExampleHome(),
        //CameraScreen(cam: 0, check: true),
        TabLayoutDemo(initialindexg),
        // Container(color: Colors.yellow),
      ],
    );
    setStatus('true');
    super.initState();
  }

  setStatus(String val) async {
    DateTime time;
    if (val == 'false') time = DateTime.now();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currUser.uid)
        .update({'online': val, 'last seen': time.toString()});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setStatus('true');
    else
      setStatus('false');
  }

  void getCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    firebaseProvider.user = await Repository().retrieveUserDetails(currentUser);
    setState(() {});
    print(currentUser.displayName);
    print(currentUser.email);
    print(currentUser.uid);
  }

  List<CameraDescription> cameras = [];
  DateTime currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "tap again for back");
      return Future.value(false);
    }
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
    // print("hore ho kya bhai");
    // SystemNavigator.pop();
    // SystemNavigator.pop();
  }

  //final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
//    final user = Provider.of<User>(context);
//    _saveDeviceToken(user.uid);
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: myPageView,
      ),
    );
  }
}

List<CameraDescription> cameras = [];

class TabLayoutDemo extends StatefulWidget {
  TabLayoutDemo(
    this.initialindexg,
  );

  final int initialindexg;
  @override
  _TabLayoutDemoState createState() => _TabLayoutDemoState(initialindexg);
}

bool hideappbar = false;
bool hidebottombar = false;

class _TabLayoutDemoState extends State<TabLayoutDemo>
    with SingleTickerProviderStateMixin {
  _TabLayoutDemoState(this.initialindexg);
  TabController tabController;
  Map<String, dynamic> _profile;
  bool _loading = false;
  User currentUser;
  FirebaseProvider firebaseProvider;
  VideoPlayerController vpController;

  final int initialindexg;
  TextEditingController emailController,
      urlController,
      descriptionController,
      displayNameController,
      uidController,
      photoUrlController,
      phonenumberController,
      bioController;

  DocumentSnapshot docSnap;
  User currUser;

  void getCurrentUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    firebaseProvider.user = await Repository().retrieveUserDetails(currentUser);
    setState(() {});
    print(currentUser.displayName);
    print(currentUser.email);
    print(currentUser.uid);
  }

  fetchProfileData() async {
    currUser = FirebaseAuth.instance.currentUser;
    try {
      docSnap = await FirebaseFirestore.instance
          .collection("users")
          .doc(currUser.uid)
          .get();
      displayNameController.text = docSnap["displayName"];
      uidController.text = docSnap["uid"];
      emailController.text = docSnap["email"];
      photoUrlController.text = docSnap["photoURL"];
      phonenumberController.text = docSnap["phonenumber"];
      int followers = docSnap["followers"];
      int following = docSnap["following"];
      int posts = docSnap["posts"];
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

    // DateTime now = DateTime.now();
    // if (currentBackPressTime == null ||
    //     now.difference(currentBackPressTime) > Duration(seconds: 2)) {
    //   currentBackPressTime = now;
    //   Fluttertoast.showToast(msg: "exit_warning");
    //   return Future.value(false);
    // }
    // return Future.value(true);
    if (tabController.index == 1) {
      print("bahi aa rahe ho kya");
      SystemNavigator.pop();
      SystemNavigator.pop();
    }

    Future.delayed(Duration(milliseconds: 200), () {
      print("set index");
      tabController.index = 1;
    });

    print("return");
    return tabController.index == 1;
  }

  Future<bool> onWillPop2() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    });
  }

  @override
  Widget build(BuildContext context) {
    // Local dragStartDetail.
    DragStartDetails dragStartDetails;
    // Current drag instance - should be instantiated on overscroll and updated alongside
    Drag drag;
    // TODO: implement build

    return Scaffold(
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
                    builder: (context) =>
                        CameraExampleHome(cam: 0, check: true),
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
                    builder: (context) => CloudFirebaseFirestoreSearch(
                          displayNamecurrentUser: displayNameController.text,
                          uidX: uidController.text,
                        )),
              );
              flutterLocalNotificationsPlugin.show(
                  0,
                  "Testing ",
                  "How you doin ?",
                  NotificationDetails(
                      android: AndroidNotificationDetails(channel.id, channel.name, channel.description,
                          importance: Importance.high,
                          color: Colors.deepPurple,
                          playSound: true,
                          icon: '@mipmap/ic_launcher')));
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
                MaterialPageRoute(
                    builder: (context) =>
                        ConversationPage(displayNameController.text)),
              );
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        //initialIndex: (initialindexg == null) ? 1 : initialindexg,
        child: Scaffold(
          body: DoubleBackToCloseApp(
            snackBar: const SnackBar(
              content: Text('Tap back again to leave'),
            ),
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                new Container(
                  child: DetailStatusScreen(),
                ),
                new Container(
                  child: FeedsPage(
                    displayNamecurrentUser: displayNameController.text,
                  ),
                ),
                new Container(
                  //child: FeedsPage(),
                  child: NotificationsPage(
                      currUid: uidController.text,
                      displayNameCurrUser: displayNameController.text),
                ),
                new Container(child: AccountBottomIconScreen()),
              ],
            ),
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
    );
  }
}
