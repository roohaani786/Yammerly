import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/utils/utils.dart';

class NotificationsPage extends StatefulWidget {
  final String currUid;

  NotificationsPage({this.currUid});


  @override
  _NotificationsPageState createState() => _NotificationsPageState(currUid: currUid);
}

class _NotificationsPageState extends State<NotificationsPage> {
  final String currUid;
  _NotificationsPageState({this.currUid});

  void _onHorizontalDrag(DragEndDetails details) {
    if (details.primaryVelocity == 0)
      // user have just tapped on screen (no dragging)
      return;

    if (details.primaryVelocity.compareTo(0) == -1) {
//      dispose();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 4)),
      );
    }
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage(initialindexg: 2)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;

    final pageTitle = Padding(
      padding: EdgeInsets.only(top: 1.0, bottom: 30.0),
      child: Text(
        "Notifications",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontSize: 40.0,
        ),
      ),
    );

    final image = Image.asset(
      AvailableImages.emptyState['assetPath'],
    );

    final notificationHeader = Container(
      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
      child: Text(
        "Coming Soon....",
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 24.0),
      ),
    );
    final notificationText = Text(
      "Notification feature is coming soon on our app.",
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        color: Colors.grey.withOpacity(0.6),
      ),
      textAlign: TextAlign.center,
    );

    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) =>
          _onHorizontalDrag(details),
      onTap: () =>null,
      child: Scaffold(
        // resizeToAvoidBottomPadding: false,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              top: 30.0,
              left: 30.0,
              right: 30.0,
              bottom: 30.0,
            ),
            height: deviceHeight,
            width: deviceWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                pageTitle,
                SizedBox(
                  height: deviceHeight * 0.1,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    image,
                    notificationHeader,
                    notificationText,
                    Expanded(
                      child: retrieveNotification(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  retrieveNotification(){
    //print("user");
    //print(displayNamecurrentUser);
    return  StreamBuilder(
      stream: Firestore.instance.collection("users").document(currUid)
          .collection("notification")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, dataSnapshot){
        if (!dataSnapshot.hasData){
          return Container(
            color: Colors.white,
          );
        }
        List<Notification> notifications = [];
        dataSnapshot.data.documents.forEach((document){
          notifications.add(Notification.fromDocument(document));
        });
        return ListView(
          children: notifications,
        );
      },
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

  Notification({this.userName,this.userId,this.url,this.comment,this.timestamp,this.status});

  factory Notification.fromDocument(DocumentSnapshot documentSnapshot){
    return Notification(
      status: documentSnapshot["status"],
      userName: documentSnapshot["username"],
      userId: documentSnapshot["uid"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],

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
                            text: status + "your post",
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
