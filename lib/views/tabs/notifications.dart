import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techstagram/ui/Otheruser/other_user.dart';
import 'package:techstagram/ui/post.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

final NotificationRefrence = FirebaseFirestore.instance.collection("users");

class NotificationsPage extends StatefulWidget{
  final String currUid;
  final String displayNameCurrUser;


  NotificationsPage({this.currUid,this.displayNameCurrUser});

  @override
  NotificationsPageState createState() => NotificationsPageState(currUid: currUid,displayNameCurrUser: displayNameCurrUser);
}

class NotificationsPageState extends State<NotificationsPage> {
  final String currUid;
  final String displayNameCurrUser;
  final GlobalKey<FormState> _CommentKey = GlobalKey<FormState>();

  String CommentId = Uuid().v4();
  String NotificationId = Uuid().v4();

  TextEditingController commentTextEditingController = TextEditingController();

  NotificationsPageState({this.currUid,this.displayNameCurrUser});
  // return Firestore.instance
  //     .collection("posts")
  //     .orderBy("timestamp", descending: true)
  //     .snapshots();


  retrieveNotificationsLike() {
     print("bhujm");
     print(currUid);


    return  StreamBuilder(
      stream: NotificationRefrence.doc(currUid)
          .collection("notification")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, dataSnapshot){
        if (!dataSnapshot.hasData){
          return Container(
            color: Colors.white,
          );
        }
        List<NotificationLike> Notifications = [];
        dataSnapshot.data.documents.forEach((document){
          Notifications.add(NotificationLike.fromDocument(document));
        });
        return ListView(
          children: Notifications,
        );
      },
    );
  }

  retrieveNotificationsComment(){
    print("bhujm");
    print(currUid);
    return  StreamBuilder(
      stream: NotificationRefrence.doc(currUid)
          .collection("notification")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, dataSnapshot){
        if (!dataSnapshot.hasData){
          return Container(
            color: Colors.white,
          );
        }
        List<NotificationComment> Notifications = [];
        dataSnapshot.data.documents.forEach((document){
          Notifications.add(NotificationComment.fromDocument(document));
        });
        return ListView(
          children: Notifications,
        );
      },
    );
  }

  retrieveNotificationsShare(){
    print("bhujm");
    print(currUid);
    return  StreamBuilder(
      stream: NotificationRefrence.doc(currUid)
          .collection("notification")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, dataSnapshot){
        if (!dataSnapshot.hasData){
          return Container(
            color: Colors.white,
          );
        }
        List<NotificationShare> Notifications = [];
        dataSnapshot.data.documents.forEach((document){
          Notifications.add(NotificationShare.fromDocument(document));
        });
        return ListView(
          children: Notifications,
        );
      },
    );
  }

  retrieveNotificationsFollow(){
    print("bhujm");
    print(currUid);
    return  StreamBuilder(
      stream: NotificationRefrence.doc(currUid)
          .collection("notification")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, dataSnapshot){
        if (!dataSnapshot.hasData){
          return Container(
            color: Colors.white,
          );
        }
        List<NotificationFollow> Notifications = [];
        dataSnapshot.data.documents.forEach((document){
          Notifications.add(NotificationFollow.fromDocument(document));
        });
        return ListView(
          children: Notifications,
        );
      },
    );
  }

  bool errordikhaoC = false;

//   String commentValidator(String value) {
//     if (value.length == null) {
// //      return 'Password must be longer than 8 characters';
//       setState(() {
//         errordikhaoC = true;
//       });
//     } else {
//       setState(() {
//         errordikhaoC = false;
//       });
//     }
//   }




  //setData({'liked': userEmail});

  var commentCount = 0;
  saveCurrUser() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('currUid', currUid);
      prefs.setString('displayNameCurrUser', displayNameCurrUser);
  }


  @override
  void initState() {
    saveCurrUser();
    retrieveNotificationsLike();

  }

  @override
  Widget build(BuildContext) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          backgroundColor: Colors.white,

          appBar: TBar(),

          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              retrieveNotificationsLike(),
              retrieveNotificationsComment(),
              retrieveNotificationsShare(),
              retrieveNotificationsFollow(),
              // Container(
              //     //color: Colors.blue,
              //     child: Icon(
              //         Icons.movie
              //     )
              // ),
              // Container(
              //   //color: Colors.blue,
              //   child: Icon(
              //       Icons.games
              //   ),
              // ),
              // Container(
              //   //color: Colors.blue,
              //   child: Icon(
              //       Icons.games
              //   ),
              // ),
            ],
          ),

      ),
    );
  }
}

//notfication for follow tab

class NotificationFollow extends StatefulWidget {
  final String userId;
  final String comment;
  final Timestamp timestamp;
  final String status;
  final String commentId;
  final String notificationId;
  final int likes;
  final String postId;

  NotificationFollow({this.postId,this.userId,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

  factory NotificationFollow.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationFollow(
      userId: documentSnapshot["uid"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
      status: documentSnapshot["status"],
      commentId: documentSnapshot["commentId"],
      notificationId: documentSnapshot["notificationId"],
      likes: documentSnapshot["likes"],
      postId: documentSnapshot["postId"],
    );
  }

  @override
  _NotificationFollowState createState() => _NotificationFollowState();
}

class _NotificationFollowState extends State<NotificationFollow> {

  DocumentSnapshot docSnap;
  String userName;
  String postUrl;
  String photoUrl;

  TextEditingController userNameController,photoUrlController,postUrlController;

  void initState() {
    userNameController = TextEditingController();
    photoUrlController = TextEditingController();
    postUrlController = TextEditingController();

    super.initState();

    Fetchprofile();
    Fetchpost();

  }

  Fetchprofile() async{
    print("pust");
    docSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get();
    photoUrlController.text = docSnap.data['photoURL'];
    userNameController.text = docSnap.data['displayName'];
    setState(() {
      userName = userNameController.text;
      photoUrl = photoUrlController.text;
      //cloading[index] = true;
    });
  }

  Fetchpost() async{
    docSnap = await FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .get();
    postUrlController.text = docSnap.data['url'];
    setState(() {
      postUrl = postUrlController.text;
      // cdisplayName[index] = cdisplayNameController.text;
      // cloading[index] = true;
    });
  }


  String tAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "y" : "y"}";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "m" : "m"}";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "w" : "w"}";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "d" : "d"} ";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "h" : "h"} ";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "m" : "m"} ";
    return "just now";
  }

  @override
  Widget build(BuildContext) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return (widget.status == "Follow")?Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OtherUserProfile(displayName: userName, uid: widget.userId)),
                );
              },
            child: Container(
              //width: 320.0,
              width: deviceWidth*1,
              child: ListTile(
                title: (userName != null || widget.comment != null)?Row(
                  children: [
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.start,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: (userName == null)?"loading...":userName,
                              style: TextStyle(fontSize: 15.0, color: Colors.black,fontWeight: FontWeight.bold,),
                            ),
                            TextSpan(
                              text: " started following you ",
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                  fontSize: 15.0),
                            ),
                            TextSpan(
                              text: tAgo(widget.timestamp.toDate()),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),

                      ),
                    )
                  ],
                ):Text(""),
                leading: (userName != null || widget.comment != null)?CircleAvatar(
                  backgroundImage: (photoUrl == null)?NetworkImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAM1BMVEXk5ueutLfn6eqrsbTp6+zg4uOwtrnJzc/j5earsbW0uby4vcDQ09XGyszU19jd3+G/xMamCvwDAAAFLklEQVR4nO2d2bLbIAxAbYE3sDH//7WFbPfexG4MiCAcnWmnrzkjIRaD2jQMwzAMwzAMwzAMwzAMwzAMwzAMwzAMwzAMwzAMw5wQkHJczewxZh2lhNK/CBOQo1n0JIT74/H/qMV0Z7GU3aCcVPuEE1XDCtVLAhgtpme7H0s1N1U7QjO0L8F7llzGeh1hEG/8Lo7TUmmuSrOfns9xnGXpXxsONPpA/B6OqqstjC6Ax/0ujkNdYQQbKNi2k64qiiEZ+ohi35X+2YcZw/WujmslYewiAliVYrxgJYrdwUmwXsU+RdApUi83oNIE27YvrfB/ZPg8+BJETXnqh9CVzBbTQHgojgiCvtqU9thFJg/CKz3VIMKMEkIXxIWqIpIg2SkjYj+xC816mrJae2aiWGykxRNsW0UwiJghJDljYI5CD8GRiCtIsJxizYUPQ2pzItZy5pcisTRdk/a9m4amtNNfBuQkdVhSaYqfpNTSFGfb9GRIakrE2Pm+GFLaCQPqiu0OpWP+HMPQQcgQMiQprWXNmsVwIjQjYi/ZrhAqNTCgr2gu0Jnz85RSSjso0HkMFZ0YZjKkc26a/jlmh9JiDyDxi9oeorTYAzZkwwoMz19pzj9bnH/GP/+qbchjSGflneWYhtTuKdMOmNKZcJ5TjInQKcYXnESd/jQxy0ENpULTNGOGgxpap/oyw9pbUAqhfx2Dbkhovvfgz4iUzoM9+GlK6/Mh4q29hyC1mwro30hpVVLPF9wYQr71RazOeM5/cw81iBRD+A03aM9/C/obbrKjbYSpCmIVG3qT/Q8oeUo3Rz0IL7vI1tEbCB9pSiu8I/aV8x3Kg/BGWrWp4ZVs0nZfmAoEG4h/61yHYIJiFSl6Q0Vk6tTW1N8kYp8hdOkfHYYMXd2Qft+8CYwqYDSKvqIh+MCF8Wgca2u/cwdgeW3TtuVn6+1oBs3yLo5C2JpK6CvQzGpfUkz9UG/87gCsi5o2LIXolxN0FbwAsjOLEr+YJmXn7iR6N0BCt5p5cMxm7eAsfS+/CACQf4CTpKjzgkvr2cVarVTf96372yut7XLJ1sa7lv6VcfgYrWaxqr3Wlo1S6pvStr22sxOtTNPLzdY3nj20bPP+ejFdJYkLsjGLdtPBEbe/mr2bQKiXWJDroA+vtzc0p9aahuwqHMDYrQEXHEw9jwQl3drMpts9JBU1SdktPe5FBRdJQ6bwXBpa57ib2A8kukQDzMjh++Uo7Fo6Wd02Pkf4fknqoo4HtvAIjsqUcjx6DIPgWCaOML9rKI/oqD9/lgNrn+eF+p7j8tnzHBiR7+kdUGw/+V1Kzkc75mMy6U+FMaxjPibiM1U1uGM+puInHpmALZCgP4pt7i840MV8+0R1zPsRB6UTcqpizncYwZ89syDydfyWCwXB1l8/zRNGWbTG/GHKUm9AkxHMc/EGSk3z2+ArEhPEV5TUBLEvUGFcjEUH80J/jveTGOAJEljJbILWGQT3zRYiwuKsUXN1EEJAzBhRJFll7mBUG7KD8EqPkKekBREaL8hMDZLQSG6AQjtHPYmvTQnX0TtpC1SYCe2YdkkyLP3jj5BSbKiuR585eQhTgoje6yIb0Yb0C+mV6EYvebqw5SDy2WmubogZiF2AVxPC2FpDf8H2Q9QWo6IkjUxTWVEI3WY/wrCeSuqJ+eRWzXR/JXwgVjUMozbCOfoEZiSiKVGepqv5CJ8RyR4D7xBeamqa7z3BJ/z17JxuBPdv93d/a2Ki878MMAzDMAzDMAzDMAzDMF/KP09VUmxBAiI3AAAAAElFTkSuQmCC"):CachedNetworkImageProvider(photoUrl),
                ):null,
                //subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
              ),
            ),
                ),
            // Container(
            //     child: Image.network(url)
            // ),
          ],
        ),
        // Divider(
        //   thickness: 1,
        //   color: Colors.grey,
        //   indent: 15,
        //   endIndent: 15,
        // ),
      ],
    ):Container();
  }
}

//notoification of share tab

class NotificationShare extends StatefulWidget {
  final String userId;
  final String comment;
  final Timestamp timestamp;
  final String status;
  final String commentId;
  final String notificationId;
  final int likes;
  final String postId;

  NotificationShare({this.postId,this.userId,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

  factory NotificationShare.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationShare(
      userId: documentSnapshot["uid"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
      status: documentSnapshot["status"],
      commentId: documentSnapshot["commentId"],
      notificationId: documentSnapshot["notificationId"],
      likes: documentSnapshot["likes"],
      postId: documentSnapshot["postId"],

    );
  }

  @override
  _NotificationShareState createState() => _NotificationShareState();
}

class _NotificationShareState extends State<NotificationShare> {

  DocumentSnapshot docSnap;
  String userName;
  String postUrl;
  String photoUrl;
  String displayNameCurrUser;
  String currUid;

  TextEditingController userNameController,photoUrlController,postUrlController;

  void initState() {
    userNameController = TextEditingController();
    photoUrlController = TextEditingController();
    postUrlController = TextEditingController();

    super.initState();

    Fetchprofile();
    Fetchpost();
    getCurrUid();

  }
  getCurrUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currUid = prefs.getString("currUid");
    displayNameCurrUser = prefs.getString("displayNameCurrUser");

    print("abab");
    print(currUid);
  }

  Fetchprofile() async{
    print("pust");
    docSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get();
    photoUrlController.text = docSnap.data['photoURL'];
    userNameController.text = docSnap.data['displayName'];
    setState(() {
      userName = userNameController.text;
      photoUrl = photoUrlController.text;
      //cloading[index] = true;
    });
  }

  Fetchpost() async{
    docSnap = await FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .get();
    postUrlController.text = docSnap.data['url'];
    setState(() {
      postUrl = postUrlController.text;
      // cdisplayName[index] = cdisplayNameController.text;
      // cloading[index] = true;
    });
  }


  String tAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "y" : "y"} ";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "mo" : "mo"} ";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "w" : "w"} ";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "d" : "d"} ";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "h" : "h"} ";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "m" : "m"} ";
    return "just now";
  }

  @override
  Widget build(BuildContext) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return (widget.status == "Share")?Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OtherUserProfile(displayName: userName, uid: widget.userId)),
                );
              },
              child: Container(
                width: deviceWidth*0.8,
                child: ListTile(
                  title: (userName != null || widget.comment != null)?Row(
                    children: [
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.start,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: (userName == null)?"loading...":userName,
                                style: TextStyle(fontSize: 15.0, color: Colors.black,fontWeight: FontWeight.bold,),
                              ),
                              TextSpan(
                                text: " shared your post ",
                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                    fontSize: 15.0),
                              ),
                              TextSpan(
                                text: tAgo(widget.timestamp.toDate()),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                        ),
                      )
                    ],
                  ):Text(""),
                  leading: (userName != null || widget.comment != null)?CircleAvatar(
                    backgroundImage: (photoUrl == null)?NetworkImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAM1BMVEXk5ueutLfn6eqrsbTp6+zg4uOwtrnJzc/j5earsbW0uby4vcDQ09XGyszU19jd3+G/xMamCvwDAAAFLklEQVR4nO2d2bLbIAxAbYE3sDH//7WFbPfexG4MiCAcnWmnrzkjIRaD2jQMwzAMwzAMwzAMwzAMwzAMwzAMwzAMwzAMwzAMw5wQkHJczewxZh2lhNK/CBOQo1n0JIT74/H/qMV0Z7GU3aCcVPuEE1XDCtVLAhgtpme7H0s1N1U7QjO0L8F7llzGeh1hEG/8Lo7TUmmuSrOfns9xnGXpXxsONPpA/B6OqqstjC6Ax/0ujkNdYQQbKNi2k64qiiEZ+ohi35X+2YcZw/WujmslYewiAliVYrxgJYrdwUmwXsU+RdApUi83oNIE27YvrfB/ZPg8+BJETXnqh9CVzBbTQHgojgiCvtqU9thFJg/CKz3VIMKMEkIXxIWqIpIg2SkjYj+xC816mrJae2aiWGykxRNsW0UwiJghJDljYI5CD8GRiCtIsJxizYUPQ2pzItZy5pcisTRdk/a9m4amtNNfBuQkdVhSaYqfpNTSFGfb9GRIakrE2Pm+GFLaCQPqiu0OpWP+HMPQQcgQMiQprWXNmsVwIjQjYi/ZrhAqNTCgr2gu0Jnz85RSSjso0HkMFZ0YZjKkc26a/jlmh9JiDyDxi9oeorTYAzZkwwoMz19pzj9bnH/GP/+qbchjSGflneWYhtTuKdMOmNKZcJ5TjInQKcYXnESd/jQxy0ENpULTNGOGgxpap/oyw9pbUAqhfx2Dbkhovvfgz4iUzoM9+GlK6/Mh4q29hyC1mwro30hpVVLPF9wYQr71RazOeM5/cw81iBRD+A03aM9/C/obbrKjbYSpCmIVG3qT/Q8oeUo3Rz0IL7vI1tEbCB9pSiu8I/aV8x3Kg/BGWrWp4ZVs0nZfmAoEG4h/61yHYIJiFSl6Q0Vk6tTW1N8kYp8hdOkfHYYMXd2Qft+8CYwqYDSKvqIh+MCF8Wgca2u/cwdgeW3TtuVn6+1oBs3yLo5C2JpK6CvQzGpfUkz9UG/87gCsi5o2LIXolxN0FbwAsjOLEr+YJmXn7iR6N0BCt5p5cMxm7eAsfS+/CACQf4CTpKjzgkvr2cVarVTf96372yut7XLJ1sa7lv6VcfgYrWaxqr3Wlo1S6pvStr22sxOtTNPLzdY3nj20bPP+ejFdJYkLsjGLdtPBEbe/mr2bQKiXWJDroA+vtzc0p9aahuwqHMDYrQEXHEw9jwQl3drMpts9JBU1SdktPe5FBRdJQ6bwXBpa57ib2A8kukQDzMjh++Uo7Fo6Wd02Pkf4fknqoo4HtvAIjsqUcjx6DIPgWCaOML9rKI/oqD9/lgNrn+eF+p7j8tnzHBiR7+kdUGw/+V1Kzkc75mMy6U+FMaxjPibiM1U1uGM+puInHpmALZCgP4pt7i840MV8+0R1zPsRB6UTcqpizncYwZ89syDydfyWCwXB1l8/zRNGWbTG/GHKUm9AkxHMc/EGSk3z2+ArEhPEV5TUBLEvUGFcjEUH80J/jveTGOAJEljJbILWGQT3zRYiwuKsUXN1EEJAzBhRJFll7mBUG7KD8EqPkKekBREaL8hMDZLQSG6AQjtHPYmvTQnX0TtpC1SYCe2YdkkyLP3jj5BSbKiuR585eQhTgoje6yIb0Yb0C+mV6EYvebqw5SDy2WmubogZiF2AVxPC2FpDf8H2Q9QWo6IkjUxTWVEI3WY/wrCeSuqJ+eRWzXR/JXwgVjUMozbCOfoEZiSiKVGepqv5CJ8RyR4D7xBeamqa7z3BJ/z17JxuBPdv93d/a2Ki878MMAzDMAzDMAzDMAzDMF/KP09VUmxBAiI3AAAAAElFTkSuQmCC"):CachedNetworkImageProvider(photoUrl),
                  ):null,
                  //subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
                ),
              ),
            ),
            (postUrl == null)?Container():GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => postPage(displayNamecurrentUser: displayNameCurrUser,PostUrl: postUrl,uidX: currUid,delete: false,)),
                );
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top:8.0,bottom: 15.0,right: 30.0),
                  child: Container(
                      height: 40,
                      width: 40.0,
                      child: CachedNetworkImage(imageUrl:postUrl)
                  ),
                ),
              ),
            ),
            // Container(
            //     child: Image.network(url)
            // ),
          ],
        ),
      ],
    ):Container();
  }
}

//notification of comment tab

class NotificationComment extends StatefulWidget {
  final String userId;
  final String comment;
  final Timestamp timestamp;
  final String status;
  final String commentId;
  final String notificationId;
  final int likes;
  final String postId;

  NotificationComment({this.postId,this.userId,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

  factory NotificationComment.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationComment(
      userId: documentSnapshot["uid"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
      status: documentSnapshot["status"],
      commentId: documentSnapshot["commentId"],
      notificationId: documentSnapshot["notificationId"],
      likes: documentSnapshot["likes"],
      postId: documentSnapshot["postId"],
    );
  }

  @override
  _NotificationCommentState createState() => _NotificationCommentState();
}

class _NotificationCommentState extends State<NotificationComment> {
  DocumentSnapshot docSnap;
  String userName;
  String postUrl;
  String photoUrl;
  String displayNamePostUser;
  String displayNameCurrUser;
  String currUid;

  TextEditingController userNameController,photoUrlController,postUrlController,displayNamePostUserController;

  void initState() {
    userNameController = TextEditingController();
    photoUrlController = TextEditingController();
    postUrlController = TextEditingController();
    displayNamePostUserController = TextEditingController();

    super.initState();

    Fetchprofile();
    Fetchpost();
    getCurrUid();

  }

  getCurrUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currUid = prefs.getString("currUid");
    displayNameCurrUser = prefs.getString("displayNameCurrUser");

    print("abab");
    print(currUid);
  }

  Fetchprofile() async{
    print("pust");
    docSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get();
    photoUrlController.text = docSnap.data['photoURL'];
    userNameController.text = docSnap.data['displayName'];
    setState(() {
      userName = userNameController.text;
      photoUrl = photoUrlController.text;
      //cloading[index] = true;
    });
  }

  Fetchpost() async{
    docSnap = await FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .get();
    postUrlController.text = docSnap.data['url'];
    displayNamePostUserController.text = docSnap.data['displayName'];
    setState(() {
      postUrl = postUrlController.text;
      displayNamePostUser = displayNamePostUserController.text;
      // cdisplayName[index] = cdisplayNameController.text;
      // cloading[index] = true;
    });
  }

  String tAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "y" : "y"} ";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "mo" : "mo"} ";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "w" : "w"}";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "d" : "d"} ";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "h" : "h"} ";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "m" : "m"} ";
    return "just now";
  }

  @override
  Widget build(BuildContext) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return (widget.status == "Comment")?Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => postPage(displayNamecurrentUser: displayNameCurrUser,PostUrl: postUrl,uidX: currUid,delete: false,)),
                );
              },
              child: Container(
                width: deviceWidth*0.8,
                child: ListTile(
                  title: (userName != null || widget.comment != null)?Row(
                    children: [
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.start,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: (userName == null)?"loading":userName,
                                style: TextStyle(fontSize: 15.0, color: Colors.black,fontWeight: FontWeight.bold,),
                              ),
                              TextSpan(
                                text: " commented: ",
                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                    fontSize: 15.0),
                              ),
                              TextSpan(
                                text: widget.comment,
                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                    fontSize: 15.0),
                              ),
                              TextSpan(
                                text: " " + tAgo(widget.timestamp.toDate()),
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                        ),
                      )
                    ],
                  ):Text(""),
                  leading: (userName != null || widget.comment != null)?CircleAvatar(
                    backgroundImage: (photoUrl == null)?NetworkImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAM1BMVEXk5ueutLfn6eqrsbTp6+zg4uOwtrnJzc/j5earsbW0uby4vcDQ09XGyszU19jd3+G/xMamCvwDAAAFLklEQVR4nO2d2bLbIAxAbYE3sDH//7WFbPfexG4MiCAcnWmnrzkjIRaD2jQMwzAMwzAMwzAMwzAMwzAMwzAMwzAMwzAMwzAMw5wQkHJczewxZh2lhNK/CBOQo1n0JIT74/H/qMV0Z7GU3aCcVPuEE1XDCtVLAhgtpme7H0s1N1U7QjO0L8F7llzGeh1hEG/8Lo7TUmmuSrOfns9xnGXpXxsONPpA/B6OqqstjC6Ax/0ujkNdYQQbKNi2k64qiiEZ+ohi35X+2YcZw/WujmslYewiAliVYrxgJYrdwUmwXsU+RdApUi83oNIE27YvrfB/ZPg8+BJETXnqh9CVzBbTQHgojgiCvtqU9thFJg/CKz3VIMKMEkIXxIWqIpIg2SkjYj+xC816mrJae2aiWGykxRNsW0UwiJghJDljYI5CD8GRiCtIsJxizYUPQ2pzItZy5pcisTRdk/a9m4amtNNfBuQkdVhSaYqfpNTSFGfb9GRIakrE2Pm+GFLaCQPqiu0OpWP+HMPQQcgQMiQprWXNmsVwIjQjYi/ZrhAqNTCgr2gu0Jnz85RSSjso0HkMFZ0YZjKkc26a/jlmh9JiDyDxi9oeorTYAzZkwwoMz19pzj9bnH/GP/+qbchjSGflneWYhtTuKdMOmNKZcJ5TjInQKcYXnESd/jQxy0ENpULTNGOGgxpap/oyw9pbUAqhfx2Dbkhovvfgz4iUzoM9+GlK6/Mh4q29hyC1mwro30hpVVLPF9wYQr71RazOeM5/cw81iBRD+A03aM9/C/obbrKjbYSpCmIVG3qT/Q8oeUo3Rz0IL7vI1tEbCB9pSiu8I/aV8x3Kg/BGWrWp4ZVs0nZfmAoEG4h/61yHYIJiFSl6Q0Vk6tTW1N8kYp8hdOkfHYYMXd2Qft+8CYwqYDSKvqIh+MCF8Wgca2u/cwdgeW3TtuVn6+1oBs3yLo5C2JpK6CvQzGpfUkz9UG/87gCsi5o2LIXolxN0FbwAsjOLEr+YJmXn7iR6N0BCt5p5cMxm7eAsfS+/CACQf4CTpKjzgkvr2cVarVTf96372yut7XLJ1sa7lv6VcfgYrWaxqr3Wlo1S6pvStr22sxOtTNPLzdY3nj20bPP+ejFdJYkLsjGLdtPBEbe/mr2bQKiXWJDroA+vtzc0p9aahuwqHMDYrQEXHEw9jwQl3drMpts9JBU1SdktPe5FBRdJQ6bwXBpa57ib2A8kukQDzMjh++Uo7Fo6Wd02Pkf4fknqoo4HtvAIjsqUcjx6DIPgWCaOML9rKI/oqD9/lgNrn+eF+p7j8tnzHBiR7+kdUGw/+V1Kzkc75mMy6U+FMaxjPibiM1U1uGM+puInHpmALZCgP4pt7i840MV8+0R1zPsRB6UTcqpizncYwZ89syDydfyWCwXB1l8/zRNGWbTG/GHKUm9AkxHMc/EGSk3z2+ArEhPEV5TUBLEvUGFcjEUH80J/jveTGOAJEljJbILWGQT3zRYiwuKsUXN1EEJAzBhRJFll7mBUG7KD8EqPkKekBREaL8hMDZLQSG6AQjtHPYmvTQnX0TtpC1SYCe2YdkkyLP3jj5BSbKiuR585eQhTgoje6yIb0Yb0C+mV6EYvebqw5SDy2WmubogZiF2AVxPC2FpDf8H2Q9QWo6IkjUxTWVEI3WY/wrCeSuqJ+eRWzXR/JXwgVjUMozbCOfoEZiSiKVGepqv5CJ8RyR4D7xBeamqa7z3BJ/z17JxuBPdv93d/a2Ki878MMAzDMAzDMAzDMAzDMF/KP09VUmxBAiI3AAAAAElFTkSuQmCC"):CachedNetworkImageProvider(photoUrl),
                  ):null,
                  //subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
                ),
              ),
            ),
            (postUrl == null)?Container():GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => postPage(displayNamecurrentUser: displayNameCurrUser,PostUrl: postUrl,uidX: currUid,delete: false,)),
                );
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top:8.0,bottom: 15.0,right: 30.0),
                  child: Container(
                      height: 40,
                      width: 40.0,
                      child: (postUrl == null)?Container():CachedNetworkImage(imageUrl:postUrl)
                  ),
                ),
              ),
            ),
            // Container(
            //     child: Image.network(url)
            // ),
          ],
        ),
        // Divider(
        //   thickness: 1,
        //   color: Colors.grey,
        //   indent: 15,
        //   endIndent: 15,
        // ),
      ],
    ):Container();
  }
}

//notification of like tab

class NotificationLike extends StatefulWidget {
  final String userId;
  final String comment;
  final Timestamp timestamp;
  final String status;
  final String commentId;
  final String notificationId;
  final int likes;
  final String postId;

  NotificationLike({this.postId,this.userId,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

  factory NotificationLike.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationLike(
      userId: documentSnapshot["uid"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
      status: documentSnapshot["status"],
      commentId: documentSnapshot["commentId"],
      notificationId: documentSnapshot["notificationId"],
      likes: documentSnapshot["likes"],
      postId: documentSnapshot["postId"],
    );
  }

  @override
  _NotificationLikeState createState() => _NotificationLikeState();
}

class _NotificationLikeState extends State<NotificationLike> {

  DocumentSnapshot docSnap;
  String userName;
  String postUrl;
  String photoUrl;
  String displayNamePostUser;
  String currUid;
  String displayNameCurrUser;

  TextEditingController userNameController,photoUrlController,postUrlController,displayNamePostUserController;

  void initState() {
    userNameController = TextEditingController();
    photoUrlController = TextEditingController();
    postUrlController = TextEditingController();
    displayNamePostUserController = TextEditingController();
    // setState(() async{
    //   SharedPreferences prefs = await SharedPreferences.getInstance();
    //   currUser = prefs.getString("currUser");
    // });

    super.initState();

    Fetchprofile();
    Fetchpost();
    getCurrUid();

  }

  getCurrUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currUid = prefs.getString("currUid");
    displayNameCurrUser = prefs.getString("displayNameCurrUser");

    print("abab");
    print(currUid);
  }

  Fetchprofile() async{
    print("pust");
    docSnap = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .get();
    photoUrlController.text = docSnap.data['photoURL'];
    userNameController.text = docSnap.data['displayName'];
    setState(() {
      userName = userNameController.text;
      photoUrl = photoUrlController.text;
      //cloading[index] = true;
    });
  }

  Fetchpost() async{
    docSnap = await FirebaseFirestore.instance
        .collection("posts")
        .doc(widget.postId)
        .get();
    postUrlController.text = docSnap.data['url'];
    displayNamePostUserController.text = docSnap['displayName'];
    setState(() {
      postUrl = postUrlController.text;
      displayNamePostUser = displayNamePostUserController.text;
      // cdisplayName[index] = cdisplayNameController.text;
      // cloading[index] = true;
    });
    print("dick");
    print(postUrl);
    print(displayNamePostUser);
    print(widget.userId);
    print(currUid);
    print(displayNameCurrUser);
  }


  String tAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "y" : "y"}";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "mo" : "mo"}";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "w" : "w"} ";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "d" : "d"}";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "h" : "h"}";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "m" : "m"}";
    return "just now";
  }

  @override
  Widget build(BuildContext) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return (widget.status == "like")?Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => OtherUserProfile(uid: widget.userId,displayName: userName)),
                );
              },
              child: Container(
                width: deviceWidth*0.80,
                child: ListTile(
                  title: (userName != null || widget.comment != null)?Row(
                    children: [
                      Expanded(
                        child: RichText(
                          textAlign: TextAlign.start,
                          softWrap: true,
                          overflow: TextOverflow.visible,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: (userName == null)?"loading":userName,
                                style: TextStyle(fontSize: 15.0, color: Colors.black,fontWeight: FontWeight.bold,),
                              ),
                              TextSpan(
                                text: " liked you photo. ",
                                style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                    fontSize: 15.0),
                              ),
                              TextSpan(
                                text: tAgo(widget.timestamp.toDate()),
                                  style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),

                        ),
                      )
                    ],
                  ):Text(""),
                  leading: (userName != null || widget.comment != null)?CircleAvatar(
                    backgroundImage: (photoUrl == null)?NetworkImage("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAM1BMVEXk5ueutLfn6eqrsbTp6+zg4uOwtrnJzc/j5earsbW0uby4vcDQ09XGyszU19jd3+G/xMamCvwDAAAFLklEQVR4nO2d2bLbIAxAbYE3sDH//7WFbPfexG4MiCAcnWmnrzkjIRaD2jQMwzAMwzAMwzAMwzAMwzAMwzAMwzAMwzAMwzAMw5wQkHJczewxZh2lhNK/CBOQo1n0JIT74/H/qMV0Z7GU3aCcVPuEE1XDCtVLAhgtpme7H0s1N1U7QjO0L8F7llzGeh1hEG/8Lo7TUmmuSrOfns9xnGXpXxsONPpA/B6OqqstjC6Ax/0ujkNdYQQbKNi2k64qiiEZ+ohi35X+2YcZw/WujmslYewiAliVYrxgJYrdwUmwXsU+RdApUi83oNIE27YvrfB/ZPg8+BJETXnqh9CVzBbTQHgojgiCvtqU9thFJg/CKz3VIMKMEkIXxIWqIpIg2SkjYj+xC816mrJae2aiWGykxRNsW0UwiJghJDljYI5CD8GRiCtIsJxizYUPQ2pzItZy5pcisTRdk/a9m4amtNNfBuQkdVhSaYqfpNTSFGfb9GRIakrE2Pm+GFLaCQPqiu0OpWP+HMPQQcgQMiQprWXNmsVwIjQjYi/ZrhAqNTCgr2gu0Jnz85RSSjso0HkMFZ0YZjKkc26a/jlmh9JiDyDxi9oeorTYAzZkwwoMz19pzj9bnH/GP/+qbchjSGflneWYhtTuKdMOmNKZcJ5TjInQKcYXnESd/jQxy0ENpULTNGOGgxpap/oyw9pbUAqhfx2Dbkhovvfgz4iUzoM9+GlK6/Mh4q29hyC1mwro30hpVVLPF9wYQr71RazOeM5/cw81iBRD+A03aM9/C/obbrKjbYSpCmIVG3qT/Q8oeUo3Rz0IL7vI1tEbCB9pSiu8I/aV8x3Kg/BGWrWp4ZVs0nZfmAoEG4h/61yHYIJiFSl6Q0Vk6tTW1N8kYp8hdOkfHYYMXd2Qft+8CYwqYDSKvqIh+MCF8Wgca2u/cwdgeW3TtuVn6+1oBs3yLo5C2JpK6CvQzGpfUkz9UG/87gCsi5o2LIXolxN0FbwAsjOLEr+YJmXn7iR6N0BCt5p5cMxm7eAsfS+/CACQf4CTpKjzgkvr2cVarVTf96372yut7XLJ1sa7lv6VcfgYrWaxqr3Wlo1S6pvStr22sxOtTNPLzdY3nj20bPP+ejFdJYkLsjGLdtPBEbe/mr2bQKiXWJDroA+vtzc0p9aahuwqHMDYrQEXHEw9jwQl3drMpts9JBU1SdktPe5FBRdJQ6bwXBpa57ib2A8kukQDzMjh++Uo7Fo6Wd02Pkf4fknqoo4HtvAIjsqUcjx6DIPgWCaOML9rKI/oqD9/lgNrn+eF+p7j8tnzHBiR7+kdUGw/+V1Kzkc75mMy6U+FMaxjPibiM1U1uGM+puInHpmALZCgP4pt7i840MV8+0R1zPsRB6UTcqpizncYwZ89syDydfyWCwXB1l8/zRNGWbTG/GHKUm9AkxHMc/EGSk3z2+ArEhPEV5TUBLEvUGFcjEUH80J/jveTGOAJEljJbILWGQT3zRYiwuKsUXN1EEJAzBhRJFll7mBUG7KD8EqPkKekBREaL8hMDZLQSG6AQjtHPYmvTQnX0TtpC1SYCe2YdkkyLP3jj5BSbKiuR585eQhTgoje6yIb0Yb0C+mV6EYvebqw5SDy2WmubogZiF2AVxPC2FpDf8H2Q9QWo6IkjUxTWVEI3WY/wrCeSuqJ+eRWzXR/JXwgVjUMozbCOfoEZiSiKVGepqv5CJ8RyR4D7xBeamqa7z3BJ/z17JxuBPdv93d/a2Ki878MMAzDMAzDMAzDMAzDMF/KP09VUmxBAiI3AAAAAElFTkSuQmCC"):CachedNetworkImageProvider(photoUrl),
                  ):null,
                 // subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
                ),
              ),
            ),
            (postUrl == null)?Container():GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => postPage(displayNamecurrentUser: displayNameCurrUser,PostUrl: postUrl,uidX: currUid,delete: false,)),
                );
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top:8.0,bottom: 15.0,right: 30.0),
                  child: Container(
                    height: 40,
                      width: 40.0,
                      child: CachedNetworkImage(imageUrl:postUrl)
                  ),
                ),
              ),
            ),
          ],
        ),
        // Divider(
        //   thickness: 1,
        //   color: Colors.grey,
        //   indent: 15,
        //   endIndent: 15,
        // ),
      ],
    ):Container();
  }
}

class TBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // boxShadow: [
        //   new BoxShadow(blurRadius: 10.0)
        // ],
        color: Colors.white,
        //borderRadius: BorderRadius.circular(50),
        border: Border.all(
            color: Colors.white,
            width: 5.0
        ),
      ),
      child: TabBar(
        labelColor: Colors.white,
        //indicatorColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          color: Colors.grey[300],
        ),
        tabs: [
          Tab(
            icon: Icon(
              Icons.thumb_up,
              color: Colors.deepPurple,
              size: 24.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
          ),
          Tab(
            icon: Icon(
              Icons.comment_rounded,
              color: Colors.deepPurple,
              size: 24.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
          ),
          Tab(
            icon: Icon(
              FontAwesomeIcons.shareAlt,
              color: Colors.deepPurple,
              size: 24.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
          ),
          Tab(
            icon: Icon(
              FontAwesomeIcons.userPlus,
              color: Colors.deepPurple,
              size: 24.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
          )
        ],
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize {
    return Size.fromHeight(200.0);
  }
}
