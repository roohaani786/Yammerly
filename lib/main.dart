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

//        builder: (context, widget) => ResponsiveWrapper.builder(
//            .builder(context, widget),
//            maxWidth: 1200,
//            minWidth: 450,
//            defaultScale: true,
//            breakpoints: [
//              ResponsiveBreakpoint.resize(450, name: MOBILE),
//              ResponsiveBreakpoint.autoScale(800, name: TABLET),
//              ResponsiveBreakpoint.autoScale(1000, name: TABLET),
//              ResponsiveBreakpoint.resize(1200, name: DESKTOP),
//              ResponsiveBreakpoint.autoScale(2460, name: "4K"),
//            ],
//            background: Container(color: Color(0xFFF5F5F5))),
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
              return IntroPage();
            }
          },
        )

//        var ref = new Firebase("https://<YOUR-FIREBASE-APP>.firebaseio.com");
//    ref.onAuth(function(authData) {
//    if (authData) {
//    console.log("User " + authData.uid + " is logged in with " + authData.provider);
//    } else {
//    console.log("User is logged out");
//    }
//    });


    );
  }
}
