import 'package:camera/camera.dart';
import 'package:camera/new/src/support_android/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:firebase/firebase.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:responsive_layout_builder/responsive_layout_builder.dart';
import 'package:techstagram/ComeraV/cam.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/models/wiggle.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/resources/firebase_provider.dart';
//import 'package:techstagram/resources/opencamera.dart';
import 'package:techstagram/resources/repository.dart';
import 'package:techstagram/services/database.dart';
import 'package:techstagram/ui/ProfilePage.dart';
import 'package:techstagram/ui/other_profile.dart';
import 'package:techstagram/views/tabs/chats.dart';
import 'package:techstagram/views/tabs/feeds.dart';
import 'package:techstagram/views/tabs/notifications.dart';

//import '../resources/opencamera.dart';
import 'messagingsystem.dart';
import 'searchlist.dart';


class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.title = "Hashtag",
    this.uid,this.initialindexg,
  }) : super(key: key); //update this to include the uid in the constructor
  final String title;
  final String uid;
  int initialindexg = 2;
  FirebaseUser user;



  //include this

  GoogleSignIn _googleSignIn;
  FirebaseUser _user;


  Body(FirebaseUser user, GoogleSignIn signIn) {
    _user = user;
    _googleSignIn = signIn;
  }

  @override
  _HomePageState createState() => _HomePageState(initialindexg);
}

class _HomePageState extends State<HomePage> {
  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;
  FirebaseUser currentUser;
  FirebaseProvider firebaseProvider;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  _HomePageState(this.initialindexg);

  int initialindexg;
  TextEditingController emailController,urlController,descriptionController,
      displayNameController,uidController,photoUrlController,phonenumberController,
      bioController,followers,following,posts;

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
      bioController.text = docSnap.data["bio"];
      followers = docSnap.data["followers"];
      following  = docSnap.data["following"];
      posts  = docSnap.data["posts"];
      setState(() {
//        isLoading = false;
//        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }


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
//    fetchPosts();
    fetchProfileData();
    this.getCurrentUser();
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


  _signOut() async {
    await _firebaseAuth.signOut();
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

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();


  _saveDeviceToken(String uid) async {
    String fcmToken = await _fcm.getToken();
    DatabaseService(uid: uid).uploadtoken(fcmToken);
  }


  @override
  Widget build(BuildContext context) {
//    final user = Provider.of<User>(context);
//    _saveDeviceToken(user.uid);
    return GestureDetector(
      onTap: (){print("hu");},
//      onTap: () => Navigator.of(context).pop(HomePage()),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                          'Hashtag',
                          style: TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),

              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(
                  FontAwesomeIcons.searchengin,
                  color: Colors.deepPurple,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CloudFirestoreSearch(displayNamecurrentUser:displayNameController.text,uidX: uidController.text,)),
                  );
                },
              ),

                actions: <Widget>[

                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.teamspeak,
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
//
            body: TabLayoutDemo(initialindexg),

          ),
        );
  }


}

List<CameraDescription> cameras = [];

class TabLayoutDemo extends StatefulWidget {
  TabLayoutDemo(this.initialindexg);

  int initialindexg;
  @override
  _TabLayoutDemoState createState() => _TabLayoutDemoState(initialindexg);
}

bool hideappbar = false;
bool hidebottombar = false;

class _TabLayoutDemoState extends State<TabLayoutDemo> {
  _TabLayoutDemoState(this.initialindexg);

  int initialindexg;



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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return GestureDetector(
      onTap: () => print("hello"),
      child: Scaffold(
        body: DefaultTabController(
          length: 5,
          initialIndex: (initialindexg == null) ? 2 : initialindexg,

          child: new Scaffold(
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              children: [

                GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) => CameraS(),
                      ),
                    );
                    setState(() {
                      hidebottombar = true;
                      hideappbar = true;
                    });
                  },
                  //child: CameraExampleHome(cameras),
                ),


                new Container(
                  child: ChatsPage(),
                ),
                new Container(
                  child: FeedsPage(),
                ),
                new Container(
                  child: NotificationsPage(),
                ),
                new Container(child: AccountBottomIconScreen()),
              ],
            ),
            bottomNavigationBar: (hidebottombar == true) ? PreferredSize(
              child: Container(),
              preferredSize: Size(0.0, 0.0),
            ) : new Container(
              height: 60.0,
              child: new TabBar(
                tabs: [
                  Tab(
                    icon: IconButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (context) => CameraS(),
                            ),
                          );
                        },

                        icon: new Icon(FontAwesomeIcons.camera, size: 30)),
                  ),
                  Tab(
                    icon: new Icon(Icons.blur_circular, size: 30),
                  ),
                  Tab(
                    icon: new Icon(Icons.home, size: 30),
                  ),
                  Tab(
                    icon: new Icon(Icons.notifications, size: 30),
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

//  Future<void> _opencamera() async {
//    // Fetch the available cameras before initializing the app.
//    try {
//      WidgetsFlutterBinding.ensureInitialized();
//      cameras = await availableCameras();
//    } on CameraException catch (e) {
//      logError(e.code, e.description);
//    }
//    return CameraExampleHome(cameras);
//  }
}

