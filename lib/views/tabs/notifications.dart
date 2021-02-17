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





  retrieveNotifications(){
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
        List<Notification> Notifications = [];
        dataSnapshot.data.documents.forEach((document){
          Notifications.add(Notification.fromDocument(document));
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

  // CommentCount() async {
  //   return StreamBuilder(
  //     stream: CommentsRefrence.document(postId)
  //         .snapshots(),
  //     builder: (context, dataSnapshot) {
  //        commentCount = 'comments';
  //       }


  //   );
  // }


  @override
  void initState() {

    retrieveNotifications();

  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
        backgroundColor: Colors.white,

        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   title: Text("Notifications", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.normal),),
        //   // leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.black,), onPressed: (){
        //   //   Navigator.pop(context);
        //   // }),
        // ),
        //appBar: header(context, strTitle: "Comments"),

        body: Column(
          children: [
            Expanded(
              child: retrieveNotifications(),
            ),
          ],
        )

    );
  }
}

class Notification extends StatelessWidget {
  final String userName;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  final String status;
  final String commentId;
  final String notificationId;
  final int likes;

  Notification({this.userName,this.userId,this.url,this.comment,this.timestamp,this.status,this.commentId,this.notificationId,this.likes});

  factory Notification.fromDocument(DocumentSnapshot documentSnapshot){
    return Notification(
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
    return Padding(
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
//                      Text(userName + " :",style: TextStyle(fontSize: 18.0,color: Colors.black,
//                        fontWeight: FontWeight.bold,),),
//                      Padding(
//                        padding: const EdgeInsets.only(left: 2.0),
//                        child: Expanded(
//                          //width: 170.0,
//                          child: SizedBox(
//                            width: 108.0,
//                            child: Text(comment,style: TextStyle(fontSize: 15.0,color: Colors.black,
//                            ),),
//                          ),
//                        ),
//                      ),
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

    );
  }
}





// import 'package:flutter/material.dart';
//
// import 'package:techstagram/utils/utils.dart';
//
// class NotificationsPage extends StatefulWidget {
//
//
//   @override
//   _NotificationsPageState createState() => _NotificationsPageState();
// }
//
// class _NotificationsPageState extends State<NotificationsPage> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     final deviceHeight = MediaQuery.of(context).size.height;
//     final deviceWidth = MediaQuery.of(context).size.width;
//
//     final pageTitle = Padding(
//       padding: EdgeInsets.only(top: 1.0, bottom: 30.0),
//       child: Text(
//         "Notifications",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//           fontSize: 40.0,
//         ),
//       ),
//     );
//
//     final image = Image.asset(
//       AvailableImages.emptyState['assetPath'],
//     );
//
//     final notificationHeader = Container(
//       padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
//       child: Text(
//         "Coming Soon....",
//         style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
//       ),
//     );
//     final notificationText = Text(
//       "Notification feature is coming soon on our app.",
//       style: TextStyle(
//         fontWeight: FontWeight.w600,
//         fontSize: 16.0,
//         color: Colors.grey.withOpacity(0.6),
//       ),
//       textAlign: TextAlign.center,
//     );
//
//     return Scaffold(
//       // resizeToAvoidBottomPadding: false,
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.only(
//             top: 30.0,
//             left: 30.0,
//             right: 30.0,
//             bottom: 30.0,
//           ),
//           height: deviceHeight,
//           width: deviceWidth,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               pageTitle,
//               SizedBox(
//                 height: deviceHeight * 0.1,
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   image,
//                   notificationHeader,
//                   notificationText
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
//
// import 'package:techstagram/utils/utils.dart';
//
// class NotificationsPage extends StatefulWidget {
//
//
//   @override
//   _NotificationsPageState createState() => _NotificationsPageState();
// }
//
// class _NotificationsPageState extends State<NotificationsPage> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     final deviceHeight = MediaQuery.of(context).size.height;
//     final deviceWidth = MediaQuery.of(context).size.width;
//
//     final pageTitle = Padding(
//       padding: EdgeInsets.only(top: 1.0, bottom: 30.0),
//       child: Text(
//         "Notifications",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//           fontSize: 40.0,
//         ),
//       ),
//     );
//
//     final image = Image.asset(
//       AvailableImages.emptyState['assetPath'],
//     );
//
//     final notificationHeader = Container(
//       padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
//       child: Text(
//         "Coming Soon....",
//         style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
//       ),
//     );
//     final notificationText = Text(
//       "Notification feature is coming soon on our app.",
//       style: TextStyle(
//         fontWeight: FontWeight.w600,
//         fontSize: 16.0,
//         color: Colors.grey.withOpacity(0.6),
//       ),
//       textAlign: TextAlign.center,
//     );
//
//     return Scaffold(
//       // resizeToAvoidBottomPadding: false,
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.only(
//             top: 30.0,
//             left: 30.0,
//             right: 30.0,
//             bottom: 30.0,
//           ),
//           height: deviceHeight,
//           width: deviceWidth,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               pageTitle,
//               SizedBox(
//                 height: deviceHeight * 0.1,
//               ),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   image,
//                   notificationHeader,
//                   notificationText
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
