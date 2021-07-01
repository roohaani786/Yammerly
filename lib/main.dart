import 'package:after_layout/after_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techstagram/Welcome/welcome_screen.dart';
import 'package:techstagram/intro/intro_page.dart';
import 'package:techstagram/resources/repository.dart';
import 'package:techstagram/ui/HomePage.dart';

bool seen;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
    playSound: true);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('A bg message just showed up :  ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SharedPreferences.setMockInitialValues({});
  // SharedPreferences prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);


  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Yammerly',
      debugShowCheckedModeBanner: false,

      // routes: {
      //   '/Login': (context) => LoginScreen(),
      //   '/Welcome': (context) => WelcomeScreen(),
      //   '/nayasignup': (context) => SignUpScreen(),
      //   '/Profile': (context) => AccountBottomIconScreen(),
      //   '/HomePage': (context) => HomePage(initialindexg: 1,cam: 0,),
      // },

      // theme: new ThemeData(
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      //   primarySwatch: Colors.blue,
      //   primaryColor: Colors.black,
      //   primaryIconTheme: IconThemeData(color: Colors.black),
      //   primaryTextTheme: TextTheme(
      //       headline6: TextStyle(
      //         color: Colors.black,
      //       )),
      //   textTheme: TextTheme(
      //       headline6: TextStyle(
      //         color: Colors.black,
      //       )),
      // ),

      home: Check(),
    );
  }
}

class Check extends StatefulWidget {
  @override
  CheckState createState() => new CheckState();
}

class CheckState extends State<Check> with AfterLayoutMixin<Check> {
//  final LocalAuthenticationService _localAuth = locator<LocalAuthenticationService>();

//  here we are checking if user cames in application first time
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //getting data using shared prefrence
    bool seen = (prefs.getBool('seen') ?? false);

    if (seen == false) {
      print("First Time");
      //Checking data using shared pref erences
      prefs.setBool('seen', true);
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new IntroPage()));
    } else {
      print("Second Time");
      Navigator.of(context).pushReplacement(
          new MaterialPageRoute(builder: (context) => new LoginCheck()));
    }
  }

  @override
  void afterFirstLayout(BuildContext context) => checkFirstSeen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }
}

class LoginCheck extends StatefulWidget {
  @override
  _LoginCheckState createState() => _LoginCheckState();
}

class _LoginCheckState extends State<LoginCheck> {
  var _repository = Repository();



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: _repository.getCurrentUser(),
      builder: (context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          print("Already Loggedin");
          return HomePage(initialindexg: 1);
        } else {
          print("Not loggedIn");
          return WelcomeScreen();
        }
      },
    );
  }
}
