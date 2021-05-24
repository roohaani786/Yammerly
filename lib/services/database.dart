import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/models/wiggle.dart';
import 'dart:io';

class DatabaseService {
  final String uid;

  DatabaseService({this.uid});

  Future getdisplayName(String uid, String displayName) async {

    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots();
  }

  Future updateEmailVerification(String uid,) async{
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({'emailVerified': true});
  }

  Future updatephotoURL(String uid, String photoURl) async {

    return await FirebaseFirestore.instance
        .collection("posts")
        .doc(uid)
        .update({'photoURL': photoURl});
  }

  getUserByUsername(String displayName) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where("displayName", isGreaterThanOrEqualTo: displayName)
        .get();
  }

  getUserByUserEmail(String email) async {
    return FirebaseFirestore.instance
        .collection('users')
        .where("email", isEqualTo: email)
        .get();
  }

  //collection reference
  final CollectionReference wiggleCollection =
  FirebaseFirestore.instance.collection('users');
  final chatReference = FirebaseFirestore.instance.collection('ChatRoom');
  final anonChatReference = FirebaseFirestore.instance.collection('Anonymous ChatRoom');
  final cloudReference = FirebaseFirestore.instance.collection('cloud');
  final feedReference = FirebaseFirestore.instance.collection('feed');
  final followersReference = FirebaseFirestore.instance.collection('followers');
  final followingReference = FirebaseFirestore.instance.collection('followings');
  final gameReference = FirebaseFirestore.instance.collection('game');
  final triviaReference = FirebaseFirestore.instance.collection('trivia');
  final maleReference = FirebaseFirestore.instance.collection('male');
  final femaleReference = FirebaseFirestore.instance.collection('female');
  final compatibilityReference = FirebaseFirestore.instance.collection('compatibility');
  final bondReference = FirebaseFirestore.instance.collection('Bond');
  final postReference = FirebaseFirestore.instance.collection('posts');
  final blogReference = FirebaseFirestore.instance.collection('blogs');

  Future<void> addData(blogData, String description) async {
    FirebaseFirestore.instance
        .collection("blogs")
        .doc('$description')
        .set(blogData)
        .catchError((e) {
      print(e);
    });
  }

  getData() async {
    return FirebaseFirestore.instance
        .collection("blogs")
        .orderBy('time', descending: true)
        .snapshots();
  }

  addForumMessages(String desc, messageMap) async {
    blogReference
        .doc(desc)
        .collection("blogs")
        .doc(messageMap['time'].toString())
        .set(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getForumMessages(String desc) async {
    return FirebaseFirestore.instance
        .collection("blogs")
        .doc(desc)
        .collection("blogs")
        .orderBy("time", descending: false)
        .snapshots();
  }

  Future updateGame(String gameRoomID, List player1, List player2) async {
    return gameReference.doc(gameRoomID).set({
      'player1': player1,
      'player2': player2,
    });
  }

  uploadtoken(String fcmToken) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tokens')
        .doc(uid)
        .set({
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
        .doc(triviaRoomID)
        .collection('questions')
        .doc(question)
        .set({
      'answer1': answer1,
      'answer2': answer2,
    });
  }

  Future createTriviaRoom(
      String triviaRoomID, String player1, String player2) async {
    return triviaReference.doc(triviaRoomID).set({
      'player1': player1,
      'player2': player2,
    });
  }

  Future uploadCompatibiltyAnswers({
    SingleUser user,
    Wiggle wiggle,
    String compatibilityRoomID,
    List<String> myAnswers,
  }) async {
    return compatibilityReference
        .doc(compatibilityRoomID)
        .collection('${user.displayName} answers')
        .doc(user.displayName)
        .set({
      '${user.displayName} answers': myAnswers,
    });
  }

  Future uploadFriendCompatibiltyAnswers({
    SingleUser user,
    Wiggle wiggle,
    String compatibilityRoomID,
    List<String> myAnswers,
  }) async {
    return compatibilityReference
        .doc(compatibilityRoomID)
        .collection('${wiggle.name} answers')
        .doc(wiggle.name)
        .set({
      '${wiggle.name} answers': myAnswers,
    });
  }

  Future uploadCompatibiltyQuestions({
    SingleUser user,
    Wiggle wiggle,
    String compatibilityRoomID,
    List<String> questions,
  }) async {
    return compatibilityReference
        .doc(compatibilityRoomID)
        .collection('questions')
        .doc(compatibilityRoomID)
        .set({
      'questions': questions,
    });
  }

  Future createCompatibilityRoom(
      {String compatibilityRoomID, String player1, String player2}) async {
    return compatibilityReference.doc(compatibilityRoomID).set({
      'player1': player1,
      'player2': player2,
    });
  }

  Future acceptRequest(String ownerID, String ownerName, String userDp,
      String userID, String senderEmail) {
    return feedReference
        .doc(ownerID)
        .collection('feed')
        .doc(senderEmail)
        .set({
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
        .doc(ownerID)
        .collection('feed')
    //.doc(senderEmail)
        .where('senderEmail', isEqualTo: senderEmail)
    // .get();
        .where('type', isEqualTo: 'request')
        .snapshots();
  }

  Future uploadBondData(
      {SingleUser user,
        bool myAnon,
        Wiggle wiggle,
        bool friendAnon,
        String chatRoomID}) async {
    return bondReference.doc(chatRoomID).set({
      "${user.displayName} Email": user.email,
      "${user.displayName} Anon": myAnon,
      "${wiggle.name} Email": wiggle.email,
      "${wiggle.name} Anon": friendAnon,
    });
  }

  getBond(String chatRoomID) async {
    return FirebaseFirestore.instance
        .collection('Bond')
        .doc(chatRoomID)
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
        ? maleReference.doc(email).set({
      "name": name,
      "email": email,
      "nickname": nickname,
      "dp": dp,
      "score": score,
      "isAnonymous": isAnonymous
    })
        : femaleReference.doc(email).set({
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
        .doc(uid)
        .collection('photos')
        .doc()
        .set({'photo': photo});
  }

  Stream<QuerySnapshot> getphotos() {
    return wiggleCollection.doc(uid).collection('photos').snapshots();
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
    followersReference.doc(email).collection('userFollowing');
    followingReference.doc(email).collection('userFollowers');
    return await wiggleCollection.doc(uid).set({
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
        .doc(uid)
        .update({"isAnonymous": isAnonymous});
  }

  Future updateAnonData(String anonBio, String anonInterest, String anonDp,
      String nickname) async {
    return await wiggleCollection.doc(uid).update({
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
          .doc(uid)
          .collection('likes')
          .doc(raterEmail)
          .set({'like': raterEmail});
    }
    return await wiggleCollection
        .doc(uid)
        .update({'fame': initialvalue + 1});
  }



  Future likepost(int initialvalue, String postId,String uid, String userDisplayName)  async {

     await FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .update({'likes': initialvalue + 1});

     print("bhai bhaibbb");
     print(uid);

     FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .collection('likes')
        .doc(uid)
        .set({'liked': userDisplayName});


  }


  Future unlikepost(int initialvalue, String postId, String uid,String userEmail) async {


    if(initialvalue < 0){

      await FirebaseFirestore.instance
          .collection("posts")
          .doc(postId)
          .update({'likes': 0});
    }

    else{
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(postId)
          .update({'likes': initialvalue - 1});

      FirebaseFirestore.instance
          .collection("posts")
          .doc(postId)
          .collection('likes')
          .doc(uid)
          .delete();
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('button', true);
  }

//  Future followingUser(int following, String displayNameX, String displayName) async {

//    return await FirebaseFirestore.instance
//        .collection("users")
//        .doc(displayName)
//        .update({'following': following + 1});
//  }

  Future unfollowUser(int followers, String uid, String displayName) {


    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({'followers': followers - 1});

    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('followers')
        .doc(displayName)
        .delete();
  }

  Future PhoneverificationX(String uid) async {
//    .collection("users")
//        .doc(uid)
//        .delete(); await FirebaseFirestore.instance


    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({'phoneVerified': true});
  }

  Future decreaseFollowing(String uid,int following,String displayNameX, String displayName, String uidX) async {

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('following')
        .doc(displayName)
        .delete();


//        if(following == 1 && following == 0){
//          return await FirebaseFirestore.instance
//        .collection("users")
//        .doc(uidX)
//        .update({'following': 0});
//        }

//        else {
          return await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .update({'following': following - 1});
//        }
  }

  PostD(String uid,int posts) async {
    //print(postsController);
    print("helloww");
    //String increment = postsController.text;
    //int incr = int.parse(posts);
    //print(incr);
    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({'posts': posts - 1});
  }

  CommentD(String postId,int comments,int commCount) async {
    int UcommCount=0;
    int Ucomments=0;
    if(commCount > 0){
      UcommCount = commCount-1;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('commCount', UcommCount);
    }else if(comments > 0){
      Ucomments = comments -1;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('comments', Ucomments);
    }
    FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .update({'comments': (comments+commCount) - 1});
  }

  Future increaseFollowing(String uid,int following,String displayNameX, String displayName, String uidX,String photoUrlX) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('following')
        .doc(displayName)
        .set({'followingname' : displayName,'followinguid' : uidX,'photoUrl' : photoUrlX});

        //.update({'followingname': uid,});

    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({'following': following + 1});
  }
  

  Future followUser(int followers, String uid, String displayName, String uidX,String photoUrlX) {

    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({'followers': followers + 1});

    FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection('followers')
        .doc(displayName)
        .set({
      'followername': displayName,
      'followeruid': uidX,
      'photoUrl' : photoUrlX,
    });

  }



  Future decreaseFame(
      int initialvalue, String raterEmail, bool isAdditional) async {
    if (isAdditional) {
      await wiggleCollection
          .doc(uid)
          .collection('dislikes')
          .doc(raterEmail)
          .set({'dislike': raterEmail});
    }
    return await wiggleCollection
        .doc(uid)
        .update({'fame': initialvalue - 1});
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
    return await wiggleCollection.doc(uid).update({
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
    return snapshot.docs.map((doc) {
      return Wiggle(
          id: doc['id'] ?? '',
          email: doc['email'] ?? '',
          dp: doc['dp'] ?? '',
          name: doc['name'] ?? '',
          bio: doc['bio'] ?? '',
          community: doc['community'] ?? '',
          gender: doc['gender'] ?? '',
          block: doc['block'] ?? '',
          nickname: doc['nickname'] ?? '',
          isAnonymous: doc['isAnonymous'] ?? false,
          anonBio: doc['anonBio'] ?? '',
          anonInterest: doc['anonInterest'] ?? '',
          anonDp: doc['anonDp'] ?? '',
          fame: doc['fame'] ?? 0,
          media: doc['media'] ?? '',
          course: doc['course'] ?? '',
          playlist: doc['playlist'] ?? '',
          accoms: doc['accoms'] ?? '');
    }).toList();
  }

  //userData from snapshot
  SingleUser _userDataFromSnapshot(DocumentSnapshot snapshot) {

    return SingleUser(
        email: snapshot['email'],
        bio: snapshot['bio'],
        displayName: snapshot['name'],
        gender: snapshot['gender'],
        photoUrl: snapshot['photoUrl'] ?? '');
  }

  //get wiggle stream
  Stream<List<Wiggle>> get wiggles {
    return wiggleCollection.snapshots().map(_wiggleListFromSnapshot);
  }

  //get user doc stream
  Stream<SingleUser> get userData {
    return wiggleCollection
        .doc(uid)
        .snapshots()
        .map(_userDataFromSnapshot);
  }

  createChatRoom(String chatRoomID, dynamic chatRoomMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomID)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  createAnonymousChatRoom(String chatRoomID, dynamic chatRoomMap) {
    FirebaseFirestore.instance
        .collection("Anonymous ChatRoom")
        .doc(chatRoomID)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  createSusChatRoom(String chatRoomID, dynamic chatRoomMap) {
    FirebaseFirestore.instance
        .collection("Sus ChatRoom")
        .doc(chatRoomID)
        .set(chatRoomMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addConversationMessages(String chatRoomId, messageMap) async {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageMap['time'].toString())
        .set(messageMap)
    // .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  addAnonymousConversationMessages(String chatRoomId, messageMap) async {
    FirebaseFirestore.instance
        .collection("Anonymous ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .doc(messageMap['time'].toString())
        .set(messageMap)
    // .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getSusConversationMessages(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("Sus ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots();
  }

  getAnonymousConversationMessages(String chatRoomId) async {
    return FirebaseFirestore.instance
        .collection("Anonymous ChatRoom")
        .doc(chatRoomId)
        .collection("chats")
        .orderBy("time", descending: false)
        .snapshots();
  }


  getPosts() async {
    return FirebaseFirestore.instance
        .collection("posts")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  getUsers() async {
    return FirebaseFirestore.instance
        .collection("users")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  getDocMyCompatibilityAnswers(wiggle, userData, compatibilityRoomID) async {
    return await FirebaseFirestore.instance
        .collection("compatibility")
        .doc(compatibilityRoomID)
        .collection("${userData.name} answers")
        .get();
  }

  getDocFriendCompatibilityAnswers(
      wiggle, userData, compatibilityRoomID) async {
    return await FirebaseFirestore.instance
        .collection("compatibility")
        .doc(compatibilityRoomID)
        .collection("${wiggle.name} answers")
        .get();
  }

  getWho(String gender) async {
    return gender == "Female"
        ? FirebaseFirestore.instance
        .collection('male')
        .orderBy("score", descending: true)
        .get()
        : FirebaseFirestore.instance
        .collection('female')
        .orderBy("score", descending: true)
        .get();
  }

  getReceivertoken(String email) async {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tokens')
        .get();
  }

  getChatRooms(String userName) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }

  getNoOfChatRooms(String email) async {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .where("users", arrayContains: email)
        .get();
  }

  getNoOfAnonChatRooms(String email) async {
    return FirebaseFirestore.instance
        .collection("Anonymous ChatRoom")
        .where("users", arrayContains: email)
        .get();
  }

  getAnonymousChatRooms(String userName) async {
    return FirebaseFirestore.instance
        .collection("Anonymous ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }

  getSusChatRooms(String userName) async {
    return FirebaseFirestore.instance
        .collection("Sus ChatRoom")
        .where("users", arrayContains: userName)
        .snapshots();
  }


}
