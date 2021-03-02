import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

final NotificationRefrence = Firestore.instance.collection("users");

class NotificationsPage extends StatefulWidget{
  final String currUid;


  NotificationsPage({this.currUid,});

  @override
  NotificationsPageState createState() => NotificationsPageState(currUid: currUid,);
}

class NotificationsPageState extends State<NotificationsPage> {
  final String currUid;
  final GlobalKey<FormState> _CommentKey = GlobalKey<FormState>();

  String CommentId = Uuid().v4();
  String NotificationId = Uuid().v4();

  TextEditingController commentTextEditingController = TextEditingController();

  NotificationsPageState({this.currUid,});
  // return Firestore.instance
  //     .collection("posts")
  //     .orderBy("timestamp", descending: true)
  //     .snapshots();

  retrieveNotificationsLike(){
     print("bhujm");
     print(currUid);
    return  StreamBuilder(
      stream: NotificationRefrence.document(currUid)
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
      stream: NotificationRefrence.document(currUid)
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
      stream: NotificationRefrence.document(currUid)
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
      stream: NotificationRefrence.document(currUid)
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


  @override
  void initState() {

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

class NotificationFollow extends StatelessWidget {
  final String userName;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  final String status;
  final String commentId;
  final String notificationId;
  final int likes;
  final String postUrl;

  NotificationFollow({this.userName,this.userId,this.postUrl,this.url,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

  factory NotificationFollow.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationFollow(
      userName: documentSnapshot["username"],
      userId: documentSnapshot["uid"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
      status: documentSnapshot["status"],
      commentId: documentSnapshot["commentId"],
      notificationId: documentSnapshot["notificationId"],
      likes: documentSnapshot["likes"],
      postUrl: documentSnapshot["postUrl"],

    );
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
    return (status == "Follow")?Column(
      children: [
        Stack(
          children: [
            Container(
              //width: 320.0,
              child: ListTile(
                title: (userName != null || comment != null)?Row(
                  children: [
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.start,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: userName,
                              style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.bold,),
                            ),
                            TextSpan(
                              text: "  started following you",
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                  fontSize: 15.0),
                            ),
                            TextSpan(
                              text: " " +tAgo(timestamp.toDate()),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),

                      ),
                    )
                  ],
                ):Text(""),
                leading: (userName != null || comment != null)?CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(url),
                ):null,
                //subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
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

class NotificationShare extends StatelessWidget {
  final String userName;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  final String status;
  final String commentId;
  final String notificationId;
  final int likes;
  final String postUrl;

  NotificationShare({this.userName,this.userId,this.postUrl,this.url,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

  factory NotificationShare.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationShare(
      userName: documentSnapshot["username"],
      userId: documentSnapshot["uid"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
      status: documentSnapshot["status"],
      commentId: documentSnapshot["commentId"],
      notificationId: documentSnapshot["notificationId"],
      likes: documentSnapshot["likes"],
      postUrl: documentSnapshot["postUrl"],

    );
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
    return (status == "Share")?Column(
      children: [
        Stack(
          children: [
            Container(
              width: 320,
              child: ListTile(
                title: (userName != null || comment != null)?Row(
                  children: [
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.start,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: userName + " ",
                              style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.bold,),
                            ),
                            TextSpan(
                              text: "shared your post",
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                  fontSize: 15.0),
                            ),
                            TextSpan(
                              text: " " +tAgo(timestamp.toDate()),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),

                      ),
                    )
                  ],
                ):Text(""),
                leading: (userName != null || comment != null)?CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(url),
                ):null,
                //subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
              ),
            ),
            (postUrl == null)?Container():Align(
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
    docSnap = await Firestore.instance
        .collection("users")
        .document(widget.userId)
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
    docSnap = await Firestore.instance
        .collection("posts")
        .document(widget.postId)
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
    return (widget.status == "Comment")?Column(
      children: [
        Stack(
          children: [
            Container(
              width: 320.0,
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
                              text: userName,
                              style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.bold,),
                            ),
                            TextSpan(
                              text: " commented on your post",
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                  fontSize: 15.0),
                            ),
                            TextSpan(
                              text: " " +tAgo(widget.timestamp.toDate()),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),

                      ),
                    )
                  ],
                ):Text(""),
                leading: (userName != null || widget.comment != null)?CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(photoUrl),
                ):null,
                //subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
              ),
            ),
            (postUrl == null)?Container():Align(
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

class NotificationLike extends StatelessWidget {
  final String userName;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  final String status;
  final String commentId;
  final String notificationId;
  final int likes;
  final String postUrl;

  NotificationLike({this.userName,this.userId,this.postUrl,this.url,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

  factory NotificationLike.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationLike(
      userName: documentSnapshot["username"],
      userId: documentSnapshot["uid"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
      status: documentSnapshot["status"],
      commentId: documentSnapshot["commentId"],
      notificationId: documentSnapshot["notificationId"],
      likes: documentSnapshot["likes"],
      postUrl: documentSnapshot["postUrl"],
    );
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
    return (status == "like")?Column(
      children: [
        Stack(
          children: [
            Container(
              //color: Colors.red,
              width: 320.0,
              child: ListTile(
                title: (userName != null || comment != null)?Row(
                  children: [
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.start,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: userName + " ",
                              style: TextStyle(fontSize: 15.0, color: Colors.black,fontWeight: FontWeight.bold,),
                            ),
                            TextSpan(
                              text: "liked you photo.",
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                  fontSize: 15.0),
                            ),
                            TextSpan(
                              text: " " +tAgo(timestamp.toDate()),
                                style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),

                      ),
                    )
                  ],
                ):Text(""),
                leading: (userName != null || comment != null)?CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(url),
                ):null,
               // subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
              ),
            ),
            (postUrl == null)?Container():Align(
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
              Icons.share,
              color: Colors.deepPurple,
              size: 24.0,
              semanticLabel: 'Text to announce in accessibility modes',
            ),
          ),
          Tab(
            icon: Icon(
              Icons.person,
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
