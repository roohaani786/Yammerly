import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
//import 'package:path/path.dart';
import 'package:techstagram/modell/global.dart';
import 'package:techstagram/views/tabs/feeds.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'package:techstagram/ui/Otheruser/other_user.dart';

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
    print("user");
    print(displayNamecurrentUser);
    return StreamBuilder(
      stream: CommentsRefrence.document(postId)
      .collection("comments")
      .orderBy("timestamp", descending: false)
      .snapshots(),
      builder: (context, dataSnapshot){
        if (!dataSnapshot.hasData){
          return Container(
            color: Colors.red,
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



  //setData({'liked': userEmail});

  saveComment() {
    print(postId);
    print("ehllo");
    CommentsRefrence.document(postId).collection("comments").document(DateTime.now().toIso8601String())
        .setData({"username": displayNamecurrentUser,
      "comment": commentTextEditingController.text,

      "timestamp": DateTime.now(),
      "url": photoUrl,
      "uid": uid,
    });


    bool isNotPostOwner = uid != uid;
     if(isNotPostOwner){
       CommentsRefrence.document(postId).collection("feedItems").add({
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

        stream: CommentsRefrence.document(postId).snapshots(),
        builder: (context, dataSnapshotX)
        {
          int commentscount = dataSnapshotX.data["comments"];
          updatecommentscount(commentscount);

          return (dataSnapshotX.hasData)?
          Container(
            color: Colors.red,
          ):Container();
        }
    );


  }

  updatecommentscount(int commentscount){
    print("oichhh!!1");
    print(commentscount);

    CommentsRefrence.document(postId).updateData({"comments": commentscount + 1});

  }

  @override
  void initState() {
//    retrieveCommentscount();
    retrieveComments();

  }

  @override
  Widget build(BuildContext) {
    return Scaffold(

        appBar: AppBar(
          backgroundColor: Colors.white70,
          title: Text("Comment", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),),
        ),
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
              onPressed: (){
                saveComment();
//                retrieveComments();
              },
              borderSide: BorderSide.none,
              child: Icon(Icons.arrow_forward,size: 40.0,color: Colors.purpleAccent,),
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

  Comment({this.userName,this.userId,this.url,this.comment,this.timestamp});

  factory Comment.fromDocument(DocumentSnapshot documentSnapshot){
    return Comment(
      userName: documentSnapshot["username"],
      userId: documentSnapshot["uid"],
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
        child: GestureDetector(
          //onTap: () => OtherUserProfile(uid: uid,displayNamecurrentUser: displayNamecurrentUser,displayName: displayName, uidX: uidX),
          // onTap: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => OtherUserProfile(uid: uid,displayNamecurrentUser: displayNamecurrentUser,displayName: displayName, uidX: uidX)),
          //   );
          // },
         
        //color: Colors.white,
        child: Stack(
          children: [
            ListTile(
              title: (userName != null || comment != null)?Row(
                children: [
                  Text(userName,style: TextStyle(fontSize: 18.0,color: Colors.black,
                  fontWeight: FontWeight.bold,),),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: SizedBox(
                      width: 200.0,
                      child: Text(comment,maxLines: 1,style: TextStyle(fontSize: 15.0,color: Colors.black,
                      ),),
                    ),
                  ),
                ],
              ):Text(""),
              leading: (userName != null || comment != null)?CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(url),
              ):null,
              subtitle: (userName != null || comment != null)?Text(tAgo.format(timestamp.toDate()),style: TextStyle(color: Colors.black),):Text(""),
            ),
          ],
        ),
      ),
    )
    );
  }
}


