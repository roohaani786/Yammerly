import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';

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
      phoneNumberController,
  bioController;

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
    bool isChanged = false;
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
      print("Phone Number Changed");
      isChanged = true;
    }

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
    Firestore.instance
        .collection("users")
        .document(currUser.uid)
        .setData(data, merge: true);
    snackbarContent = "Profile Updated";
    if(snackbarContent == "Profile Updated"){

      Navigator.pushNamed(context, '/Profile');
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
                    TextFormField(
                      controller: firstNameController,
                      enabled: isEditable,
                      decoration: InputDecoration(
                          labelText: "First Name",
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
                          labelText: "Last Name",
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
                      maxLines: 5,
                      decoration: InputDecoration(
                          labelText: "Bio",
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
                          labelText: "Email Id",
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
                          labelText: "Phone Number",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.black, width: 1))),
                    ),
//
                  ],
                ),
              ),
      ),
//      floatingActionButton: FloatingActionButton(
//          child:
//              Icon(isEditable ? Icons.check : Icons.edit, color: Colors.white),
//          backgroundColor: Colors.black,
//          onPressed: () async {
//            if (!isEditable)
//              setState(() => isEditable = true);
//            else {
//              bool isChanged = false;
//              if (docSnap.data["fname"].toString().trim() !=
//                  firstNameController.text.trim()) {
//                print("First Name Changed");
//                isChanged = true;
//              } else if (docSnap.data["surname"].toString().trim() !=
//                  lastNameController.text.trim()) {
//                print("Last Name Changed");
//                isChanged = true;
//              } else if (docSnap.data["email"].toString().trim() !=
//                  emailController.text.trim()) {
//                print("Email Changed");
//                isChanged = true;
//              } else if (docSnap.data["phonenumber"].toString().trim() !=
//                  phoneNumberController.text.trim()) {
//                print("Phone Number Changed");
//                isChanged = true;
//              }
//
//              if (isChanged) {
//                String snackbarContent = "";
//                setState(() => isLoading = true);
//                try {
//                  Map<String, dynamic> data = {};
//                  data["fname"] = firstNameController.text.trim();
//                  data["surname"] = lastNameController.text.trim();
//                  data["phonenumber"] = phoneNumberController.text.trim();
//                  data["email"] = emailController.text.trim();
//                  Firestore.instance
//                      .collection("users")
//                      .document(currUser.uid)
//                      .setData(data, merge: true);
//                  snackbarContent = "Profile Updated";
//                  try {
//                    await currUser.updateEmail(data["email"]);
//                    snackbarContent =
//                        snackbarContent + ". Login Email Also Updated";
//                  } on PlatformException catch (e) {
//                    print(
//                        "AUTHEXCEPTION. FAILED TO CHANGE FIREBASE AUTH EMAIL. E = " +
//                            e.message.toString());
//                    snackbarContent = snackbarContent +
//                        ". Login Email Not Changed (As Not Recently Logged In)";
//                  } catch (e) {
//                    print("ERROR. FAILED TO CHANGE FIREBASE AUTH EMAIL. E = " +
//                        e.toString());
//                    snackbarContent = snackbarContent +
//                        ". Login Email Not Changed (As Not Recently Logged In)";
//                  }
//                  fetchProfileData();
//                } on PlatformException catch (e) {
//                  print("PlatformException in fetching user profile. E  = " +
//                      e.message);
//                  snackbarContent = "Failed To Update Profile";
//                }
//                _scaffoldKey.currentState.showSnackBar(SnackBar(
//                  content: Text(snackbarContent),
//                  duration: Duration(milliseconds: 3000),
//                  behavior: SnackBarBehavior.floating,
//                ));
//              } else {
//                setState(() => isEditable = false);
//              }
//            }
//          }),
    );
  }
}
