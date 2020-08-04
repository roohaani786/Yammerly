import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:techstagram/Welcome/welcome_screen.dart';
import 'package:techstagram/ui/HomePage.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();


Future<String> signInWithGoogle(bool Success) async {

  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
  await googleSignInAccount.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );

  final AuthResult authResult = await _auth.signInWithCredential(credential);
  final FirebaseUser user = authResult.user;

  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final FirebaseUser currentUser = await _auth.currentUser();
  assert(user.uid == currentUser.uid);


  Success = true;
  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
}

class GoogleSigninScreen extends StatefulWidget {
  @override
  _GoogleSigninScreenState createState() => _GoogleSigninScreenState();
}

class _GoogleSigninScreenState extends State<GoogleSigninScreen> {

  bool success = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(child: FlatButton(
          child: Container(
            child: Text("Choose Google accounts"),
          ),
          onPressed: () {
            signInWithGoogle(success).whenComplete(() {
              if (success == true)
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return HomePage(
                        title: "welcome",
                      );
                    },
                  ),
                );
              else
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return WelcomeScreen(
                      );
                    },
                  ),
                );
            });
          }

      ),
      ),
    );
  }
}