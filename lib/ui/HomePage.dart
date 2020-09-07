import 'package:camera/camera.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:responsive_layout_builder/responsive_layout_builder.dart';
import 'package:techstagram/ComeraV/cam.dart';
import 'package:techstagram/resources/firebase_provider.dart';
//import 'package:techstagram/resources/opencamera.dart';
import 'package:techstagram/resources/repository.dart';
import 'package:techstagram/ui/ProfilePage.dart';
import 'package:techstagram/views/tabs/chats.dart';
import 'package:techstagram/views/tabs/feeds.dart';
import 'package:techstagram/views/tabs/notifications.dart';

//import '../resources/opencamera.dart';
import 'messagingsystem.dart';


class HomePage extends StatefulWidget {
  HomePage({
    Key key,
    this.title = "Hashtag",
    this.uid, @required this.initialindexg,
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



  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(HomePage()),
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
                  Icons.search,
                  color: Colors.deepPurple,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SearchListExample()),
                  );
                },
              ),

                actions: <Widget>[

                IconButton(
                  icon: Icon(
                    Icons.message,
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
            body: ResponsiveLayoutBuilder(
                  builder: (context, size) => new TabLayoutDemo(initialindexg)),

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
      onTap: () => Navigator.of(context).pop(HomePage()),
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
                        builder: (context) => Camera(),
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
                              builder: (context) => Camera(),
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

class SearchListExample extends StatefulWidget {
  @override
  _SearchListExampleState createState() => new _SearchListExampleState();
}

class _SearchListExampleState extends State<SearchListExample> {
  Widget appBarTitle = new Text(
    "Techstagram",
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
        centerTitle: true,
        title: appBarTitle,
        actions: <Widget>[
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
                        prefixIcon:
                        new Icon(Icons.search, color: Colors.deepPurple),
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
