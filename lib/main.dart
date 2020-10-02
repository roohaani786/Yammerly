//import 'package:catcher/catcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/Welcome/welcome_screen.dart';
import 'package:techstagram/pages/intro_page.dart';
import 'package:techstagram/resources/repository.dart';
import 'package:techstagram/resources/twittersignin.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/ui/ProfilePage.dart';
import 'package:techstagram/ui/fblogin.dart';
import 'Signup/signup_screen.dart';
import 'biometric_auth.dart';
import 'biometric_auth.dart' as authenticated;

int initScreen;
int initialindexg;

Future<void> main() async {
//  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  SharedPreferences prefs = await SharedPreferences.getInstance();
  initScreen = await prefs.getInt("initScreen");
  await prefs.setInt("initScreen", 1);
  print('initScreen ${initScreen}');
  runApp(MyApp());
}

//Main entry-point class

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> {
  var _repository = Repository();

  @override
  Widget build(BuildContext context) {

      return MaterialApp(

          title: 'Hashtag',
          debugShowCheckedModeBanner: false,

          //navigatorKey: Catcher.navigatorKey,


          routes: {
            '/Login': (context) => LoginScreen(),
            '/Fblogin': (context) => Fblogin(),
            '/Welcome': (context) => WelcomeScreen(),
            '/nayasignup': (context) => SignUpScreen(),
            '/Twit': (context) => TwitterLoginScreen(),
            '/Profile': (context) => AccountBottomIconScreen(),
            '/HomePage': (context) => HomePage(),
          },


          theme: new ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.black,
            primaryIconTheme: IconThemeData(color: Colors.black),
            primaryTextTheme: TextTheme(
                headline6: TextStyle(
                  color: Colors.black,)),
            textTheme: TextTheme(headline6: TextStyle(
              color: Colors.black,)),
          ),


          home:
          FutureBuilder(
            future: _repository.getCurrentUser(),
            builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
              if (snapshot.hasData) {
//                return Biometricauth();
                return HomePage();
              } else {
//                return Biometricauth();
                return Check();
              }
            },
          )
      );
  }
}

class Check extends StatefulWidget {
  @override
  CheckState createState() => new CheckState();
}

class CheckState extends State<Check> {

//  final LocalAuthenticationService _localAuth = locator<LocalAuthenticationService>();


  @override
  Widget build(BuildContext context) {
    if (initScreen == 0 || initScreen == null) {
      return IntroPage();
    }
    else {
      return WelcomeScreen();
    }
  }


}
