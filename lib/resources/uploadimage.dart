import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:techstagram/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;

import 'auth.dart';

class UploadImage extends StatefulWidget {
  final User userData;
  File file;
  UploadImage({this.file, this.userData});

  @override
  _UploadImageState createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage>
    with AutomaticKeepAliveClientMixin<UploadImage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController
  emailController,
      uidController,
      displayNameController,photoUrlController,
  descriptionController,postsController;


  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
  FirebaseUser currUser;


  File file;
//  TextEditingController descriptionTextEditingController =
//  TextEditingController();
  bool uploading = false;
  final StorageReference storageReference =
  FirebaseStorage.instance.ref().child("Post Pictures");
  final postReference = Firestore.instance.collection("posts");
  String postId = Uuid().v4();

  // removeImage() {
  //   descriptionTextEditingController.clear();
  //   setState(() {
  //     widget.file = null;
  //   });
  // }

  compressPhoto() async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImage = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(
        ImD.encodeJpg(mImageFile, quality: 50),
      );
    setState(() {
      file = compressedImage;
    });
  }

  Future<String> uploadPhoto(mImageFile) async {
    StorageUploadTask mStorageUploadTask =
    storageReference.child("post_$postId.jpg").putFile(mImageFile);
    StorageTaskSnapshot storageTaskSnapshot =
    await mStorageUploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  controlUploadAndSave() async {
    setState(() {
      uploading = true;
    });

    await compressPhoto();

    String downloadUrl = await uploadPhoto(file);
    savePostInfoToFirestore(downloadUrl, descriptionController.text);
    savePostinfoToUser(downloadUrl, descriptionController.text);
    //PostI();

    descriptionController.clear();
    setState(() {
      // file = null;
      uploading = false;
      postId = Uuid().v4();
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  PostI() async {
    print(postsController);
    print("helloww");
    //String increment = postsController.text;
    //int incr = int.parse(posts);
    //print(incr);
    Firestore.instance
        .collection("users")
        .document(uidController.text)
        .updateData({'posts': posts + 1});
  }

  savePostinfoToUser(String url, String description){
    Firestore.instance
        .collection("users")
        .document(uidController.text)
        .collection('posts')
        .document(postId)
        .setData({
      "postId": postId,
      "uid" : uidController.text,
      "displayName": displayNameController.text,
      "timestamp": Timestamp.now(),
      "email": emailController.text,
      "photoURL" :photoUrlController.text,
//      "email": widget.userData.email,
      "description": descriptionController.text,
      "likes": 0,
      "comments": 0,
      "url": url,
//      "photourl": widget.userData.photoUrl,
    });
  }

  savePostInfoToFirestore(String url, String description) {
    postReference.document(postId).setData({
      "postId": postId,
      "uid" : uidController.text,
      "displayName": displayNameController.text,
      "timestamp": Timestamp.now(),
      "email": emailController.text,
      "photoURL" :photoUrlController.text,
//      "email": widget.userData.email,
      "description": descriptionController.text,
      "likes": 0,
      "comments": 0,
      "url": url,
//      "photourl": widget.userData.photoUrl,
    });

  }

  displayUploadFormScreen() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: Colors.deepPurple,),
            onPressed: (){
          Navigator.pop(context);
        }),
        title: Text(
          "New Post",
          style: TextStyle(
              color: Colors.deepPurple, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          // uploading ? linearProgress() : Text(''),
          FlatButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onPressed: (){
              if(_formKey.currentState.validate()) {
                controlUploadAndSave();
                PostI();
              }
            },
            //onPressed: () => controlUploadAndSave(),
            child: Text(
              "Share",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: uploading
          ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      )
          : ListView(
        children: <Widget>[
          Container(
            height: 330,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 6 / 5,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(

                        image: FileImage(file), fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 12),
          ),

          Container(
//            color: Colors.white,
            child:  Align(
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text("Caption :-",style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      autovalidate: true,
                      key: _formKey,
                      child: TextFormField(
                        controller: descriptionController,
                        enabled: true,
                        validator: (value) {
                          if(value.length > 25.0){
                            return 'Caption should not be greater then 25 words';
                          }
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: 2,
                        decoration: InputDecoration(
                            labelText: "Write your caption here...",labelStyle: TextStyle(
                          color: Colors.grey,
                        ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                BorderSide(color: Colors.black, width: 1))),
                      ),
                    )

                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    file = widget.file;
    uidController = TextEditingController();
    emailController = TextEditingController();
    photoUrlController = TextEditingController();
    displayNameController = TextEditingController();
    descriptionController = TextEditingController();
    postsController = TextEditingController();

    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));

    super.initState();
    fetchProfileData();
  }

  int posts;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  fetchProfileData() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {
      docSnap = await Firestore.instance
          .collection("users")
          .document(currUser.uid)
          .get();
      uidController.text = docSnap.data["uid"];
      emailController.text = docSnap.data["email"];
      displayNameController.text = docSnap.data["displayName"];
      photoUrlController.text = docSnap.data["photoURL"];
      posts = docSnap.data["posts"];


      print(postsController);
      print("halelula");

    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: displayUploadFormScreen(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}