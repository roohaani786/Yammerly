import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:techstagram/constants.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/ui/ProfilePage.dart';
import 'package:image/image.dart' as ImD;

import '../constants3.dart';

class ProfilePage extends StatefulWidget {
  static final String pageName = "/ProfilePage";
  final User user;

  const ProfilePage({this.user, Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool isLoading = true;
  bool isEditable = true;
  String loadingMessage = "Loading Profile Data";
  TextEditingController firstNameController,
      lastNameController,
      emailController,
      phoneNumberController,uidController,
  bioController,genderController,linkController,photoUrlController,
  displayNameController,workController,educationController,
  currentCityController,homeTownController,relationshipController,pincodeController;

  DocumentSnapshot docSnap;
  FirebaseUser currUser;

  Map<String, dynamic> _profile;
  bool _loading = false;

  @override
  initState() {
    super.initState();

    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));

    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
    bioController = TextEditingController();
    genderController = TextEditingController();
    linkController = TextEditingController();
    photoUrlController = TextEditingController();
    displayNameController = TextEditingController();
    workController = TextEditingController();
    educationController = TextEditingController();
    currentCityController = TextEditingController();
    homeTownController = TextEditingController();
    relationshipController = TextEditingController();
    pincodeController = TextEditingController();

    uidController = TextEditingController();

    super.initState();
    fetchProfileData();
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();





  fetchProfileData() async {
    currUser = await FirebaseAuth.instance.currentUser();
    try {


      docSnap = await Firestore.instance
          .collection("users")
          .document(currUser.uid)
          .get();
      firstNameController.text = docSnap.data["fname"];
      lastNameController.text = docSnap.data["surname"];
      phoneNumberController.text = docSnap.data["phonenumber"];
      emailController.text = docSnap.data["email"];
      bioController.text = docSnap.data["bio"];
      genderController.text = docSnap.data["gender"];
      linkController.text = docSnap.data["link"];
      photoUrlController.text = docSnap.data["photoURL"];
      displayNameController.text = docSnap.data["displayName"];
      workController.text = docSnap.data["work"];
      educationController.text = docSnap.data["education"];
      currentCityController.text = docSnap.data["currentCity"];
      homeTownController.text = docSnap.data["homeTown"];
      relationshipController.text = docSnap.data["relationship"];
      pincodeController.text = docSnap.data["pincode"];

      uidController.text = docSnap.data["uid"];

      setState(() {
        isLoading = false;
        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  File profileImageFile;

  File _image;
  String _uploadedFileURL;

  Future pickImage() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
    uploadFile();
    print("Done..");
  }



//  Future<String> uploadPhoto(mImageFile) async {
//    StorageUploadTask mStorageUploadTask =
//    storageReference.child("dp_$uidController.jpg").putFile(mImageFile);
//    StorageTaskSnapshot storageTaskSnapshot =
//    await mStorageUploadTask.onComplete;
//    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
//    return downloadUrl;
//  }

  bool uploading = false;

//  controlUploadAndSave() async {
//    setState(() {
//      uploading = true;
//    });
//
//   await compressPhoto();
//
//    String downloadUrl = await uploadPhoto(_image);
//    savePostInfoToFirestore(downloadUrl);
//
//    setState(() {
//      // file = null;
//      uploading = false;
//    });
////    Navigator.pop(context);
//  }


  compressPhoto() async {
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    ImD.Image mImageFile = ImD.decodeImage(_image.readAsBytesSync());
    final compressedImage = File('$path/img_$uidController.jpg')
      ..writeAsBytesSync(
        ImD.encodeJpg(mImageFile, quality: 60),
      );
    setState(() {
      _image = compressedImage;
    });
  }

  final StorageReference storageReference =
  FirebaseStorage.instance.ref().child("Display Pictures");
  final postReference = Firestore.instance.collection("users");

  savePostInfoToFirestore(String url) {
    postReference.document(currUser.uid).updateData({
      "photoURL": photoUrlController.text,
    });
    print(photoUrlController.text);
  }

  Future uploadFile() async {

    await compressPhoto();

    StorageReference storageReference =

    FirebaseStorage.instance
        .ref()
        .child('users');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {

//        _uploadedFileURL = fileURL;
//        photoUrlController.text = _uploadedFileURL;
      photoUrlController.text = fileURL;
        isChanged = true;
      });
    });
    savePostInfoToFirestore(photoUrlController.text);
  }




//  savePostInfoToFirestore(String url, String description) {
//    storageReference.document(currUser).setData({
//
//      "photoURL": photoUrlController.text,
////      "photourl": widget.userData.photoUrl,
//    });
//  }


  Future pickImagefromCamera() async {
    await ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      setState(() {
        _image = image;
      });
    });
    uploadFile();
    print("Done..");

  }



//  Future<void> updateProfilePicture(File profilePictureUrl) async {
//    String uid = uidController.text;
//    DocumentReference ref = Firestore.instance.collection("users").document(
//        uid); //reference of the user's document node in database/users. This node is created using uid
//    var data = {
//      'photoURL': profilePictureUrl,
//    };
//    await ref.setData(data, merge: true); // set the photoURL
//  }




bool isChanged = false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Edit Profile"),
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.close,
          color: Colors.redAccent,),
        ),
        actions: [
          IconButton(
          onPressed: () async {
    if (!isEditable)
    setState(() => isEditable = true);
    else {
    bool isChanged = true;
    if (docSnap.data["fname"].toString().trim() !=
    firstNameController.text.trim()) {
    print("First Name Changed");
    isChanged = true;
    } else if (docSnap.data["surname"].toString().trim() !=
    lastNameController.text.trim()) {
    print("Last Name Changed");
    isChanged = true;
    } else if (docSnap.data["email"].toString().trim() !=
    emailController.text.trim()) {
    print("Email Changed");
    isChanged = true;
    } else if (docSnap.data["phonenumber"].toString().trim() !=
    phoneNumberController.text.trim()) {
    print("Phone Number Changed");
    isChanged = true;
    } else if (docSnap.data["bio"].toString().trim() !=
        bioController.text.trim()) {
      print("Bio Changed");
      isChanged = true;
    }   else if (docSnap.data["gender"].toString().trim() !=
        genderController.text.trim()) {
      print("Gender Changed");
      isChanged = true;
    }
    else if (docSnap.data["link"].toString().trim() !=
        linkController.text.trim()) {
      print("Link Changed");
      isChanged = true;
    }


    else if (docSnap.data["displayName"].toString().trim() !=
        displayNameController.text.trim()) {
      print("displayName Changed");
      isChanged = true;
    }

    else if (docSnap.data["photoURL"].toString().trim() !=
        photoUrlController.text.trim()) {
      print("photoUrl Changed");
      isChanged = true;
    } //displayName

    else if (docSnap.data["work"].toString().trim() !=
        workController.text.trim()) {
      print("work Changed");
      isChanged = true;
    }//work

    else if (docSnap.data["education"].toString().trim() !=
        educationController.text.trim()) {
      print("education Changed");
      isChanged = true;
    }//education

    else if (docSnap.data["currentCity"].toString().trim() !=
        currentCityController.text.trim()) {
      print("currentCity Changed");
      isChanged = true;
    }//currentCity

    else if (docSnap.data["homeTown"].toString().trim() !=
        homeTownController.text.trim()) {
      print("homeTown Changed");
      isChanged = true;
    }//homeTown

    else if (docSnap.data["relationship"].toString().trim() !=
        relationshipController.text.trim()) {
      print("relationship Changed");
      isChanged = true;
    }

//    else if (docSnap.data["photoURL"].toString().trim() !=
//        photoUrlController.text.trim()) {
//      print("photoURL Changed");
//      isChanged = true;
//    }


    else if (docSnap.data["pincode"].toString().trim() !=
        pincodeController.text.trim()) {
      print("Pincode Changed");
      isChanged = true;
    }//relationship

    if (isChanged) {
    String snackbarContent = "";
    setState(() => isLoading = true);
    try {

    Map<String, dynamic> data = {};
    data["fname"] = firstNameController.text.trim();
    data["surname"] = lastNameController.text.trim();
    data["phonenumber"] = phoneNumberController.text.trim();
    data["email"] = emailController.text.trim();
    data["bio"] = bioController.text.trim();
    data["gender"] = genderController.text.trim();
    data["link"] = linkController.text.trim();
    data["photoURL"] = photoUrlController.text.trim();
    data["displayName"] = displayNameController.text.trim();
    data["pincode"] = pincodeController.text.trim();
    data["work"] = workController.text.trim();//work
    data["education"] = educationController.text.trim();//education
    data["currentCity"] = currentCityController.text.trim();//currentCity
    data["homeTown"] = homeTownController.text.trim();//hometown
    data["relationship"] = relationshipController.text.trim();//relationship
    Firestore.instance
        .collection("users")
        .document(currUser.uid)
        .setData(data, merge: true);
    snackbarContent = "Profile Updated";
    if(snackbarContent == "Profile Updated"){

      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HomePage(initialindexg: 4)));
    }
    try {
    await currUser.updateEmail(data["email"]);
    snackbarContent =
    snackbarContent + ". Login Email Also Updated";
    } on PlatformException catch (e) {
    print(
    "AUTHEXCEPTION. FAILED TO CHANGE FIREBASE AUTH EMAIL. E = " +
    e.message.toString());
    snackbarContent = snackbarContent +
    ". Login Email Not Changed (As Not Recently Logged In)";
    } catch (e) {
    print("ERROR. FAILED TO CHANGE FIREBASE AUTH EMAIL. E = " +
    e.toString());
    snackbarContent = snackbarContent +
    ". Login Email Not Changed (As Not Recently Logged In)";
    }
    fetchProfileData();
    } on PlatformException catch (e) {
    print("PlatformException in fetching user profile. E  = " +
    e.message);
    snackbarContent = "Failed To Update Profile";
    }
    _scaffoldKey.currentState.showSnackBar(SnackBar(
    content: Text(snackbarContent),
    duration: Duration(milliseconds: 3000),
    behavior: SnackBarBehavior.floating,
    ));
    } else {
    setState(() => isEditable = false);
    }
    }

    }
            ,icon: Icon(Icons.done,
            color: Colors.deepPurple,),
          ),
        ],
      ),
      key: _scaffoldKey,
      backgroundColor: Colors.white,
//      appBar: AppBar(
//        title: "Profile".text.white.make(),
//        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
//        brightness: Brightness.dark,
//      ),
      body: Container(
        color: Colors.white,
        height: double.maxFinite,
        width: double.maxFinite,
        padding: EdgeInsets.all(12),

        child: isLoading
            ? Center(
                child: Column(
                  
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 8,
                  ),
                  Text(loadingMessage,
                  style: TextStyle(
                    color: Colors.deepPurple,
                  ),)
                ],
              ))
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4,vertical: 8),
                child: Column(
                  children: [
                    Text(
                      "My Account",
                      style: TextStyle(
                          fontFamily: "Cookie-Regular", fontSize: 25.0),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    GestureDetector(
                      onTap: (){
    showDialog<void>(
    context: context,// THIS WAS MISSING// user must tap button!
    builder: (BuildContext context) {
    return (isChanged==false)?AlertDialog(
    title: Text('Select image from :-',style: TextStyle(
      fontSize: 15.0,
    ),),
    content: SingleChildScrollView(
    child: ListBody(
    children: <Widget>[
    GestureDetector(
      onTap: (){
        _scaffoldKey.currentState.removeCurrentSnackBar();
        setState(() {
          isChanged = true;
        });
        pickImagefromCamera();
      },
      child: Row(
        children: [
          Icon(FontAwesomeIcons.camera,color: kPrimaryColor,),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Text('Camera'),
          ),
        ],
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: GestureDetector(
        onTap: (){
          pickImage();
        },
        child: Row(
            children: [
              Icon(FontAwesomeIcons.images,color: kPrimaryColor,),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text('Gallery'),
              ),
            ],
          ),
      ),
    ),
    ],
    ),
    ),
    ):Container();

                      });
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(photoUrlController.text),

                        backgroundColor: Colors.transparent,
                      ),

                    ),
                    SizedBox(
                      height: 16,
                    ),



                    TextFormField(
                      controller: firstNameController,
                      enabled: isEditable,
                      decoration: InputDecoration(
                          labelText: "First Name",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1))),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: lastNameController,
                      enabled: isEditable,
                      decoration: InputDecoration(
                          labelText: "Last Name",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1))),
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller: phoneNumberController,
                      enabled: isEditable,
                      maxLength: 10,
                      inputFormatters: [
                        WhitelistingTextInputFormatter.digitsOnly
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: "Phone Number",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller: emailController,
                      enabled: isEditable,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: "Email Id",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1))),
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller: bioController,
                      enabled: isEditable,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      decoration: InputDecoration(
                          labelText: "Bio",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormField(
                      controller: genderController,
                      enabled: isEditable,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Gender",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller: linkController,
                      enabled: isEditable,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Link",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),
                    SizedBox(
                      height: 16,
                    ),


                    TextFormField(
                      controller: displayNameController,
                      enabled: isEditable,
                      keyboardType: TextInputType.text,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Display Name",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller: workController,
                      enabled: isEditable,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Work",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller: educationController,
                      enabled: isEditable,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Education",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller: currentCityController,
                      enabled: isEditable,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Current City",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller: pincodeController,
                      enabled: isEditable,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Pin Code",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),

                    SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller: homeTownController,
                      enabled: isEditable,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Home Town",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),
                    SizedBox(
                      height: 16,
                    ),

                    TextFormField(
                      controller: relationshipController,
                      enabled: isEditable,
                      keyboardType: TextInputType.multiline,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: "Relationship",labelStyle: TextStyle(
                          color: Colors.deepPurple,fontWeight: FontWeight.bold
                      ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              BorderSide(color: Colors.black, width: 1))),
                    ),


                  ],
                ),
              ),
      ),
    );
  }
}
