
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techstagram/services/database.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

final CommentsRefrence = FirebaseFirestore.instance.collection("posts");

class CommentsPage extends StatefulWidget{
  final String postId;
  final String uid;
  final String postImageUrl;
  final Timestamp timestamp;
  final String displayName;
  final String photoUrl;
  final String displayNamecurrentUser;
  final int comments;
  final String currUser;


  CommentsPage({this.currUser,this.comments,this.postId,this.uid,this.postImageUrl,this.timestamp,this.displayName,this.photoUrl,this.displayNamecurrentUser});

  @override
  CommentsPageState createState() => CommentsPageState(currUser: currUser,comments: comments,postId: postId, uid: uid, postImageUrl: postImageUrl,timestamp: timestamp,displayName: displayName,photoUrl: photoUrl,displayNamecurrentUser: displayNamecurrentUser);
}

class CommentsPageState extends State<CommentsPage> {
  final int comments;
  final String postId;
  final String uid;
  final String postImageUrl;
  final Timestamp timestamp;
  final String displayName;
  final String photoUrl;
  final String displayNamecurrentUser;
  final GlobalKey<FormState> _CommentKey = GlobalKey<FormState>();
  final String currUser;

  String CommentId = Uuid().v4();
  String NotificationId = Uuid().v4();

  TextEditingController commentTextEditingController = TextEditingController();

  CommentsPageState({this.currUser,this.comments,this.postId,this.uid,this.postImageUrl,this.timestamp,this.displayName,this.photoUrl,this.displayNamecurrentUser});


  SaveCurrUserId()
  async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currUserId', currUser);
  }  retrieveComments(){

    print("user");
    print(displayNamecurrentUser);
    return  StreamBuilder(
      stream: CommentsRefrence.doc(postId)
          .collection("comments")
          .orderBy("timestamp", descending: false)
          .snapshots(),
      builder: (context, dataSnapshot){
        if (!dataSnapshot.hasData){
          return Container(
            color: Colors.white,
          );
        }
        List<Comment> comments = [];
        dataSnapshot.data.documents.forEach((document){
          comments.add(Comment.fromDocument(document));
        });
        return ListView(
          children: comments,

        );
      },
    );
  }

  bool errordikhaoC = false;

  var commentCount = 0;

  SaveCommentI() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('commCount', commentCount);
    return await FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .update({'comments': comments + commentCount});

  }

  showError(){
    setState(() {
      errordikhaoC = true;
    });
    return AlertDialog(
      content: Text(
        'Insert something',
        style: TextStyle(color: Colors.black),
      ),
      title: Text("Error !", style:
      TextStyle(color: Colors.red),),
    );
  }

  Notification() async {
    //print(currUid);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String displayName = prefs.getString("displayName");
    String displayNameCurrUser = prefs.getString('displayNameCurrUser');

    print("911");

    if(displayName != displayNameCurrUser){
      print("911");
      setState(() {
        // file = null;
        NotificationId = Uuid().v4();
      });

      return await FirebaseFirestore.instance.collection("users")
          .doc(uid).collection("notification")
          .doc(currUser+postId+commentTextEditingController.text)
          .set({"commentId" : CommentId,
        "notificationId" : NotificationId,
        //"comment": commentTextEditingController.text,

        "timestamp": DateTime.now(),
        "uid": currUser,
        "status" : "Comment",
        "postId" : postId,
        "comment": commentTextEditingController.text,
      });

    }


    // return await Firestore.instance.collection("users")
    //     .document(uid).collection("notification")
    //     .document(NotificationId)
    //     .setData({"commentId" : CommentId,
    //   "notificationId" : NotificationId,
    //   "username": displayNamecurrentUser,
    //   "comment": commentTextEditingController.text,
    //
    //   "timestamp": DateTime.now(),
    //   "url": photoUrl,
    //   "uid": uid,
    //   "status" : "Comment",
    //   "postId" : postId,
    //   "postUrl" : postImageUrl,
    // });

  }

  SaveCommentIP() async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("posts")
        .doc(postId)
        .update({'comments': comments + commentCount});
  }

  saveComment() async {
    print("comm");
    print(commentCount);
    setState(() {
      // file = null;
      CommentId = Uuid().v4();
    });
    setState(() {
      errordikhaoC = false;
    });

    await CommentsRefrence.doc(postId).collection("comments").doc(CommentId)
        .set({"commentId" : CommentId,
      "username": displayNamecurrentUser,
      "comment": commentTextEditingController.text,

      "timestamp": DateTime.now(),
      "url": photoUrl,
      "uid": uid,
    });

    bool isNotPostOwner = uid != uid;
    if(isNotPostOwner){
      CommentsRefrence.doc(postId).collection("feedItems").add({
        "type": "comment",
        "commentDate": timestamp,
        "postId": postId,
        "username": displayNamecurrentUser,
        "userProfileImg": photoUrl,
        "url": postImageUrl,
      });
    }
    commentTextEditingController.clear();

    return StreamBuilder(

        stream: CommentsRefrence.doc(postId).snapshots(),
        builder: (context, dataSnapshotX)
        {
          int commentscount = dataSnapshotX.data["comments"];
          updatecommentscount(commentscount);

          return (dataSnapshotX.hasData)?
          Container(
            color: Colors.white,
          ):Container();
        }
    );



  }

  updatecommentscount(int commentscount){
    print("oichhh!!1");
    print(commentscount);

    CommentsRefrence.doc(postId).update({"comments": commentscount + 1});

  }

  @override
  void initState() {

    retrieveComments();
    SaveCurrUserId();

  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text("Comments", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.normal),),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios,color: Colors.black,), onPressed: (){
            Navigator.pop(context);
          }),
        ),
        //appBar: header(context, strTitle: "Comments"),

        body: Column(
          children: [
            Expanded(
              child: retrieveComments(),
            ),

            ListTile(
              key: _CommentKey,
              title: TextFormField(
                controller: commentTextEditingController,
                //validator: commentValidator,
                decoration: InputDecoration(
                    labelText: (errordikhaoC)?"insert proper comment":"Write Comment Here...",
                    labelStyle: TextStyle(color: (errordikhaoC)?Colors.red:Colors.black),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: (errordikhaoC)?Colors.red:Colors.grey)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: (errordikhaoC)?Colors.red:Colors.black))
                ),
                style: TextStyle(color: Colors.black),
              ),
              trailing:IconButton(
                onPressed: (){
                  if(commentTextEditingController.text != "" && commentTextEditingController.text.length < 100){
                    setState(() {
                      errordikhaoC = false;
                    });
                    commentCount = commentCount + 1;
                    saveComment();
                    SaveCommentI();
                    SaveCommentIP();
                    Notification();
                  }else{
                    showError();
                    print("error hai bhaiya");
                  }

//                retrieveComments();
                },

                icon: Icon(Icons.arrow_forward_ios,size: 30.0,color: Colors.deepPurple,),
                //child: Text("Publish", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),),
              ),
            )
          ],
        )

    );
  }
}

class Comment extends StatelessWidget {
  final String userName;
  final String userId;
  final String url;
  final String comment;
  final Timestamp timestamp;
  final String commentId;

  Comment({this.userName,this.userId,this.url,this.comment,this.timestamp,this.commentId});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot){
    return Comment(
      userName: documentSnapshot["username"],
      userId: documentSnapshot["uid"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],
      commentId : documentSnapshot["commentId"],

    );
  }

  get context => null;

  DeleteNotification() async {


    SharedPreferences prefs = await SharedPreferences.getInstance();
    String postId = prefs.getString('postId');
    String currUid = prefs.getString('currUserId');
    print(currUid);
    print(postId);
    print(comment);
    print("amios");
    FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection('notification')
    //.where('displayName','==',displayName);
        .doc(currUid+postId+comment)
        .delete();
  }

  deleteComments(String displayNameComment) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String displayName = prefs.getString("displayName");
    String displayNameCurrUser = prefs.getString('displayNameCurrUser');
    String postId = prefs.getString('postId');
    int comments = prefs.getInt("comments");
    int commCount = prefs.getInt("commCount");
    print(displayNameCurrUser+"del");
    print(commCount);
    print("delete comment");
    //int deleteC= comments+commCount;


    if(displayNameComment == displayNameCurrUser){


      DatabaseService().CommentD(postId,comments,commCount);
      print(displayNameCurrUser);
      await FirebaseFirestore.instance.collection('posts').doc(postId)
          .collection("comments").doc(commentId).delete();

    }
    else if(displayName == displayNameCurrUser){
      print("delte clickd");

      DatabaseService().CommentD(postId,comments,commCount);
      print(postId);
      print(displayName);
      print("halelula");
      print(displayNameCurrUser);
      await FirebaseFirestore.instance.collection('posts').doc(postId)
          .collection("comments").doc(commentId).delete();
    }
    else{
      print("aaya bhai ko");
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('You are not the owner of this comment'),
              actions: <Widget>[

              ],
            );
          });
    }
    print("delete me aaya");
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
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
          //height: deviceHeight*0.075,
          child: Stack(
            children: [
              ListTile(
                title: (userName != null || comment != null)?Row(
                  children: [
                    Container(
                      width: deviceWidth*0.60,
                      //height: deviceHeight*0.01,
                      child: RichText(
                        textAlign: TextAlign.start,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: userName + " : ",
                              style: TextStyle(fontSize: 18.0, color: Colors.black,fontWeight: FontWeight.bold,),
                            ),
                            TextSpan(
                              text: comment,
                              style: TextStyle(color: Colors.black,fontWeight: FontWeight.normal,
                                  fontSize: 15.0),
                            ),
                          ],
                        ),

                      ),
                    ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteComments(userName);
                      DeleteNotification();
                      print("delete me");
                    },
                  )
                  ],
                ):Text(""),
                leading: (userName != null || comment != null)?Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: CircleAvatar(
                    backgroundImage:NetworkImage(url),
                  ),
                ):null,
                subtitle: (userName != null || comment != null)?Text(tAgo(timestamp.toDate()),style: TextStyle(color: Colors.grey),):Text(""),
              ),
            ],
          ),
    );
  }
}

