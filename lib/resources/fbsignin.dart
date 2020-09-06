import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart' as fl;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:techstagram/ui/HomePage.dart';

class FbLoginPage extends StatefulWidget {
  @override
  _FbLoginPageState createState() => _FbLoginPageState();
}

class _FbLoginPageState extends State<FbLoginPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  fl.FacebookLogin fbLogin = new fl.FacebookLogin();
  bool isFacebookLoginIn = false;
  String errorMessage = '';
  String successMessage = '';
  int initialindexg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Email Login'),
      ),
      body: Center(
          child: Column(
            children: [
              (!isFacebookLoginIn
                  ? RaisedButton(
                child: Text('Facebook Login'),
                onPressed: () {
                  facebookLogin(context).then((user) {
                    if (user != null) {
                      print('Logged in successfully.');

                    Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                    builder: (context) =>
                    HomePage(title:

                    "huhu",
                      uid: "h",
                    )),
                            (_) => false);

                      setState(() {
                        isFacebookLoginIn = true;
                        successMessage =
                        'Logged in successfully.\nEmail : ${user.email}\nYou can now navigate to Home Page.';

                      });
                    } else {
                      print('Error while Login.');
                    }
                  });
                },
              )
                  : RaisedButton(
                child: Text('Facebook Logout'),
                onPressed: () {
                  facebookLoginout().then((response) {
                    if (response) {
                      setState(() {
                        isFacebookLoginIn = false;
                        successMessage = '';
                      });
                    }
                  });
                },
              )),
            ],
          )),
    );
  }

  Future<FirebaseUser> facebookLogin(BuildContext context) async {
    FirebaseUser currentUser;
    // fbLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    // if you remove above comment then facebook login will take username and pasword for login in Webview
    try {
      final FacebookLoginResult facebookLoginResult =
      await fbLogin.logIn(['email']);
      if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
        FacebookAccessToken facebookAccessToken =
            facebookLoginResult.accessToken;
        final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: facebookAccessToken.token);
        final AuthResult user = await auth.signInWithCredential(credential);
        assert(user.user.email != null);
        assert(user.user.displayName != null);
        assert(!user.user.isAnonymous);
        assert(await user.user.getIdToken() != null);
        currentUser = await auth.currentUser();
        assert(user.user.uid == currentUser.uid);
        return currentUser;
      }
    } catch (e) {
      print(e);
    }
    return currentUser;
  }

  Future<bool> facebookLoginout() async {
    await auth.signOut();
    await fbLogin.logOut();
    return true;
  }
}