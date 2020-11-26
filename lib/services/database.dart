import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/models/wiggle.dart';
import 'dart:io';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  Future getdisplayName(String uid, String displayName) async {

    return await Firestore.instance
        .collection("users")
        .document(uid)
        .snapshots();
  }

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
  final CollectionReference wiggleCollection =
  Firestore.instance.collection('users');
  final chatReference = Firestore.instance.collection('ChatRoom');
  final anonChatReference = Firestore.instance.collection('Anonymous ChatRoom');
  final cloudReference = Firestore.instance.collection('cloud');
  final feedReference = Firestore.instance.collection('feed');
  final followersReference = Firestore.instance.collection('followers');
  final followingReference = Firestore.instance.collection('followings');
  final gameReference = Firestore.instance.collection('game');
  final triviaReference = Firestore.instance.collection('trivia');
  final maleReference = Firestore.instance.collection('male');
  final femaleReference = Firestore.instance.collection('female');
  final compatibilityReference = Firestore.instance.collection('compatibility');
  final bondReference = Firestore.instance.collection('Bond');
  final postReference = Firestore.instance.collection('posts');
  final blogReference = Firestore.instance.collection('blogs');

  Future<void> addData(blogData, String description) async {
    Firestore.instance
        .collection("blogs")
        .document('$description')
        .setData(blogData)
        .catchError((e) {
      print(e);
    });
  }

  getData() async {
    return await Firestore.instance
        .collection("blogs")
        .orderBy('time', descending: true)
        .snapshots();
  }

  addForumMessages(String desc, messageMap) async {
    blogReference
        .document(desc)
        .collection("blogs")
        .document(messageMap['time'].toString())
        .setData(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getForumMessages(String desc) async {
    return Firestore.instance
        .collection("blogs")
        .document(desc)
        .collection("blogs")
        .orderBy("time", descending: false)
        .snapshots();
  }

  Future updateGame(String gameRoomID, List player1, List player2) async {
    return gameReference.document(gameRoomID).setData({
      'player1': player1,
      'player2': player2,
    });
  }

  uploadtoken(String fcmToken) async {
    await Firestore.instance
        .collection('users')
        .document(uid)
        .collection('tokens')
        .document(uid)
        .setData({
      'token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
      'platform': Platform.operatingSystem
    });
  }

  Future updateTrivia(
      {String triviaRoomID,
        String question,
        String answer1,
        String answer2}) async {
    return triviaReference
        .document(triviaRoomID)
        .collection('questions')
        .document(question)
        .setData({
      'answer1': answer1,
      'answer2': answer2,
    });
  }

  Future createTriviaRoom(
      String triviaRoomID, String player1, String player2) async {
    return triviaReference.document(triviaRoomID).setData({
      'player1': player1,
      'player2': player2,
    });
  }

  Future uploadCompatibiltyAnswers({
    User user,
    Wiggle wiggle,
    String compatibilityRoomID,
    List<String> myAnswers,
  }) async {
    return compatibilityReference
        .document(compatibilityRoomID)
        .collection('${user.displayName} answers')
        .document(user.displayName)
        .setData({
      '${user.displayName} answers': myAnswers,
    });
  }

  Future uploadFriendCompatibiltyAnswers({
    User user,
    Wiggle wiggle,
    String compatibilityRoomID,
    List<String> myAnswers,
  }) async {
    return compatibilityReference
        .document(compatibilityRoomID)
        .collection('${wiggle.name} answers')
        .document(wiggle.name)
        .setData({
      '${wiggle.name} answers': myAnswers,
    });
  }

  Future uploadCompatibiltyQuestions({
    User user,
    Wiggle wiggle,
    String compatibilityRoomID,
    List<String> questions,
  }) async {
    return compatibilityReference
        .document(compatibilityRoomID)
        .collection('questions')
        .document(compatibilityRoomID)
        .setData({
      'questions': questions,
    });
  }

  Future createCompatibilityRoom(
      {String compatibilityRoomID, String player1, String player2}) async {
    return compatibilityReference.document(compatibilityRoomID).setData({
      'player1': player1,
      'player2': player2,
    });
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

  getRequestStatus(String ownerID, String ownerName, String userDp,
      String userID, String senderEmail) async {
    return feedReference
        .document(ownerID)
        .collection('feed')
    //.document(senderEmail)
        .where('senderEmail', isEqualTo: senderEmail)
    // .get();
        .where('type', isEqualTo: 'request')
        .snapshots();
  }

  Future uploadBondData(
      {User user,
        bool myAnon,
        Wiggle wiggle,
        bool friendAnon,
        String chatRoomID}) async {
    return bondReference.document(chatRoomID).setData({
      "${user.displayName} Email": user.email,
      "${user.displayName} Anon": myAnon,
      "${wiggle.name} Email": wiggle.email,
      "${wiggle.name} Anon": friendAnon,
    });
  }

  getBond(String chatRoomID) async {
    return Firestore.instance
        .collection('Bond')
        .document(chatRoomID)
        .snapshots();
    // .get();
  }

  Future uploadWhoData(
      {String email,
        String name,
        String nickname,
        bool isAnonymous,
        String dp,
        String gender,
        int score}) async {
    return gender == 'Male'
        ? maleReference.document(email).setData({
      "name": name,
      "email": email,
      "nickname": nickname,
      "dp": dp,
      "score": score,
      "isAnonymous": isAnonymous
    })
        : femaleReference.document(email).setData({
      "name": name,
      "email": email,
      "nickname": nickname,
      "dp": dp,
      "score": score,
      "isAnonymous": isAnonymous
    });
  }

  Future uploadPhotos(String photo) async {
    return await wiggleCollection
        .document(uid)
        .collection('photos')
        .document()
        .setData({'photo': photo});
  }

  Stream<QuerySnapshot> getphotos() {
    return wiggleCollection.document(uid).collection('photos').snapshots();
  }

  Future uploadUserData(
      String email,
      String name,
      String nickname,
      String gender,
      String block,
      String bio,
      String dp,
      bool isAnonymous,
      String media,
      String playlist,
      String course,
      String accoms) async {
    followersReference.document(email).collection('userFollowing');
    followingReference.document(email).collection('userFollowers');
    return await wiggleCollection.document(uid).setData({
      "email": email,
      "name": name,
      "nickname": nickname,
      "gender": gender,
      "block": block,
      "bio": bio,
      "dp": dp,
      "isAnonymous": isAnonymous,
      'anonBio': '',
      'anonInterest': '',
      'anonDp': '',
      'id': uid,
      'fame': 0,
      'media': media,
      'course': course,
      'playlist': playlist,
      'accoms': accoms,
    });
  }

  Future updateAnonymous(bool isAnonymous) async {
    return await wiggleCollection
        .document(uid)
        .updateData({"isAnonymous": isAnonymous});
  }

  Future updateAnonData(String anonBio, String anonInterest, String anonDp,
      String nickname) async {
    return await wiggleCollection.document(uid).updateData({
      'anonBio': anonBio,
      'anonInterest': anonInterest,
      'anonDp': anonDp,
      'nickname': nickname
    });
  }

  Future increaseFame(
      int initialvalue, String raterEmail, bool isAdditional) async {
    if (isAdditional) {
      await wiggleCollection
          .document(uid)
          .collection('likes')
          .document(raterEmail)
          .setData({'like': raterEmail});
    }
    return await wiggleCollection
        .document(uid)
        .updateData({'fame': initialvalue + 1});
  }



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

//  Future followingUser(int following, String displayNameX, String displayName) async {

//    return await Firestore.instance
//        .collection("users")
//        .document(displayName)
//        .updateData({'following': following + 1});
//  }

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
//    .collection("users")
//        .document(uid)
//        .delete(); await Firestore.instance


    return await Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'phoneVerified': true});
  }

  Future decreaseFollowing(String uid,int following,String displayNameX, String displayName, String uidX) async {

    await Firestore.instance
        .collection("users")
        .document(uid)
        .collection('following')
        .document(displayName)
        .delete();


//        if(following == 1 && following == 0){
//          return await Firestore.instance
//        .collection("users")
//        .document(uidX)
//        .updateData({'following': 0});
//        }

//        else {
          return await Firestore.instance
              .collection("users")
              .document(uid)
              .updateData({'following': following - 1});
//        }
  }

  PostD(String uid,int posts) async {
    //print(postsController);
    print("helloww");
    //String increment = postsController.text;
    //int incr = int.parse(posts);
    //print(incr);
    Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'posts': posts - 1});
  }

  Future increaseFollowing(String uid,int following,String displayNameX, String displayName, String uidX,String photoUrlX) async {
    await Firestore.instance
        .collection("users")
        .document(uid)
        .collection('following')
        .document(displayName)
        .setData({'followingname' : displayName,'followinguid' : uidX,'photoUrl' : photoUrlX});

        //.updateData({'followingname': uid,});

    return await Firestore.instance
        .collection("users")
        .document(uid)
        .updateData({'following': following + 1});
  }
  

  Future followUser(int followers, String uid, String displayName, String uidX,String photoUrlX) {

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
      'photoUrl' : photoUrlX,
    });

  }



  Future decreaseFame(
      int initialvalue, String raterEmail, bool isAdditional) async {
    if (isAdditional) {
      await wiggleCollection
          .document(uid)
          .collection('dislikes')
          .document(raterEmail)
          .setData({'dislike': raterEmail});
    }
    return await wiggleCollection
        .document(uid)
        .updateData({'fame': initialvalue - 1});
  }

  Future updateUserData(
      String email,
      String name,
      String gender,
      String block,
      String bio,
      String dp,
      bool isAnonymous,
      String media,
      String playlist,
      String course,
      String accoms,
      ) async {
    return await wiggleCollection.document(uid).updateData({
      "email": email,
      "name": name,
      "gender": gender,
      "block": block,
      "bio": bio,
      "dp": dp,
      "isAnonymous": isAnonymous,
      'id': uid,
      'media': media,
      'course': course,
      'playlist': playlist,
      'accoms': accoms,
    });
  }

  //wiggle list from snapshot
  List<Wiggle> _wiggleListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Wiggle(
          id: doc.data['id'] ?? '',
          email: doc.data['email'] ?? '',
          dp: doc.data['dp'] ?? '',
          name: doc.data['name'] ?? '',
          bio: doc.data['bio'] ?? '',
          community: doc.data['community'] ?? '',
          gender: doc.data['gender'] ?? '',
          block: doc.data['block'] ?? '',
          nickname: doc.data['nickname'] ?? '',
          isAnonymous: doc.data['isAnonymous'] ?? false,
          anonBio: doc.data['anonBio'] ?? '',
          anonInterest: doc.data['anonInterest'] ?? '',
          anonDp: doc.data['anonDp'] ?? '',
          fame: doc.data['fame'] ?? 0,
          media: doc.data['media'] ?? '',
          course: doc.data['course'] ?? '',
          playlist: doc.data['playlist'] ?? '',
          accoms: doc.data['accoms'] ?? '');
    }).toList();
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

  //get wiggle stream
  Stream<List<Wiggle>> get wiggles {
    return wiggleCollection.snapshots().map(_wiggleListFromSnapshot);
  }

  //get user doc stream
  Stream<User> get userData {
    return wiggleCollection
        .document(uid)
        .snapshots()
        .map(_userDataFromSnapshot);
  }

  createChatRoom(String chatRoomID, dynamic chatRoomMap) {
    Firestore.instance
        .collection("ChatRoom")
        .document(chatRoomID)
        .setData(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  createAnonymousChatRoom(String chatRoomID, dynamic chatRoomMap) {
    Firestore.instance
        .collection("Anonymous ChatRoom")
        .document(chatRoomID)
        .setData(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  createSusChatRoom(String chatRoomID, dynamic chatRoomMap) {
    Firestore.instance
        .collection("Sus ChatRoom")
        .document(chatRoomID)
        .setData(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
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

  addAnonymousConversationMessages(String chatRoomId, messageMap) async {
    Firestore.instance
        .collection("Anonymous ChatRoom")
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

  getSusConversationMessages(String chatRoomId) async {
    return Firestore.instance
        .collection("Sus ChatRoom")
        .document(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getAnonymousConversationMessages(String chatRoomId) async {
    return Firestore.instance
        .collection("Anonymous ChatRoom")
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

  getDocMyCompatibilityAnswers(wiggle, userData, compatibilityRoomID) async {
    return await Firestore.instance
        .collection("compatibility")
        .document(compatibilityRoomID)
        .collection("${userData.name} answers")
        .getDocuments();
  }

  getDocFriendCompatibilityAnswers(
      wiggle, userData, compatibilityRoomID) async {
    return await Firestore.instance
        .collection("compatibility")
        .document(compatibilityRoomID)
        .collection("${wiggle.name} answers")
        .getDocuments();
  }

  getWho(String gender) async {
    return gender == "Female"
        ? Firestore.instance
        .collection('male')
        .orderBy("score", descending: true)
        .getDocuments()
        : Firestore.instance
        .collection('female')
        .orderBy("score", descending: true)
        .getDocuments();
  }

  getReceivertoken(String email) async {
    return Firestore.instance
        .collection('users')
        .document(uid)
        .collection('tokens')
        .getDocuments();
  }

  getChatRooms(String userName) async {
    return Firestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }

  getNoOfChatRooms(String email) async {
    return Firestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: email)
        .getDocuments();
  }

  getNoOfAnonChatRooms(String email) async {
    return Firestore.instance
        .collection("Anonymous ChatRoom")
        .where("users", arrayContains: email)
        .getDocuments();
  }

  getAnonymousChatRooms(String userName) async {
    return Firestore.instance
        .collection("Anonymous ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }

  getSusChatRooms(String userName) async {
    return Firestore.instance
        .collection("Sus ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }


}
