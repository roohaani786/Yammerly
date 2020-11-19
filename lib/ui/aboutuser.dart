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
import 'package:string_validator/string_validator.dart';
import 'package:techstagram/constants.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/services/database.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:techstagram/ui/ProfilePage.dart';
import 'package:image/image.dart' as ImD;
//import 'package:fluttertoast/fluttertoast.dart';



class AboutUser extends StatefulWidget {
  static final String pageName = "/ProfilePage";
  //final User user;
  String uid;
  AboutUser({this.uid});
  //const AboutOtherUser({this.user, Key key}) : super(key: key);

  @override
  _AboutUserState createState() => _AboutUserState(uid: uid);
}

class _AboutUserState extends State<AboutUser> {

  String uid;
  _AboutUserState({this.uid});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
          .document(uid)
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

  final StorageReference storageReference =
  FirebaseStorage.instance.ref().child("Display Pictures");
  final postReference = Firestore.instance.collection("users");





  bool isChanged = false;
  String relationstring = "Select Relationship";
  String genderstring = "Select Gender";

  String _male = "male";
  String _female = "female";
  String _other = "other";
  String _value;
  bool tickvalue = false;
  int check;
  void _handleRadioValueChange1(String value) {
    setState(() {
      _value = value;
      if(_value=="Male"){
        setState(() {
          check = 0;
        });
      }else if(_value=="Female"){
        setState(() {
          check = 1;
        });
      }else if(_value == "other"){
        setState(() {
          check = 2;
          print(tickvalue);
          tickvalue = true;
        });
      }
      else{
        setState(() {
          tickvalue = false;
        });
      }

      switch (check) {
        case 0:
          genderController.text = _male;
          //correctScore++;
          break;
        case 1:
          genderController.text = _female;
          break;
        case 2:
          genderController.text = _other;
          break;
        default:
          genderController.text = null;
      }
    });
  }


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
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back,
            color: Colors.black,),
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
                "About Me",
                style: TextStyle(
                    fontFamily: "Cookie-Regular", fontSize: 25.0),
              ),
              SizedBox(
                height: 16,
              ),
              CircleAvatar(
                radius: 50,
                backgroundImage: (isChanged == false)?NetworkImage(photoUrlController.text):AssetImage("assets/images/loading.gif"),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(
                height: 16,
              ),

              Form(
                autovalidate: true,
                key: _formKey,
                child: Column(children: <Widget>[

                  TextFormField(
                    controller: displayNameController,
                    enabled: false,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Display Name",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),

                  SizedBox(
                    height: 16.0,
                  ),

                  TextFormField(
                    controller: firstNameController,
                    enabled: false,

                    decoration: InputDecoration(
                        labelText: "First Name",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
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
                    enabled: false,
                    decoration: InputDecoration(
                        labelText: "Last Name",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
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
                    enabled: false,
                    maxLength: 10,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: "Phone Number",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
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
                    enabled: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: "Email Id",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
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
                    enabled: false,
                    keyboardType: TextInputType.text,
                    maxLines: 3,
                    decoration: InputDecoration(
                        labelText: "Bio",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),

                  SizedBox(
                    height: 16.0,
                  ),

                  TextFormField(
                    controller: genderController,
                    enabled: false,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Gender",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),



                  SizedBox(
                    height: 16.0,
                  ),

                  TextFormField(
                    controller: relationshipController,
                    enabled: false,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Relationship",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
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
                    enabled: false,
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Website",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
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
                    enabled: false,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Work",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
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
                    enabled: false,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Education",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
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
                    enabled: false,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Current City",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
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
                    enabled: false,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Pin Code",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
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
                    enabled: false,
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    decoration: InputDecoration(
                        labelText: "Home Town",labelStyle: TextStyle(
                        color: Colors.deepPurple[300],fontWeight: FontWeight.bold
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
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