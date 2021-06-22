import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:techstagram/models/user.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:techstagram/models/users.dart';

class AuthService {
  // Dependencies
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Shared State for Widgets
  Stream<User> user; // firebase user
  Stream<Map<String, dynamic>> profile; // custom user data in Firestore
  PublishSubject loading = PublishSubject();

  AuthService() {
    user = _auth.authStateChanges();

    profile = user.switchMap((User u) {
      if (u != null) {
        return _db
            .collection('users')
            .doc(u.uid)
            .snapshots()
            .map((snap) => snap.data());
      } else {
        return Stream.value(({}));
      }
    });
  }

  Future<String> emailVerify() async {
    User user;

    print("bahia bhia");
    //print(user.email);
    try {
      print("try");
      await user.sendEmailVerification();
      print("Success");
      Fluttertoast.showToast(
          timeInSecForIosWeb: 100,
          msg: "email Verification link has been sent to your mail");
      return user.uid;
    } catch (e) {
      print("An error occured while trying to send email verification");
      print(e.message);
    }
    return null;
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User> hellogoogleSignIn() async {
    loading.add(true);

    // Step 1
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    // Step 2
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final User user = (await _auth.signInWithCredential(credential)).user;
// Checking if email and name is null
    checkuserexists(user.uid, user, user.displayName);

//      updateUserData(user);

    // Step 3

    // Done
    loading.add(false);

    print("signed in " + user.displayName);

    return user;
  }

  Future<bool> usernameCheck(String displayName) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('displayName', isEqualTo: displayName)
        .get();
    return result.docs.isEmpty;
  }

  checkuserexists(String uid, User user, String displayName) async {
    final snapShotX =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (snapShotX.exists) {
      updateUserData(user);
    } else {
      updatenewUserData(user);
    }
//        updatenewUserData(user);
  }

  User userdatax;

  void updateUserData(User user) async {
    DocumentReference ref = _db.collection('users').doc(user.uid);

    return ref.set({
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoURL,
      'displayName': user.displayName.toLowerCase(),
      'lastSeen': DateTime.now(),
      //'followers': user.followers,
      //'following': user.following,
      //'posts': user.posts,
      'bio': "Proud Hashtager",
      'emailVerified': false,
      'phoneVerified': false,
    }, SetOptions(merge: true));
  }

  void updatenewUserData(User user) async {
    DocumentReference ref = _db.collection('users').doc(user.uid);

    return ref.set({
      'uid': user.uid,
      'email': user.email,
      'photoURL': user.photoURL,
      'displayName': user.displayName.toLowerCase(),
      'lastSeen': DateTime.now(),
      'followers': 0,
      'following': 0,
      'posts': 0,
      'bio': "Proud Hashtager",
      'emailVerified': false,
      'phoneVerified': false,
    }, SetOptions(merge: true));
  }

  void signOut() {
    _auth.signOut();
  }
}

final AuthService authService = AuthService();
