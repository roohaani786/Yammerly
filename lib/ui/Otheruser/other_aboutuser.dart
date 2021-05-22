import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as ImD;
import 'package:path_provider/path_provider.dart';
import 'package:techstagram/resources/auth.dart';

class AboutOtherUser extends StatefulWidget {
  static final String pageName = "/ProfilePage";
  //final User user;
  String uid;
  AboutOtherUser({this.uid});
  //const AboutOtherUser({this.user, Key key}) : super(key: key);

  @override
  _AboutOtherUserState createState() => _AboutOtherUserState(uid: uid);
}

class _AboutOtherUserState extends State<AboutOtherUser> {
  String uid;
  _AboutOtherUserState({this.uid});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = true;
  bool isEditable = true;
  String loadingMessage = "Loading Profile Data";
  TextEditingController firstNameController,
      lastNameController,
      emailController,
      phoneNumberController,
      uidController,
      bioController,
      genderController,
      linkController,
      photoUrlController,
      displayNameController,
      workController,
      educationController,
      currentCityController,
      homeTownController,
      relationshipController,
      pincodeController;

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
      docSnap =
          await Firestore.instance.collection("users").document(uid).get();
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
  bool uploading = false;

  compressPhoto() async {
    setState(() {
      isChanged = true;
    });
    final directory = await getTemporaryDirectory();
    final path = directory.path;
    ImD.Image mImageFile = ImD.decodeImage(_image.readAsBytesSync());
    final compressedImage = File('$path/img_$uidController.jpg')
      ..writeAsBytesSync(
        ImD.encodeJpg(mImageFile, quality: 30),
      );
    setState(() {
      _image = compressedImage;
    });
  }

  final Reference storageReference =
      FirebaseStorage.instance.ref().child("Display Pictures");
  final postReference = Firestore.instance.collection("users");

  bool isChanged = false;
  String relationstring = "Select Relationship";
  String genderstring = "Select Gender";
  bool tickvalue = false;
  int check;

  bool firstnameE = false;
  bool lastnameE = false;
  bool phonenumberE = false;
  bool emailE = false;
  bool bioE = false;
  bool websiteE = false;
  bool educationE = false;
  bool currentcityE = false;
  bool hometownE = false;
  String valueX = "Select Gender";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(displayNameController.text),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
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
                  Text(
                    loadingMessage,
                    style: TextStyle(
                      color: Colors.deepPurple,
                    ),
                  )
                ],
              ))
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Column(
                  children: [
                    Text(
                      "About" + " " + displayNameController.text,
                      style: TextStyle(
                          fontFamily: "Cookie-Regular", fontSize: 25.0),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                        decoration: BoxDecoration(
                          //borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.white,
                            width: 5,
                          ),
                        ),
                        child: Container(
                          height: 100,
                          width: 100.0,
                          child: Image(
                            image: (isChanged == false)
                                ? NetworkImage(photoUrlController.text)
                                : AssetImage("assets/images/loading.gif"),
                            fit: BoxFit.cover,
                          ),
                          //backgroundImage: NetworkImage(photoUrlController.text)
                        )),
                    SizedBox(
                      height: 16,
                    ),
                    Form(
                      autovalidateMode: AutovalidateMode.always,
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          (displayNameController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: displayNameController,
                                  enabled: false,
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Username",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (displayNameController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16.0,
                                ),
                          (firstNameController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: firstNameController,
                                  enabled: false,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "First Name",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (firstNameController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16,
                                ),
                          (lastNameController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: lastNameController,
                                  enabled: false,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Last Name",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (lastNameController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16,
                                ),
                          (phoneNumberController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: phoneNumberController,
                                  enabled: false,
                                  maxLength: 10,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Phone Number",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (phoneNumberController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 0,
                                ),
                          (emailController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: emailController,
                                  enabled: false,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Email Id",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (emailController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16,
                                ),
                          (bioController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: bioController,
                                  enabled: false,
                                  keyboardType: TextInputType.text,
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 10.0, horizontal: 10.0),
                                      labelText: "Bio",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (bioController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16.0,
                                ),
                          (genderController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: genderController,
                                  enabled: false,
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Gender",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (genderController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16.0,
                                ),
                          (relationshipController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: relationshipController,
                                  enabled: false,
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Relationship",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (relationshipController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16,
                                ),
                          (linkController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: linkController,
                                  enabled: false,
                                  keyboardType: TextInputType.text,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Website",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (linkController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16,
                                ),
                          (workController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: workController,
                                  enabled: false,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Work",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (workController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16,
                                ),
                          (educationController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: educationController,
                                  enabled: false,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Education",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (educationController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16,
                                ),
                          (currentCityController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: currentCityController,
                                  enabled: false,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Current City",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (currentCityController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16,
                                ),
                          (pincodeController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: pincodeController,
                                  enabled: false,
                                  inputFormatters: [
                                    WhitelistingTextInputFormatter.digitsOnly
                                  ],
                                  keyboardType: TextInputType.number,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Pin Code",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                          (pincodeController.text == "")
                              ? Container()
                              : SizedBox(
                                  height: 16,
                                ),
                          (homeTownController.text == "")
                              ? Container()
                              : TextFormField(
                                  controller: homeTownController,
                                  enabled: false,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 5.0, horizontal: 10.0),
                                      labelText: "Home Town",
                                      labelStyle: TextStyle(
                                          color: Colors.deepPurple[300],
                                          fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 1))),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
