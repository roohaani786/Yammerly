//import 'package:camera/camera.dart';
import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_layout_builder/responsive_layout_builder.dart';
import 'package:techstagram/Welcome/welcome_screen.dart';
import 'package:techstagram/resources/firebase_provider.dart';
import 'package:techstagram/resources/opencamera.dart';
import 'package:techstagram/resources/repository.dart';
import 'package:techstagram/ui/ProfilePage.dart';
import 'package:techstagram/views/tabs/chats.dart';
import 'package:techstagram/views/tabs/feeds.dart';
import 'package:techstagram/views/tabs/notifications.dart';

import 'messagingsystem.dart';
//import 'package:techstagram/pages/home.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title = "Hashtag", this.uid,})
      : super(key: key); //update this to include the uid in the constructor
  final String title;
  final String uid; //include this

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController taskTitleInputController;
  TextEditingController taskDescripInputController;
  FirebaseUser currentUser;
  FirebaseProvider firebaseProvider;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  initState() {
    firebaseProvider = FirebaseProvider();
    taskTitleInputController = new TextEditingController();
    taskDescripInputController = new TextEditingController();
    this.getCurrentUser();
    super.initState();
  }

  void getCurrentUser() async {
    currentUser = await FirebaseAuth.instance.currentUser();
    firebaseProvider.user = await Repository().retrieveUserDetails(currentUser);
    setState(() {});
  }

  _signOut() async {
    await _firebaseAuth.signOut();
  }


  static const Map<LayoutSize, String> layoutSizeEnumToString = {
    LayoutSize.watch: 'Wristwatch',
    LayoutSize.mobile: 'Mobile',
    LayoutSize.tablet: 'Tablet',
    LayoutSize.desktop: 'Desktop',
    LayoutSize.tv: 'TV',
  };
  static const Map<MobileLayoutSize, String> mobileLayoutSizeEnumToString = {
    MobileLayoutSize.small: 'Small',
    MobileLayoutSize.medium: 'Medium',
    MobileLayoutSize.large: 'Large',
  };
  static const Map<TabletLayoutSize, String> tabletLayoutSizeEnumToString = {
    TabletLayoutSize.small: 'Small',
    TabletLayoutSize.large: 'Large',
  };
//  List<CameraDescription> cameras = [];
//
//  Future<void> main() async {
//    // Fetch the available cameras before initializing the app.
//    try {
//      WidgetsFlutterBinding.ensureInitialized();
//      cameras = await availableCameras();
//      final firstCamera = cameras.first;
//      runApp(
//        MaterialApp(
//          theme: ThemeData.dark(),
//          home: CameraExampleHome(
//            // Pass the appropriate camera to the TakePictureScreen widget.
//            camera: firstCamera,
//          ),
//        ),
//      );
//    } on CameraException catch (e) {
//      logError(e.code, e.description);
//    }
//  }

//  void _onHorizontalDrag(DragEndDetails details) {
//    if (details.primaryVelocity == 0)
//      return; // user have just tapped on screen (no dragging)
//
//    if (details.primaryVelocity.compareTo(0) == -1)
//      _opencamera();
//    else
//      _opencamera();
//  }

//  List<CameraDescription> cameras = [];

  Future<void> _opencamera() async {
    // Fetch the available cameras before initializing the app.
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(

        child: Scaffold(
          appBar: AppBar(
            title: Text("Hashtag", style: TextStyle(color: Colors.deepPurple)),
            backgroundColor: Colors.white,
            //  backgroundColor: Colors.white,
            leading: Padding(
              padding: EdgeInsets.only(left: 12,),
              child: IconButton(
                  icon: Icon(Icons.camera_alt, color: Colors.deepPurple,),
                  onPressed: () {
                    _opencamera();

//                  Navigator.push(
//                    context,
//                    MaterialPageRoute(builder: (context) =>CameraExampleHome()),
//                  );
                  }

              ),

            ),
            // title: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       Text('Hashtag',
            //         style: TextStyle(color: Colors.white,),),
            //     ]
            // ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search, color: Colors.deepPurple,),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchListExample()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.message, color: Colors.deepPurple,),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConversationPage()),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.exit_to_app, color: Colors.deepPurple,),
                onPressed: () {
                  _signOut();

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()),
                  );
                },
              ),
            ],

          ),
//      appBar: AppBar(
//        title: Text(widget.title),
//        actions: <Widget>[
//          FlatButton(
//            child: Text("Log Ot"),
//            textColor: Colors.white,
//            onPressed: () {
//              FirebaseAuth.instance
//                  .signOut()
//                  .then((result) =>
//                  Navigator.push(context, new MaterialPageRoute(
//                      builder: (context) =>
//                      new LoginScreen())
//                  ))
//                  .catchError((err) => print(err));
//            },
//          )
//        ],
//      ),
//
////      body: Center(
////        child: Container(
////            padding: const EdgeInsets.all(20.0),
////            child: Text("Welcome")),
////
////      ),
          body: ResponsiveLayoutBuilder(
              builder: (context, size) =>
              new TabLayoutDemo()),

        ),
      ),
    );
  }


//  Future<void> _opencamera() async {
//    // Ensure that plugin services are initialized so that `availableCameras()`
//    // can be called before `runApp()`
//    WidgetsFlutterBinding.ensureInitialized();
//
//    // Obtain a list of the available cameras on the device.
//    final cameras = await availableCameras();
//
//    // Get a specific camera from the list of available cameras.
//    final firstCamera = cameras.first;
//
//    runApp(
//      MaterialApp(
//        debugShowCheckedModeBanner: false,
//        theme: ThemeData.dark(),
//        home: TakePictureScreen(
//          // Pass the appropriate camera to the TakePictureScreen widget.
//          camera: firstCamera,
//        ),
//      ),
//    );
//  }
}


class TabLayoutDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: new Scaffold(
          body: TabBarView(
            children: [
              new Container(
                child: FeedsPage(),
              ),
              new Container(
                child: ChatsPage(),
              ),
              new Container(
                child: NotificationsPage(),
              ),
              new Container(
                  child: AccountBottomIconScreen()
              ),
            ],
          ),
          bottomNavigationBar: new Container(
            height: 60.0,
            child: new TabBar(
              tabs: [
                Tab(
                  icon: new Icon(Icons.home, size: 30),
                ),
                Tab(
                  icon: new Icon(Icons.blur_circular, size: 30),
                ),
                Tab(
                  icon: new Icon(Icons.notifications, size: 30),
                ),
                Tab(icon: new Icon(Icons.account_circle, size: 30),)
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


class SearchListExample extends StatefulWidget {
  @override
  _SearchListExampleState createState() => new _SearchListExampleState();
}

class _SearchListExampleState extends State<SearchListExample> {
  Widget appBarTitle = new Text(
    "Hashtag",
    style: new TextStyle(color: Colors.deepPurple),
  );
  Icon icon = new Icon(
    Icons.search,
    color: Colors.deepPurple,
  );
  final globalKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _controller = new TextEditingController();
  List<dynamic> _list;
  bool _isSearching;
  String _searchText = "";
  List searchresult = new List();

  _SearchListExampleState() {
    _controller.addListener(() {
      if (_controller.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _isSearching = true;
          _searchText = _controller.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _isSearching = false;
    values();
  }

  void values() {
    _list = List();
    _list.add("Shadaab88");
    _list.add("Shahid0712");
    _list.add("Aman446");
    _list.add("Nabeel44");
    _list.add("Nikhil123");
    _list.add("Shahana88");
    _list.add("Sara77");
    _list.add("Khizar712");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        key: globalKey,
        appBar: buildAppBar(context),
        body: new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Flexible(
                  child: searchresult.length != 0 || _controller.text.isNotEmpty
                      ? new ListView.builder(
                    shrinkWrap: true,
                    itemCount: searchresult.length,
                    itemBuilder: (BuildContext context, int index) {
                      String listData = searchresult[index];
                      return new ListTile(
                        title: new Text(listData.toString()),
                      );
                    },
                  )
                      : new ListView.builder(
                    shrinkWrap: true,
                    itemCount: _list.length,
                    itemBuilder: (BuildContext context, int index) {
                      String listData = _list[index];
                      return new ListTile(
                        title: new Text(listData.toString()),
                      );
                    },
                  ))
            ],
          ),
        ));
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        backgroundColor: Colors.white,
        centerTitle: true, title: appBarTitle, actions: <Widget>[
      new IconButton(
        icon: icon,
        onPressed: () {
          setState(() {
            if (this.icon.icon == Icons.search) {
              this.icon = new Icon(
                Icons.close,
                color: Colors.black,
              );
              this.appBarTitle = new TextField(
                controller: _controller,
                style: new TextStyle(
                  color: Colors.deepPurple,
                ),
                decoration: new InputDecoration(
                    prefixIcon: new Icon(
                        Icons.search, color: Colors.deepPurple),
                    hintText: "Search...",
                    hintStyle: new TextStyle(color: Colors.white)),
                onChanged: searchOperation,
              );
              _handleSearchStart();
            } else {
              _handleSearchEnd();
            }
          });
        },
      ),
    ]);
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.icon = new Icon(
        Icons.search,
        color: Colors.deepPurple,
      );
      this.appBarTitle = new Text(
        "Hashtag",
        style: new TextStyle(color: Colors.deepPurple),
      );
      _isSearching = false;
      _controller.clear();
    });
  }

  void searchOperation(String searchText) {
    searchresult.clear();
    if (_isSearching != null) {
      for (int i = 0; i < _list.length; i++) {
        String data = _list[i];
        if (data.toLowerCase().contains(searchText.toLowerCase())) {
          searchresult.add(data);
        }
      }
    }
  }
}