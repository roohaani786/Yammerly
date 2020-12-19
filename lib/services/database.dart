import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:techstagram/models/user.dart';

class DatabaseService {

  final String uid;

  DatabaseService({this.uid});


  // Get user's displayName
  Future getdisplayName(String uid, String displayName) async {

    return await Firestore.instance
        .collection("users")
        .document(uid)
        .snapshots();
  }

  // send verification email to organic users
  void sendVerificationEmail() async {
    final auth = FirebaseAuth.instance;

    print("andar aaya");
    FirebaseUser firebaseUser = await auth.currentUser();
    print("hogaya bhai");

    Fluttertoast.showToast(
        timeInSecForIosWeb: 100,
        msg: "Verificatin link has been sent to you mail");

    await firebaseUser.sendEmailVerification();
  }

  // Set emailVerified boolean to true
  Future updateEmailVerification(String uid,) async{
    return await Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'emailVerified': true});
  }

  //Update user's profile picture
  Future updatephotoURL(String uid, String photoURl) async {

    return await Firestore.instance
        .collection("posts")
        .document(uid)
        .updateData({'photoURL': photoURl});
  }

  getUserByUsername(String displayName) async {
    return Firestore.instance
        .collection('users')
        .where("displayName", isGreaterThanOrEqualTo: displayName)
        .getDocuments();
  }

  getUserByUserEmail(String email) async {
    return Firestore.instance
        .collection('users')
        .where("email", isEqualTo: email)
        .getDocuments();
  }

  //collection reference

  final CollectionReference wiggleCollection = Firestore.instance.collection(
      'users');
  final feedReference = Firestore.instance.collection('feed');
  final followersReference = Firestore.instance.collection('followers');
  final followingReference = Firestore.instance.collection('followings');
  final postReference = Firestore.instance.collection('posts');


  Future likepost(int initialvalue, String postId, String userEmail)  {

     Firestore.instance
        .collection("posts")
        .document(postId)
        .updateData({'likes': initialvalue + 1});

     Firestore.instance
        .collection("posts")
        .document(postId)
        .collection('likes')
        .document(userEmail)
        .setData({'liked': userEmail});

  }

  Future unlikepost(int initialvalue, String postId, String userEmail) {


    if(initialvalue < 0){

      initialvalue = 0;

      Firestore.instance
          .collection("posts")
          .document(postId)
          .updateData({'likes': initialvalue});
    }

    else {
      Firestore.instance
          .collection("posts")
          .document(postId)
          .updateData({'likes': initialvalue - 1});

      Firestore.instance
          .collection("posts")
          .document(postId)
          .collection('likes')
          .document(userEmail)
          .delete();
    }
  }

  Future followUser(int followers, String uid, String displayName, String uidX,
      String photoUrlX) {
    Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'followers': followers + 1});

    Firestore.instance
        .collection("users")
        .document(uid)
        .collection('followers')
        .document(displayName)
        .setData({
      'followername': displayName,
      'followeruid': uidX,
      'photoUrl': photoUrlX,
    });
  }

  Future unfollowUser(int followers, String uid, String displayName) {


    Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'followers': followers - 1});

    Firestore.instance
        .collection("users")
        .document(uid)
        .collection('followers')
        .document(displayName)
        .delete();
  }

  Future PhoneverificationX(String uid) async {

    return await Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'phoneVerified': true});
  }

  Future increaseFollowing(String uid, int following, String displayNameX,
      String displayName, String uidX, String photoUrlX) async {
    await Firestore.instance
        .collection("users")
        .document(uid)
        .collection('following')
        .document(displayName)
        .setData({
      'followingname': displayName,
      'followinguid': uidX,
      'photoUrl': photoUrlX
    });


    return await Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'following': following + 1});
  }

  Future decreaseFollowing(String uid, int following, String displayNameX,
      String displayName, String uidX) async {

    await Firestore.instance
        .collection("users")
        .document(uid)
        .collection('following')
        .document(displayName)
        .delete();

    return await Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'following': following - 1});
  }

  //decrement post count

  PostD(String uid, int posts) async {
    print("helloww");

    Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'posts': posts - 1});
  }


  Future acceptRequest(String ownerID, String ownerName, String userDp,
      String userID, String senderEmail) {
    return feedReference
        .document(ownerID)
        .collection('feed')
        .document(senderEmail)
        .setData({
      'type': 'request',
      'ownerID': ownerID,
      'ownerName': ownerName,
      'timestamp': DateTime.now(),
      'userDp': userDp,
      'userID': userID,
      'status': 'accepted',
      'senderEmail': senderEmail
    });
  }

  //userData from snapshot

  User _userDataFromSnapshot(DocumentSnapshot snapshot) {

    return User(
        email: snapshot.data['email'],
        bio: snapshot.data['bio'],
        displayName: snapshot.data['name'],
        gender: snapshot.data['gender'],
        photoUrl: snapshot.data['photoUrl'] ?? '');
  }

  //get user doc stream

  Stream<User> get userData {
    return wiggleCollection
        .document(uid)
        .snapshots()
        .map(_userDataFromSnapshot);
  }

  addConversationMessages(String chatRoomId, messageMap) async {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .document(messageMap['time'].toString())
        .setData(messageMap)
    // .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(String chatRoomId) async {
    return Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getPosts() async {
    return Firestore.instance
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  getUsers() async {
    return Firestore.instance
        .collection("users")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }
}
