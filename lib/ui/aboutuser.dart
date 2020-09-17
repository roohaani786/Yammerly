import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/services/database.dart';

import '../constants.dart';

class AboutUser extends StatefulWidget{
  @override
  _AboutUserState createState() => _AboutUserState();
}

class _AboutUserState extends State<AboutUser> {
  bool isLoading = true;
  bool isEditable = false;
  String loadingMessage = "Loading Profile Data";
  TextEditingController firstNameController,
      lastNameController,
      emailController,
      phoneNumberController,
      bioController,genderController,linkController,photoUrlController,
      displayNameController,workController,educationController,
      currentCityController,homeTownController,relationshipController,
      followersController,followingController;

  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
  FirebaseUser currUser;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
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

    followersController = TextEditingController();
    followingController = TextEditingController();


    super.initState();
    // Subscriptions are created here
    authService.profile.listen((state) => setState(() => _profile = state));

    authService.loading.listen((state) => setState(() => _loading = state));

    fetchProfileData();
  }

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

      followersController.text = docSnap.data["followers"];
      followingController.text = docSnap.data["following"];
      setState(() {
        isLoading = false;
        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("About me",style: TextStyle(
          color: Colors.deepPurple
        ),),
      ),
      body: Container(
        height: 300.0,
        width: 340.0,
        child: Card(
          elevation: 5.0,
          color: Colors.white,
          // margin: EdgeInsets.only(top:200, bottom: 70,left: 20,right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[


              Padding(
                padding: const EdgeInsets.only(left: 20.0,top: 10.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    " Account Information",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Pacifico',
                    ),
                  ),

                ),
              ),


              Padding(
                padding: const EdgeInsets.only(top: 10.0,left: 25.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text("First Name",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 99.0),
                          child: Text(firstNameController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
                    ),

                    Padding(padding: const EdgeInsets.all(2)),

                    Row(
                      children: [
                        Text("Last Name",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 99.0),
                          child: Text(lastNameController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
                    ),
                    Padding(padding: const EdgeInsets.all(2)),
                    Row(
                      children: [
                        Text("Username",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 102.0),
                          child: Text(displayNameController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
                    ),

                    Padding(padding: const EdgeInsets.all(2)),
                    Row(
                      children: [
                        Text("Phonenumber",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 75.0),
                          child: Text(phoneNumberController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
                    ),

                    Padding(padding: const EdgeInsets.all(2)),
                    Row(
                      children: [
                        Text("Username",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 100.0),
                          child: Text(displayNameController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
                    ),

                    Padding(padding: const EdgeInsets.all(2)),
                    Row(
                      children: [
                        Text("Gender",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 119.0),
                          child: Text(genderController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
                    ),
                    Padding(padding: const EdgeInsets.all(2)),
                    Row(
                      children: [
                        Text("Relationship",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 83.0),
                          child: Text(relationshipController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
                    ),

                    Padding(padding: const EdgeInsets.all(2)),
                    Row(
                      children: [
                        Text("Work",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 132.0),
                          child: Text(workController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
                    ),
                    Padding(padding: const EdgeInsets.all(2)),
                    Row(
                      children: [
                        Text("Education",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 100.0),
                          child: Text(educationController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
                    ),

                    Padding(padding: const EdgeInsets.all(2)),
                    Row(
                      children: [
                        Text("Current City",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 86.0),
                          child: Text(currentCityController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
                    ),

                    Padding(padding: const EdgeInsets.all(2)),
                    Row(
                      children: [
                        Text("HomeTown",style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),),
                        Padding(
                          padding: const EdgeInsets.only(left: 91.0),
                          child: Text(homeTownController.text,style: TextStyle(
                            color: kPrimaryColor,
                          ),),
                        ),
                      ],
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