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

  NotificationFollow({this.userName,this.userId,this.url,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

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

    );
  }

  String tAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "just now";
  }

  @override
  Widget build(BuildContext) {
    return (status == "Follow")?Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(

        color: Colors.white,

        child: Stack(
          children: [
            ListTile(
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
                            text: userName + " :  ",
                            style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.bold,),
                          ),
                          TextSpan(
                            text: status,
                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                fontSize: 15.0),
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
              subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
            ),
          ],
        ),

      ),

    ):Container();
  }
}

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

  NotificationShare({this.userName,this.userId,this.url,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

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

    );
  }

  String tAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "just now";
  }

  @override
  Widget build(BuildContext) {
    return (status == "Share")?Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(

        color: Colors.white,

        child: Stack(
          children: [
            ListTile(
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
                            text: userName + " :  ",
                            style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.bold,),
                          ),
                          TextSpan(
                            text: status,
                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                fontSize: 15.0),
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
              subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
            ),
          ],
        ),

      ),

    ):Container();
  }
}

class NotificationComment extends StatelessWidget {
  final String userName;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  final String status;
  final String commentId;
  final String notificationId;
  final int likes;

  NotificationComment({this.userName,this.userId,this.url,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

  factory NotificationComment.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationComment(
      userName: documentSnapshot["username"],
      userId: documentSnapshot["uid"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
      status: documentSnapshot["status"],
      commentId: documentSnapshot["commentId"],
      notificationId: documentSnapshot["notificationId"],
      likes: documentSnapshot["likes"],

    );
  }

  String tAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "just now";
  }

  @override
  Widget build(BuildContext) {
    return (status == "Comment")?Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(

        color: Colors.white,

        child: Stack(
          children: [
            ListTile(
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
                            text: userName + " :  ",
                            style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.bold,),
                          ),
                          TextSpan(
                            text: status,
                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                fontSize: 15.0),
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
              subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
            ),
          ],
        ),

      ),

    ):Container();
  }
}

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

  NotificationLike({this.userName,this.userId,this.url,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

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

    );
  }

  String tAgo(DateTime d) {
    Duration diff = DateTime.now().difference(d);
    if (diff.inDays > 365)
      return "${(diff.inDays / 365).floor()} ${(diff.inDays / 365).floor() == 1 ? "year" : "years"} ago";
    if (diff.inDays > 30)
      return "${(diff.inDays / 30).floor()} ${(diff.inDays / 30).floor() == 1 ? "month" : "months"} ago";
    if (diff.inDays > 7)
      return "${(diff.inDays / 7).floor()} ${(diff.inDays / 7).floor() == 1 ? "week" : "weeks"} ago";
    if (diff.inDays > 0)
      return "${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago";
    if (diff.inHours > 0)
      return "${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago";
    if (diff.inMinutes > 0)
      return "${diff.inMinutes} ${diff.inMinutes == 1 ? "minute" : "minutes"} ago";
    return "just now";
  }

  @override
  Widget build(BuildContext) {
    return (status == "like")?Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(

        color: Colors.white,

        child: Stack(
          children: [
            ListTile(
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
                            text: userName + " :  ",
                            style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.bold,),
                          ),
                          TextSpan(
                            text: status,
                            style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                fontSize: 15.0),
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
              subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
            ),
          ],
        ),

      ),

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
