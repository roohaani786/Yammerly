import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:techstagram/modell/global.dart';
import 'package:techstagram/views/tabs/feeds.dart';
import 'package:timeago/timeago.dart' as tAgo;

import 'package:flutter/material.dart';

final CommentsRefrence = Firestore.instance.collection("posts");

class CommentsPage extends StatefulWidget{
  final String postId;
  final String uid;
  final String postImageUrl;
  final Timestamp timestamp;
  final String displayName;
  final String photoUrl;
  final String displayNamecurrentUser;


  CommentsPage({this.postId,this.uid,this.postImageUrl,this.timestamp,this.displayName,this.photoUrl,this.displayNamecurrentUser});

  @override
  CommentsPageState createState() => CommentsPageState(postId: postId, uid: uid, postImageUrl: postImageUrl,timestamp: timestamp,displayName: displayName,photoUrl: photoUrl,displayNamecurrentUser: displayNamecurrentUser);
}

class CommentsPageState extends State<CommentsPage> {
  final String postId;
  final String uid;
  final String postImageUrl;
  final Timestamp timestamp;
  final String displayName;
  final String photoUrl;
  final String displayNamecurrentUser;

  TextEditingController commentTextEditingController = TextEditingController();

  CommentsPageState({this.postId,this.uid,this.postImageUrl,this.timestamp,this.displayName,this.photoUrl,this.displayNamecurrentUser});

  retrieveComments(){
    return StreamBuilder(
      stream: CommentsRefrence.document(postId)
      .collection("comments")
      .orderBy("timestamp", descending: false)
      .snapshots(),
      builder: (context, dataSnapshot){
        if (!dataSnapshot.hasData){
          return Container();
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
  //setData({'liked': userEmail});
  saveComment(){
    print(displayNamecurrentUser);
    print("ehllo");
    CommentsRefrence.document(postId).collection("comments").document("klaus")
        .setData({"username": "klaus",
      "comment": commentTextEditingController,
      "timestamp": DateTime.now(),
      "url": photoUrl,
      "uid": uid,
    });

    // bool isNotPostOwner = uid != uid;
    // if(isNotPostOwner){
    //   activityFeedRefrence.document(postOwnerId).collection("feedItems").add({
    //     "type": "comment",
    //     "commentDate": timestamp,
    //     "postId": curentuser.id,
    //     "username": currentUser.name,
    //     "userProfileImg":currentUser.url,
    //     "url": postImageUrl,
    //   });
    // }
    // commentTextEditingController.clear();
  }

  @override
  Widget build(BuildContext) {
    return Scaffold(
      //appBar: header(context, strTitle: "Comments"),
      body: Column(
        children: [
          Expanded(
            child: retrieveComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentTextEditingController,
              decoration: InputDecoration(
                labelText: "Write Comment Here...",
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black))
              ),
              style: TextStyle(color: Colors.black),
            ),
            trailing: OutlineButton(
              onPressed: saveComment,
              borderSide: BorderSide.none,
              child: Text("Publish", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),),
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

  Comment({this.userName,this.userId,this.url,this.comment,this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot){
    return Comment(
      userName: documentSnapshot["username"],
      userId: documentSnapshot["userId"],
      url: documentSnapshot["url"],
      comment: documentSnapshot["comment"],
      timestamp: documentSnapshot["timestamp"],

    );
  }

  @override
  Widget build(BuildContext) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.0),
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            ListTile(
              title: Text(userName+":  "+ comment,style: TextStyle(fontSize: 18.0,color: Colors.black),),
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ),
              subtitle: Text(tAgo.format(timestamp.toDate()),style: TextStyle(color: Colors.black),),
            )
          ],
        ),
      ),
    );
  }
}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:techstagram/models/comment.dart';
// import 'package:techstagram/models/user.dart';
// //import 'package:instagram_clone/models/user.dart';
//
// class CommentsScreen extends StatefulWidget {
//   final DocumentReference documentReference;
//   final User user;
//   CommentsScreen({this.documentReference, this.user});
//
//   @override
//   _CommentsScreenState createState() => _CommentsScreenState();
// }
//
// class _CommentsScreenState extends State<CommentsScreen> {
//   TextEditingController _commentController = TextEditingController();
//   var _formKey = GlobalKey<FormState>();
//
//   @override
//   void dispose() {
//     super.dispose();
//     _commentController?.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 1,
//         backgroundColor: new Color(0xfff8faf8),
//         title: Text('Comments'),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Column(
//           children: <Widget>[
//             commentsListWidget(),
//             Divider(
//               height: 20.0,
//               color: Colors.grey,
//             ),
//             commentInputWidget()
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget commentInputWidget() {
//     return Container(
//       height: 55.0,
//       margin: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: Row(
//         children: <Widget>[
//           Container(
//             width: 40.0,
//             height: 40.0,
//             margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
//             padding: const EdgeInsets.symmetric(vertical: 4.0),
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(40.0),
//                 image:
//                 DecorationImage(image: NetworkImage(widget.user.photoUrl))),
//           ),
//           Flexible(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12.0),
//               child: TextFormField(
//                 validator: (String input) {
//                   if (input.isEmpty) {
//                     return "Please enter comment";
//                   }
//                 },
//                 controller: _commentController,
//                 decoration: InputDecoration(
//                   hintText: "Add a comment...",
//                 ),
//                 onFieldSubmitted: (value) {
//                   _commentController.text = value;
//                 },
//               ),
//             ),
//           ),
//           GestureDetector(
//             child: Container(
//               margin: const EdgeInsets.only(right: 8.0),
//               child: Text('Post', style: TextStyle(color: Colors.blue)),
//             ),
//             onTap: () {
//               if (_formKey.currentState.validate()) {
//                 postComment();
//               }
//             },
//           )
//         ],
//       ),
//     );
//   }
//
//   postComment() {
//     var _comment = Comment(
//         comment: _commentController.text,
//         timeStamp: FieldValue.serverTimestamp(),
//         ownerName: widget.user.displayName,
//         ownerPhotoUrl: widget.user.photoUrl,
//         ownerUid: widget.user.uid);
//     widget.documentReference
//         .collection("comments")
//         .document()
//         .setData(_comment.toMap(_comment)).whenComplete(() {
//       _commentController.text = "";
//     });
//   }
//
//   Widget commentsListWidget() {
//     print("Document Ref : ${widget.documentReference.path}");
//     return Flexible(
//       child: StreamBuilder(
//         stream: widget.documentReference
//             .collection("comments")
//             .orderBy('timestamp', descending: false)
//             .snapshots(),
//         builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           } else {
//             return ListView.builder(
//               itemCount: snapshot.data.documents.length,
//               itemBuilder: ((context, index) =>
//                   commentItem(snapshot.data.documents[index])),
//             );
//           }
//         }),
//       ),
//     );
//   }
//
//   Widget commentItem(DocumentSnapshot snapshot) {
//     //   var time;
//     //   List<String> dateAndTime;
//     //   print('${snapshot.data['timestamp'].toString()}');
//     //   if (snapshot.data['timestamp'].toString() != null) {
//     //       Timestamp timestamp =snapshot.data['timestamp'];
//     //  // print('${timestamp.seconds}');
//     //  // print('${timestamp.toDate()}');
//     //    time =timestamp.toDate().toString();
//     //    dateAndTime = time.split(" ");
//     //   }
//
//
//     return Padding(
//       padding: const EdgeInsets.all(12.0),
//       child: Row(
//         children: <Widget>[
//           Padding(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: CircleAvatar(
//               backgroundImage: NetworkImage(snapshot.data['ownerPhotoUrl']),
//               radius: 20,
//             ),
//           ),
//           SizedBox(
//             width: 15.0,
//           ),
//           Row(
//             children: <Widget>[
//               Text(snapshot.data['ownerName'],
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   )),
//               Padding(
//                 padding: const EdgeInsets.only(left: 8.0),
//                 child: Text(snapshot.data['comment']),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
