import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/models/users.dart';

class FirebaseProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserData user;
  SingleUser singleUser;
//  Post post;
//  Message _message;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Reference _storageReference;

  Future<void> addDataToDb(SingleUser currentUser) async {
    print("Inside addDataToDb Method");

    _firestore
        .collection("display_names")
        .doc(currentUser.displayName)
        .set({'displayName': currentUser.displayName});

    user = UserData(
        //uid: currentUser.uid,
        email: currentUser.email,
        displayName: currentUser.displayName,
        //photoUrl: currentUser.photoUrl,
        //followers: 0,
        //following: 0,
        bio: '',
        //posts: 0,
        //phone: '');
    );
    //  Map<String, String> mapdata = Map<String, dynamic>();

    //  mapdata = user.toMap(user);

    return _firestore
        .collection("users")
        .doc(currentUser.uid)
        .set(singleUser.toMap(singleUser));
  }

  Future<bool> authenticateUser(User user) async {
    print("Inside authenticateUser");
    final QuerySnapshot result = await _firestore
        .collection("users")
        .where("email", isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    if (docs.length == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser =  _auth.currentUser;
    print("EMAIL ID : ${currentUser.email}");
    return currentUser;
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    return await _auth.signOut();
  }

  Future<User> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentication =
    await _signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: _signInAuthentication.accessToken,
      idToken: _signInAuthentication.idToken,
    );

    final UserCredential authResult = await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    assert(user.uid == currentUser.uid);
  }

  Future<String> uploadImageToStorage(File imageFile) async {
    _storageReference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}');
    UploadTask storageUploadTask = _storageReference.putFile(imageFile);
    var url = await (await storageUploadTask).ref.getDownloadURL();
    return url;
  }


  Future<UserData> retrieveUserDetails(User user) async {
    DocumentSnapshot _documentSnapshot =
    await _firestore.collection("users").doc(user.uid).get();
    return UserData.fromMap(_documentSnapshot.data());
  }

  Future<List<DocumentSnapshot>> retrieveUserPosts(String userId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(userId)
        .collection("posts")
        .get();
    return querySnapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchPostCommentDetails(DocumentReference reference) async {
    QuerySnapshot snapshot =
    await reference.collection("comments").get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> fetchPostLikeDetails(DocumentReference reference) async {
    print("REFERENCE : ${reference.path}");
    QuerySnapshot snapshot = await reference.collection("likes").get();
    return snapshot.docs;
  }

  Future<bool> checkIfUserLikedOrNot(String userId, DocumentReference reference) async {
    DocumentSnapshot snapshot =
    await reference.collection("likes").doc(userId).get();
    print('DOC ID : ${snapshot.reference.path}');
    return snapshot.exists;
  }

  Future<List<DocumentSnapshot>> retrievePosts(User user) async {
    List<DocumentSnapshot> list = <DocumentSnapshot>[];
    List<DocumentSnapshot> updatedList = <DocumentSnapshot>[];
    QuerySnapshot querySnapshot;
    QuerySnapshot snapshot =
    await _firestore.collection("users").get();
    for (int i = 0; i < snapshot.docs.length; i++) {
      if (snapshot.docs[i].id != user.uid) {
        list.add(snapshot.docs[i]);
      }
    }
    for (var i = 0; i < list.length; i++) {
      querySnapshot =
      await list[i].reference.collection("posts").get();
      for (var i = 0; i < querySnapshot.docs.length; i++) {
        updatedList.add(querySnapshot.docs[i]);
      }
    }
    // fetchSearchPosts(updatedList);
    print("UPDATED LIST LENGTH : ${updatedList.length}");
    return updatedList;
  }

  Future<List<String>> fetchAllUserNames(User user) async {
    List<String> userNameList = <String>[];
    QuerySnapshot querySnapshot =
    await _firestore.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != user.uid) {
        userNameList.add(querySnapshot.docs[i]['displayName']);
      }
    }
    print("USERNAMES LIST : ${userNameList.length}");
    return userNameList;
  }

  Future<String> fetchUidBySearchedName(String name) async {
    String uid;
    List<DocumentSnapshot> uidList = <DocumentSnapshot>[];

    QuerySnapshot querySnapshot =
    await _firestore.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      uidList.add(querySnapshot.docs[i]);
    }

    print("UID LIST : ${uidList.length}");

    for (var i = 0; i < uidList.length; i++) {
      if (uidList[i]['displayName'] == name) {
        uid = uidList[i].id;
      }
    }
    print("UID DOC ID: $uid");
    return uid;
  }

  Future<UserData> fetchUserDetailsById(String uid) async {
    DocumentSnapshot documentSnapshot =
    await _firestore.collection("users").doc(uid).get();
    return UserData.fromMap(documentSnapshot.data());
  }

  Future<void> followUser({String currentUserId, String followingUserId}) async {
    var followingMap = Map<String, String>();
    followingMap['uid'] = followingUserId;
    await _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .doc(followingUserId)
        .set(followingMap);

    var followersMap = Map<String, String>();
    followersMap['uid'] = currentUserId;

    return _firestore
        .collection("users")
        .doc(followingUserId)
        .collection("followers")
        .doc(currentUserId)
        .set(followersMap);
  }

  Future<void> unFollowUser({String currentUserId, String followingUserId}) async {
    await _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .doc(followingUserId)
        .delete();

    return _firestore
        .collection("users")
        .doc(followingUserId)
        .collection("followers")
        .doc(currentUserId)
        .delete();
  }

  Future<bool> checkIsFollowing(String name, String currentUserId) async {
    bool isFollowing = false;
    String uid = await fetchUidBySearchedName(name);
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(currentUserId)
        .collection("following")
        .get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id == uid) {
        isFollowing = true;
      }
    }
    return isFollowing;
  }

  Future<List<DocumentSnapshot>> fetchStats({String uid, String label}) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(uid)
        .collection(label)
        .get();
    return querySnapshot.docs;
  }

  Future<void> updatePhoto(String photoUrl, String uid) async {
    Map<String, dynamic> map = Map();
    map['photoUrl'] = photoUrl;
    return _firestore.collection("users").doc(uid).update(map);
  }

  Future<void> updateDetails(String uid, String name, String bio, String email, String phone) async {
    Map<String, dynamic> map = Map();
    map['displayName'] = name;
    map['bio'] = bio;
    map['email'] = email;
    map['phone'] = phone;
    return _firestore.collection("users").doc(uid).update(map);
  }

  Future<List<String>> fetchUserNames(User user) async {
    DocumentReference documentReference =
    _firestore.collection("messages").doc(user.uid);
    List<String> userNameList = <String>[];
    List<String> chatUsersList = <String>[];
    QuerySnapshot querySnapshot =
    await _firestore.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != user.uid) {
        print("USERNAMES : ${querySnapshot.docs[i].id}");
        userNameList.add(querySnapshot.docs[i].id);
        //querySnapshot.documents[i].reference.collection("collectionPath");
        //userNameList.add(querySnapshot.documents[i].data['displayName']);
      }
    }

    for (var i = 0; i < userNameList.length; i++) {
      if (documentReference.collection(userNameList[i]) != null) {
        if (documentReference.collection(userNameList[i]).get() !=
            null) {
          print("CHAT USERS : ${userNameList[i]}");
          chatUsersList.add(userNameList[i]);
        }
      }
    }

    print("CHAT USERS LIST : ${chatUsersList.length}");

    return chatUsersList;

    // print("USERNAMES LIST : ${userNameList.length}");
    // return userNameList;
  }

  Future<List<UserData>> fetchAllUsers(User user) async {
    List<UserData> userList = <UserData>[];
    QuerySnapshot querySnapshot =
    await _firestore.collection("users").get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id
          != user.uid) {
        userList.add(UserData.fromMap(querySnapshot.docs[i].data()));
        //userList.add(querySnapshot.documents[i].data[User.fromMap(mapData)]);
      }
    }
    print("USERSLIST : ${userList.length}");
    return userList;
  }


  Future<List<DocumentSnapshot>> fetchFeed(User user) async {
    List<String> followingUIDs = <String>[];
    List<DocumentSnapshot> list =<DocumentSnapshot>[];

    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("following")
        .get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      followingUIDs.add(querySnapshot.docs[i].id
      );
    }

    print("FOLLOWING UIDS : ${followingUIDs.length}");

    for (var i = 0; i < followingUIDs.length; i++) {
      print("SDDSSD : ${followingUIDs[i]}");

      //retrievePostByUID(followingUIDs[i]);
      // fetchUserDetailsById(followingUIDs[i]);

      QuerySnapshot postSnapshot = await _firestore
          .collection("users")
          .doc(followingUIDs[i])
          .collection("posts")
          .get();
      // postSnapshot.documents;
      for (var i = 0; i < postSnapshot.docs.length; i++) {
        print("dad : ${postSnapshot.docs[i].id
        }");
        list.add(postSnapshot.docs[i]);
        print("ads : ${list.length}");
      }
    }

    return list;
  }

  Future<List<String>> fetchFollowingUids(User user) async{
    List<String> followingUIDs = <String>[];

    QuerySnapshot querySnapshot = await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("following")
        .get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      followingUIDs.add(querySnapshot.docs[i].id
      );
    }

    for (var i = 0; i < followingUIDs.length; i++) {
      print("DDDD : ${followingUIDs[i]}");
    }
    return followingUIDs;
  }
}
