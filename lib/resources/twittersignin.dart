//import 'dart:async';
//import 'package:flutter_twitter_login/flutter_twitter_login.dart';
//import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'DetailedScreen.dart'; //important fix
//
//
//class Twit extends StatefulWidget {
//  @override
//  _TwitState createState() => new _TwitState();
//}
//
//class _TwitState extends State<Twit> {
//  FirebaseAuth auth = FirebaseAuth.instance;
//
//  TwitterLogin twitterInstance = new TwitterLogin(
//      consumerKey: "5A5BOBPJhlu1PcymNvWYo7PST",
//      consumerSecret: "iKMjVT371WTyZ2nzmbW1YM59uAfIPobWOf1HSxvUHTflaeqdhu");
//
//  Future<FirebaseUser> _signIn(BuildContext context) async {
//    // Scaffold.of(context).showSnackBar(new SnackBar(
//    //       content: new Text('Sign in button clicked'),
//    //     ));
//
//    final TwitterLoginResult result = await twitterInstance.authorize();
//
//    FirebaseUser user = await auth.signInWithTwitter(
//        authToken: result.session.token,
//        authTokenSecret: result.session.secret);
//
//    UserInfoDetails userInfoDetails = new UserInfoDetails(
//        user.providerId,
//        user.uid,
//        user.displayName,
//        user.photoUrl,
//        user.email,
//        user.isAnonymous,
//        user.isEmailVerified,
//        user.phoneNumber);
//
//    Navigator.push(
//      context,
//      new MaterialPageRoute(
//        builder: (context) => new DetailedScreen(detailsUser: userInfoDetails),
//      ),
//    );
//
//    return user;
//  }
//
//  Future<Null> _signOut(BuildContext context) async {
//    await twitterInstance.logOut();
//    Scaffold.of(context).showSnackBar(new SnackBar(
//      content: new Text('Sign out button clicked'),
//    ));
//    print('Signed out');
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return new MaterialApp(
//      home: new Scaffold(
//        appBar: new AppBar(
//          title: const Text('Twitter and Firebase'),
//        ),
//        body: new Builder(
//          builder: (BuildContext context) {
//            return new Center(
//              child: new Column(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  new MaterialButton(
//                    //padding: new EdgeInsets.all(16.0),
//                    minWidth: 150.0,
//                    onPressed: () => _signIn(context)
//                        .then((FirebaseUser user) => print(user))
//                        .catchError((e) => print(e)),
//                    child: new Text('Sign in with Twitter'),
//                    color: Colors.lightBlueAccent,
//                  ),
//                  new Padding(
//                    padding: const EdgeInsets.all(5.0),
//                  ),
//                  new MaterialButton(
//                    minWidth: 150.0,
//                    onPressed: () => _signOut(context),
//                    child: new Text('Sign Out'),
//                    color: Colors.lightBlueAccent,
//                  ),
//                ],
//              ),
//            );
//          },
//        ),
//      ),
//    );
//  }
//}
//
//class UserInfoDetails {
//  UserInfoDetails(this.providerId, this.uid, this.displayName, this.photoUrl,
//      this.email, this.isAnonymous, this.isEmailVerified, this.phoneNumber);
//
//  /// The provider identifier.
//  final String providerId;
//
//  /// The provider’s user ID for the user.
//  final String uid;
//
//  /// The name of the user.
//  final String displayName;
//
//  /// The URL of the user’s profile photo.
//  final String photoUrl;
//
//  /// The user’s email address.
//  final String email;
//
//  // Check anonymous
//  final bool isAnonymous;
//
//  //Check if email is verified
//  final bool isEmailVerified;
//
//  /// The user’s phone number.
//  final String phoneNumber;
//}
