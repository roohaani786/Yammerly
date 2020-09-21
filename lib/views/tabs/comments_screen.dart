import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techstagram/models/comment.dart';
import 'package:techstagram/models/posts.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/services/database.dart';
// import 'package:instagram_clone/models/comment.dart';
// import 'package:instagram_clone/models/user.dart';

class CommentsScreen extends StatefulWidget {
  final DocumentReference documentReference;
  final User user;
  CommentsScreen({this.documentReference, this.user});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  TextEditingController _commentController = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  TextEditingController emailController,urlController,descriptionController,
      displayNameController,photoUrlController,uidController,
      timestampController,likesController,urlCOntroller;
  List<Posts> posts;

  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
  FirebaseUser currUser;

  @override
  void dispose() {
    super.dispose();
    _commentController?.dispose();
  }

  @override
  void initState() {

    emailController = TextEditingController();
    likesController = TextEditingController();

    super.initState();
    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));
    fetchPosts();
    fetchProfileData();
  }

  fetchProfileData() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {
      docSnap = await Firestore.instance
          .collection("users")
          .document(currUser.uid)
          .get();
      emailController.text = docSnap.data["email"];
      likesController.text = docSnap.data["likes"];
      displayNameController.text = docSnap.data["displayName"];
      photoUrlController.text = docSnap.data["photoURL"];
      uidController.text = docSnap.data["uid"];
      setState(() {
//        isLoading = false;
//        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  fetchPosts() async {
    try {

      DatabaseService().getPosts();

    } on PlatformException catch (e) {
      print("PlatformException in fetching user posts. E  = " + e.message);
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: new Color(0xfff8faf8),
        title: Text('Comments'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            //commentsListWidget(),
            Divider(
              height: 20.0,
              color: Colors.grey,
            ),
            commentInputWidget()
          ],
        ),
      ),
    );
  }

  Widget commentInputWidget() {
    return Container(
      height: 55.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Container(
            width: 40.0,
            height: 40.0,
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40.0),
                image:
                    DecorationImage(image: NetworkImage(photoUrlController.text))),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: TextFormField(
                validator: (String input) {
                  if (input.isEmpty) {
                    return "Please enter comment";
                  }
                },
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: "Add a comment...",
                ),
                onFieldSubmitted: (value) {
                  _commentController.text = value;
                },
              ),
            ),
          ),
          GestureDetector(
            child: Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: Text('Post', style: TextStyle(color: Colors.blue)),
            ),
            onTap: () {
              if (_formKey.currentState.validate()) {
                postComment();
              }
            },
          )
        ],
      ),
    );
  }

   postComment() {
     var _comment = Comment(
         comment: _commentController.text,
         timeStamp: FieldValue.serverTimestamp(),
         ownerName: displayNameController.text,
         ownerPhotoUrl: photoUrlController.text,
         ownerUid: uidController.text);
     widget.documentReference
         .collection("comments")
         .document()
         .setData(_comment.toMap(_comment)).whenComplete(() {
           _commentController.text = "";
         });
   }

   Widget commentsListWidget() {
     print("Document Ref : ${widget.documentReference.path}");
     return Flexible(
       child: StreamBuilder(
         stream: widget.documentReference
             .collection("comments")
             .orderBy('timestamp', descending: false)
             .snapshots(),
         builder: ((context, AsyncSnapshot<QuerySnapshot> snapshot) {
           if (!snapshot.hasData) {
             return Center(child: CircularProgressIndicator());
           } else {
             return ListView.builder(
               itemCount: snapshot.data.documents.length,
               itemBuilder: ((context, index) =>
                   commentItem(snapshot.data.documents[index])),
             );
           }
         }),
       ),
     );
   }

  Widget commentItem(DocumentSnapshot snapshot) {
     var time;
     List<String> dateAndTime;
     print('${snapshot.data['timestamp'].toString()}');
     if (snapshot.data['timestamp'].toString() != null) {
         Timestamp timestamp =snapshot.data['timestamp'];
    // print('${timestamp.seconds}');
    // print('${timestamp.toDate()}');
      time =timestamp.toDate().toString();
      dateAndTime = time.split(" ");
     }
  
    
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(snapshot.data['ownerPhotoUrl']),
              radius: 20,
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Row(
            children: <Widget>[
              Text(snapshot.data['ownerName'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(snapshot.data['comment']),
              ),
            ],
          )
        ],
      ),
    );
  }
}
