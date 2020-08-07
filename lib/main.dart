import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/Welcome/welcome_screen.dart';
import 'package:techstagram/pages/intro_page.dart';
import 'package:techstagram/resources/repository.dart';
import 'package:techstagram/resources/twittersignin.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/ui/fblogin.dart';

import 'Signup/signup_screen.dart';
import 'ui/Login.dart';

void main() => runApp(MyApp());

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
        routes: {
          '/Login': (context) => LoginPage(),
          '/Fblogin': (context) => Fblogin(),
          '/Welcome': (context) => WelcomeScreen(),
          '/nayasignup': (context) => SignUpScreen(),
          '/Twit': (context) => TwitterLoginScreen(),
        },
        theme: new ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.black,
            primaryIconTheme: IconThemeData(color: Colors.black),
            primaryTextTheme: TextTheme(
                headline6: TextStyle(
                    color: Colors.black, fontFamily: "Cookie-Regular")),
            textTheme: TextTheme(headline6: TextStyle(
                color: Colors.black, fontFamily: "Cookie-Regular")),
            fontFamily: "Cookie-Regular"),


        home: FutureBuilder(
          future: _repository.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              return HomePage();
            } else {
              return IntroPage();
            }
          },
        ));
  }
}
