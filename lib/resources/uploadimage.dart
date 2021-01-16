import 'dart:io';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as ImD;
import 'package:path_provider/path_provider.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:uuid/uuid.dart';

import 'auth.dart';

class UploadImage extends StatefulWidget {
  final User userData;
  File file;
  String sharedurl;
  int cam;
  String ownerdiscription;
  String ownerphotourl;
  String ownerdisplayname;
  bool shared;
  int shares;
  String ownerPostId;
  Timestamp ownerTimeStamp;
  String ownerUid;
  UploadImage({this.ownerUid,this.ownerPostId,this.shares,this.file, this.userData,this.cam,this.ownerdiscription,this.ownerphotourl,this.ownerdisplayname,this.shared,this.sharedurl,this.ownerTimeStamp});

  @override
  _UploadImageState createState() => _UploadImageState(ownerUid: ownerUid,ownerPostId: ownerPostId,shares:shares,cam: cam,ownerdiscription: ownerdiscription,ownerphotourl: ownerphotourl,ownerdisplayname: ownerdisplayname,shared: shared,sharedurl: sharedurl,ownerTimeStamp: ownerTimeStamp);
}

class _UploadImageState extends State<UploadImage> with AutomaticKeepAliveClientMixin<UploadImage> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int cam;
  String ownerdiscription;
  String ownerphotourl;
  String ownerdisplayname;
  bool shared;
  String sharedurl;
  int shares;
  String ownerPostId;
  Timestamp ownerTimeStamp;
  String ownerUid;
  _UploadImageState({this.ownerUid,this.ownerPostId,this.shares,this.cam,this.ownerdiscription,this.ownerphotourl,this.ownerdisplayname,this.shared,this.sharedurl,this.ownerTimeStamp});
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
  bool uploading = false;
  final StorageReference storageReference =
  FirebaseStorage.instance.ref().child("Post Pictures");
  final postReference = Firestore.instance.collection("posts");
  String postId = Uuid().v4();

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

  controlUploadAndSaveShared(bool shared) async{
  setState(() {
  uploading = true;
  });

  savePostInfoToFirestoreShared(ownerUid,sharedurl,descriptionController.text,ownerdiscription,ownerphotourl,ownerdisplayname,shared);
  savePostinfoToUserShared(ownerUid,sharedurl,descriptionController.text,ownerdiscription,ownerphotourl,ownerdisplayname,shared);

  descriptionController.clear();

  setState(() {
  uploading = false;
  postId = Uuid().v4();
  });

  Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => HomePage()),
  );
}

  controlUploadAndSave(bool shared) async {
    setState(() {
      uploading = true;
    });
    print(shared);
    print("shadah");

    await compressPhoto();

    String downloadUrl = await uploadPhoto(file);

      savePostInfoToFirestore(downloadUrl, descriptionController.text);
      savePostinfoToUser(downloadUrl, descriptionController.text);

    descriptionController.clear();
    setState(() {
      uploading = false;
      postId = Uuid().v4();
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  ShareIU() async {

    Firestore.instance
        .collection("users")
        .document(uidController.text)
        .collection("posts")
        .document(ownerPostId)
        .updateData({'shares': shares + 1});
  }

  ShareI() async {
    Firestore.instance
        .collection("posts")
        .document(ownerPostId)
        .updateData({'shares': shares + 1});
  }

  PostI() async {
    Firestore.instance
        .collection("users")
        .document(uidController.text)
        .updateData({'posts': posts + 1});
  }

  savePostInfoToFirestoreShared(String ownerUid,String url, String description, String ownerdescription, String ownerphotourl, String ownerdisplayname, bool shared) {

    Firestore.instance.collection("posts").document(postId).setData({
      "OwnerPhotourl" : ownerphotourl,
      "OwnerTimeStamp" : ownerTimeStamp,
      "description" : description,
      "OwnerUid" : ownerUid,
      "OwnerDisplayName" : ownerdisplayname,
      "shared" : shared,
      "postId": postId,
      "uid" : uidController.text,
      "displayName": displayNameController.text,
      "timestamp": Timestamp.now(),
      "email": emailController.text,
      "photoURL" :photoUrlController.text,
      "OwnerDescription": ownerdescription,
      "cam": cam,
      "likes": 0,
      "comments": 0,
      "shares" : 0,
      "url": url,
    });
  }

  savePostinfoToUserShared(String ownerUid,String url, String description, String ownerdescription, String ownerphotourl, String ownerdisplayname, bool shared) {

    Firestore.instance
        .collection("users")
        .document(uidController.text)
        .collection('posts')
        .document(postId)
        .setData({
      "OwnerPhotourl" : ownerphotourl,
      "OwnerTimeStamp" : ownerTimeStamp,
      "OwnerUid" : ownerUid,
      "description" : description,
      "Ownerdescription" : ownerdescription,
      "OwnerDisplayName" : ownerdisplayname,
      "shared" : shared,
      "postId": postId,
      "uid" : uidController.text,
      "displayName": displayNameController.text,
      "timestamp": Timestamp.now(),
      "email": emailController.text,
      "photoURL" :photoUrlController.text,
      "description": descriptionController.text,
      "cam": cam,
      "likes": 0,
      "comments": 0,
      "shares" : 0,
      "url": url,
    });
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
      "description": descriptionController.text,
      "cam": cam,
      "likes": 0,
      "comments": 0,
      "shares" : 0,
      "url": url,
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
      "description": descriptionController.text,
      "cam": cam,
      "likes": 0,
      "comments": 0,
      "shares": 0,
      "url": url,
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
        title: (shared==null || shared == false)?Text(
          "New Post",
          style: TextStyle(
              color: Colors.deepPurple, fontSize: 20, fontWeight: FontWeight.bold),
        ):Text(
          "Share Post",
          style: TextStyle(
              color: Colors.deepPurple, fontSize: 20, fontWeight: FontWeight.bold),
        ),
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
                child: (cam == 1)?Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: Container(
                    decoration: (shared == true)?
                    BoxDecoration(
                      image: DecorationImage(

                          image: NetworkImage(sharedurl),
                          fit: BoxFit.cover),
                    ):BoxDecoration(
                      image: DecorationImage(

                          image: FileImage(file),
                          fit: BoxFit.cover),
                    ),
                  ),
                ): Container(
                  decoration: (shared == true)?
                  BoxDecoration(
                    image: DecorationImage(
                      
                        image: NetworkImage(sharedurl),
                        fit: BoxFit.cover),
                  ):BoxDecoration(
                    image: DecorationImage(
                                          image: FileImage(file),
                                          fit: BoxFit.contain),
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
                          if(value.length > 200.0){
                            return 'Caption should not be greater then 200 words';
                          }
                        },
                        keyboardType: TextInputType.multiline,
                        maxLines: 3,
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

                  // Padding(
                  //   padding: const EdgeInsets.only(top: 10.0),
                  //   child: Container(
                  //     width: 50.0,
                  //     height: 50.0,
                  //     child: FlatButton(
                  //       highlightColor: Colors.transparent,
                  //       splashColor: Colors.transparent,
                  //       onPressed: (){
                  //         if(_formKey.currentState.validate()) {
                  //           controlUploadAndSave();
                  //           PostI();
                  //         }
                  //       },
                  //       //onPressed: () => controlUploadAndSave(),
                  //       child: Padding(
                  //         padding: const EdgeInsets.only(right: 108.0),
                  //         child: Icon(Icons.arrow_forward_ios, size: 30,color: Colors.deepPurple,),
                  //       ),
                  //       // child: Text(
                  //       //   "Share",
                  //       //   style: TextStyle(
                  //       //       color: Colors.deepPurple,
                  //       //       fontSize: 16,
                  //       //       fontWeight: FontWeight.bold),
                  //       // ),
                  //       shape: RoundedRectangleBorder(side: BorderSide(
                  //           color: Colors.deepPurple,
                  //           width: 2,
                  //           style: BorderStyle.solid
                  //       ), borderRadius: BorderRadius.circular(50)),
                  //     ),
                  //   ),
                  // ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: GestureDetector(
                      onTap: () {
                        if(shared == true){
                          print("hai hai");
                          controlUploadAndSaveShared(shared);
                          PostI();
                          ShareI();
                          ShareIU();
                        }else{
                          if(_formKey.currentState.validate()) {
                            controlUploadAndSave(shared);
                            PostI();
                          }
                        }

                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0,right: 10.0),
                        child: Container(
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            border: Border.all(
                              color: Colors.deepPurple,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(100),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
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