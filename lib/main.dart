import 'package:catcher/catcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/Welcome/welcome_screen.dart';
import 'package:techstagram/pages/intro_page.dart';
import 'package:techstagram/resources/repository.dart';
import 'package:techstagram/resources/twittersignin.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/ui/ProfileEdit.dart';
import 'package:techstagram/ui/ProfilePage.dart';
import 'package:techstagram/ui/fblogin.dart';
import 'package:techstagram/views/tabs/profile.dart';

import 'Signup/signup_screen.dart';

int initScreen;
int initialindexg;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        navigatorKey: Catcher.navigatorKey,

        routes: {
          '/Login': (context) => LoginScreen(),
          '/Fblogin': (context) => Fblogin(),
          '/Welcome': (context) => WelcomeScreen(),
          '/nayasignup': (context) => SignUpScreen(),
          '/Twit': (context) => TwitterLoginScreen(),
          '/Profile': (context) => HomePage(initialindexg: 4,),
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


        home: FutureBuilder(
          future: _repository.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              return HomePage();
            } else {
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
