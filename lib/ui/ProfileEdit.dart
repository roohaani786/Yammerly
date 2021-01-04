import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:string_validator/string_validator.dart';
import 'package:techstagram/constants.dart';
import 'package:techstagram/models/user.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:image/image.dart' as ImD;
import 'dart:math';

class ProfilePage extends StatefulWidget {
  static final String pageName = "/ProfilePage";
  final User user;

  const ProfilePage({this.user, Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

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

  Future pickImage() async {
    await ImagePicker.pickImage(source: ImageSource.gallery).then((image) {
      setState(() {
        _image = image;
      });
    });
    uploadFile();
    return ProfilePage();
  }


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
  String Purl;

  final StorageReference storageReference =
  FirebaseStorage.instance.ref().child("Display Pictures");
  final postReference = Firestore.instance.collection("users");

  savePostInfoToFirestore(String url,String uid) {
    postReference.where('uid', isEqualTo: uid).getDocuments()
        .then((docs) {
      Firestore.instance.document(uid).updateData({'photoUrl': url}).then((val) {
        print("update ho gaya");
      });
    });
    // postReference.document(uid).updateData({
    //   "photoURL": url,
    // });


    setState(() {
      isChanged = false;
    });

    print(photoUrlController.text);
    return ProfilePage();
  }

  Future uploadFile() async {

    if(_image!=null){
      await compressPhoto();
    }

    Random randomno = new Random();

    StorageReference storageReference =

    FirebaseStorage.instance
        .ref()
        .child('users/${randomno.nextInt(5000).toString()}.jpg');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) {
      setState(() {

        photoUrlController.text = fileURL;
        Purl = fileURL;

      });
    });
    savePostInfoToFirestore(Purl,uidController.text);
  }


  Future pickImagefromCamera() async {
    await ImagePicker.pickImage(source: ImageSource.camera).then((image) {
      setState(() {
        _image = image;
      });
    });
    uploadFile();
    return ProfilePage();

  }


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
              if(_formKey.currentState.validate()) {
                if (!isEditable) {
                  setState(() => isEditable = true);
                }
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
                  } else if (docSnap.data["gender"].toString().trim() !=
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
//      DatabaseService().updatephotoURL(uidController.text,photoUrlController.text);
                    print("photoUrl Changed");
                    isChanged = true;
                  } //displayName

                  else if (docSnap.data["work"].toString().trim() !=
                      workController.text.trim()) {
                    print("work Changed");
                    isChanged = true;
                  }//work

                  else if (docSnap.data["education"].toString().trim() !=
                      educationController.text.trim() && educationController.text.length > 10.0) {
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



                  else if (docSnap.data["pincode"].toString().trim() !=
                      pincodeController.text.trim()) {
                    print("Pincode Changed");
                    isChanged = true;
                  }//relationship

                  // else if (firstNameController.text!="" && firstNameController.text.length < 10.0){
                  //   isChanged = true;
                  //   firstnameE = true;
                  // }
                  //
                  // else if (lastNameController.text != "" && lastNameController.text.length <10){
                  //   isChanged = true;
                  //   lastnameE = true;
                  // }
                  //
                  // else if (phoneNumberController.text != "" && phoneNumberController.text.length == 10){
                  //   isChanged = true;
                  //   phonenumberE = true;
                  // }
                  //
                  // else if (emailController.text != "" && emailController.text.length < 25){
                  //   isChanged = true;
                  //   emailE = true;
                  // }
                  //
                  // else if (bioController.text.length < 50.0){
                  //   isChanged = true;
                  //   bioE = true;
                  // }
                  //
                  // else if (linkController.text.length < 25.0){
                  //   isChanged = true;
                  //   websiteE = true;
                  // }
                  //
                  // else if(educationController.text.length < 10.0){
                  //   isChanged = true;
                  //   educationE = true;
                  // }
                  //
                  // else if(currentCityController.text.length < 10.0){
                  //   isChanged = true;
                  //   currentcityE = true;
                  // }
                  //
                  // else if (homeTownController.text.length < 15.0){
                  //   isChanged = true;
                  //   hometownE = true;
                  // }

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
                          .document(uidController.text)
                          .setData(data, merge: true);
                      print(uidController.text);
                      print("babbu bhai bhai");
//    DatabaseService().updatePostdisplayName(uidController.text,displayNameController.text);
//    DatabaseService().updatephotoURL(displayNameController.text,photoUrlController.text);
                      snackbarContent = "Profile Updated";
                      if(snackbarContent == "Profile Updated"){

                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => HomePage()));
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
              }else{
                print("error hai bro");
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
                        return AlertDialog(
                          title: Text('Select image from :-',style: TextStyle(
                            fontSize: 15.0,
                          ),),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: (){
                                    pickImagefromCamera();
                                    Navigator.of(context, rootNavigator: true).pop(context);
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
                                      Navigator.of(context, rootNavigator: true).pop(context);
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
                        );

                      });
                },
                child: Container(
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
                        image: (isChanged == false) ? NetworkImage(
                            photoUrlController.text) : AssetImage(
                            "assets/images/loading.gif"),
                        fit: BoxFit.cover,
                      ),
                      //backgroundImage: NetworkImage(photoUrlController.text)
                    )
                ),

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
                    enabled: isEditable,
                    validator: (value) {
                      if(value.length > 20.0){
                        return 'Username should not be greater than 20 words';
                      }else if(value.length ==0){
                        return 'Username should not be null';
                      }else if(!isLowercase(value)){
                        return 'Username must be in lower case';
                      }else if(value.contains(" ")){
                        return 'Remove space';
                      }
                    },
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        labelText: "Username",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),

                  SizedBox(
                    height: 20.0,
                  ),

                  Container(
                    child: Row(
                      children: [
                        Container(
                          width:MediaQuery.of(context).size.width*0.45,
                          height: 70.0,
                          child: TextFormField(
                            controller: firstNameController,
                            enabled: isEditable,
                            validator: (value) {
                              if(value.length > 15.0){
                                return 'Less then 15 words';
                              }else if(value.length == 0){
                                return 'Should Not blank';
                              }
                            },
                            decoration: InputDecoration(
                                errorStyle: TextStyle(
                                  //fontSize: 10.0,
                                    height: 0.3
                                ),
                                contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                labelText: "First Name",labelStyle: TextStyle(
                                color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                            ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                    BorderSide(color: Colors.black, width: 1))),
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.01,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width*0.45,
                          height: 70.0,
                          child: TextFormField(
                            controller: lastNameController,
                            enabled: isEditable,
                            validator: (value) {
                              if(value.length > 15.0) {
                                return 'Less then 15 words';
                              }
                              // }else if(value.length == 0){
                              //   return 'Null value';
                              // }
                            },
                            decoration: InputDecoration(
                                errorStyle: TextStyle(
                                  //fontSize: 10.0,
                                    height: 0.3
                                ),
                                contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                labelText: "Last Name",labelStyle: TextStyle(
                                color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                            ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                    BorderSide(color: Colors.black, width: 1))),
                          ),
                        ),
                      ],
                    ),
                  ),


                  TextFormField(
                    controller: phoneNumberController,
                    enabled: isEditable,
                    validator: (value) {
                      if(value.length < 10.0 && value.length > 0){
                        return 'Phone number should be of 10 digit';
                      }else if(value.length > 10.0){
                        return 'Phone number should be of 10 digit';
                      }
                    },
                    //maxLength: 10,
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        labelText: "Phone Number",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller: emailController,
                    enabled: isEditable,
                    validator: (value) {

                      if(value.length > 30.0){
                        return 'email should not be greater than 30 words';

                      }else if(value.length ==0){
                        return 'email should not be null';
                      }
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        labelText: "Email Id",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),

                  SizedBox(
                    height: 20,
                  ),


                  TextFormField(
                    controller: bioController,
                    enabled: isEditable,
                    validator: (value) {
                      if(value.length > 50.0){
                        return 'bio should not be greater than 50';
                      }
                    },
                    keyboardType: TextInputType.text,
                    maxLines: 2,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        labelText: "Bio",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),


                  Container(
                    width: MediaQuery.of(context).size.width*1,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: new Text(
                                'Gender :',
                                style: new TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                    color: Colors.deepPurple
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: new DropdownButton<String>(
                                hint: Padding(
                                  padding: const EdgeInsets.only(left: 13.0),
                                  child: (genderController.text == "")?Text(genderstring):Text(genderController.text),
                                ),
                                items: <String>['Male', 'Female','Others'].map((String value) {
                                  return new DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  genderController.text = value;
                                  setState(() {
                                    genderstring = value;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                        Align(
                          //padding: const EdgeInsets.only(left: 88.0),
                          alignment: Alignment.centerRight,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: new Text(
                                    'Relationship :',
                                    style: new TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0,
                                        color: Colors.deepPurple
                                    ),
                                  ),
                                ),
                              ),

                              Align(
                                alignment: Alignment.centerRight,
                                child: new DropdownButton<String>(
                                  hint: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: (relationshipController.text=="")?Text(relationstring):Text(relationshipController.text),
                                  ),
                                  items: <String>['Single', 'Engaged'].map((String value) {
                                    return new DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    relationshipController.text = value;
                                    setState(() {
                                      relationstring = value;
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),



                  SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller: linkController,
                    enabled: isEditable,
                    validator: (value) {
                      if(value.length > 20.0){
                        return 'Website link should not be greater than 20 words';
                      }
                    },
                    keyboardType: TextInputType.text,
                    maxLines: 1,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        labelText: "Website",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller: workController,
                    enabled: isEditable,
                    validator: (value) {
                      if(value.length > 35.0){
                        return 'Work should not be greater than 35 words';
                      }
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        labelText: "Work",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller: educationController,
                    enabled: isEditable,
                    validator: (value) {
                      if(value.length > 30.0){
                        return 'Education should not be greater then 30 words';
                      }
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        labelText: "Education",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller: currentCityController,
                    enabled: isEditable,
                    validator: (value) {
                      if(value.length > 15.0){
                        return 'Current city should not be greater than 15 words';
                      }
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        labelText: "Current City",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller: pincodeController,
                    enabled: isEditable,
                    validator: (value) {
                      if(value.length > 6.0){
                        return 'pin code should be of 6 digit';
                      }
                      // else if(value.length < 6){
                      //   return 'pin code should be of 6 digit';
                      // }
                    },
                    inputFormatters: [
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        labelText: "Pin Code",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
                    ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                            BorderSide(color: Colors.black, width: 1))),
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  TextFormField(
                    controller: homeTownController,
                    enabled: isEditable,
                    validator: (value) {
                      if(value.length > 15.0){
                        return 'Home town should not be greater then 15 words';
                      }
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: 1,
                    decoration: InputDecoration(
                        contentPadding: new EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        labelText: "Home Town",labelStyle: TextStyle(
                        color: Colors.deepPurple,fontWeight: FontWeight.bold,fontSize: 13.0
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




