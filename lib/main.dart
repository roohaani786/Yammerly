import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/Welcome/welcome_screen.dart';
import 'package:techstagram/pages/intro_page.dart';
import 'package:techstagram/resources/repository.dart';
import 'package:techstagram/ui/fblogin.dart';

import 'Signup/signup_screen.dart';
import 'ui/Login.dart';

void main() => runApp(MyApp());

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
//        '/HomePage': (context) => CurrentPage(),
//          '/Signup': (context) => RegisterPage(),
          '/Login': (context) => LoginPage(),
          '/Fblogin': (context) => Fblogin(),
          '/Welcome': (context) => WelcomeScreen(),
          '/nayasignup': (context) => SignUpScreen(),
//          '/Twit': (context) => Twit(),
        },
        theme: new ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: Colors.black,
            primaryIconTheme: IconThemeData(color: Colors.black),
            primaryTextTheme: TextTheme(
                headline6: TextStyle(color: Colors.black, fontFamily: "Aveny")),
            textTheme: TextTheme(headline6: TextStyle(color: Colors.black))),
        home: FutureBuilder(
          future: _repository.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              return IntroPage();
            } else {
              return IntroPage();
            }
          },
        ));
  }
}
