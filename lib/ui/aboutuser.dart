import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techstagram/components/text_field_container.dart';
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
      followersController,followingController,pinCodeController;

  Map<String, dynamic> _profile;
  bool _loading = false;

  DocumentSnapshot docSnap;
  FirebaseUser currUser;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _phoneVerificationKey = GlobalKey<FormState>();
  TextEditingController _otpController;

  AuthCredential _phoneAuthCredential;

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
    pinCodeController = TextEditingController();


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
      pinCodeController.text = docSnap.data["pincode"];
      relationshipController.text = docSnap.data["relationship"];

//      followersController.text = docSnap.data["followers"];
//      followingController.text = docSnap.data["following"];
      setState(() {
        isLoading = false;
        isEditable = true;
      });
    } on PlatformException catch (e) {
      print("PlatformException in fetching user profile. E  = " + e.message);
    }
  }

  bool errordikhaoN = false;
  bool _codesent = false;

  String validateMobile(String value) {
// Indian Mobile number are of 10 digit only

    if (value.length == null)
      return null;
    else if (value.length > 0 && value.length != 10)
      setState(() {
        errordikhaoN = true;
      });
    // return 'Mobile Number must be of 10 digit';

    else
      return null;
  }

  Future<void> _submitPhoneNumber() async {
    /// NOTE: Either append your phone number country code or add in the code itself
    /// Since I'm in India we use "+91 " as prefix `phoneNumber`
    String phoneNumber = "+91 " + phoneNumberController.text.toString().trim();
    print(phoneNumber);

    /// The below functions are the callbacks, separated so as to make code more readable
    void verificationCompleted(AuthCredential phoneAuthCredential) {
      print('verificationCompleted');

      this._phoneAuthCredential = phoneAuthCredential;
      print(phoneAuthCredential);
    }

    void verificationFailed(AuthException error) {

      print(error);
    }

    void codeSent(String verificationId, [int code]) {
      setState(() {
        _codesent = true;
      });

      print('codeSent');
    }

    void codeAutoRetrievalTimeout(String verificationId) {

      print('codeAutoRetrievalTimeout');
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      /// Make sure to prefix with your country code
      phoneNumber: phoneNumber,

      /// `seconds` didn't work. The underlying implementation code only reads in `milliseconds`
      timeout: Duration(milliseconds: 10000),

      /// If the SIM (with phoneNumber) is in the current device this function is called.
      /// This function gives `AuthCredential`. Moreover `login` function can be called from this callback
      verificationCompleted: verificationCompleted,

      /// Called when the verification is failed
      verificationFailed: verificationFailed,

      /// This is called after the OTP is sent. Gives a `verificationId` and `code`
      codeSent: codeSent,

      /// After automatic code retrival `tmeout` this function is called
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    ); // All the callbacks are above
  }




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("About me",style: TextStyle(
          color: Colors.deepPurple
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              height: 350.0,
              width: 450.0,

                // margin: EdgeInsets.only(top:200, bottom: 70,left: 20,right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[


                    Padding(
                      padding: const EdgeInsets.only(left: 20.0,top: 10.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          " Personal Details",
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
                      padding: const EdgeInsets.only(top: 20.0,left: 25.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text("First Name",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 99.0),
                                child: Text(firstNameController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),),
                              ),
                            ],
                          ),

                          Padding(padding: const EdgeInsets.all(2)),

                          Row(
                            children: [
                              Text("Last Name",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 99.0),
                                child: Text(lastNameController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),),
                              ),
                            ],
                          ),


                          Padding(padding: const EdgeInsets.all(2)),
                          Row(
                            children: [
                              Text("Phonenumber",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 70.0),
                                child: Text(phoneNumberController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),),
                              ),
                            ],
                          ),

                          Padding(padding: const EdgeInsets.all(2)),
                          Row(
                            children: [
                              Text("Username",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 70.0),
                                child: Text(displayNameController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            ],
                          ),

                          Padding(padding: const EdgeInsets.all(2)),
                          Row(
                            children: [
                              Text("Email",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 108.0),
                                child: Text(emailController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            ],
                          ),

                          Padding(padding: const EdgeInsets.all(2)),
                          Row(
                            children: [
                              Text("Gender",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 119.0),
                                child: Text(genderController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            ],
                          ),
                          Padding(padding: const EdgeInsets.all(2)),
                          Row(
                            children: [
                              Text("Relationship",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 83.0),
                                child: Text(relationshipController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            ],
                          ),

                          Padding(padding: const EdgeInsets.all(2)),
                          Row(
                            children: [
                              Text("Work",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 132.0),
                                child: Text(workController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            ],
                          ),
                          Padding(padding: const EdgeInsets.all(2)),
                          Row(
                            children: [
                              Text("Education",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 100.0),
                                child: Text(educationController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            ],
                          ),

                          Padding(padding: const EdgeInsets.all(2)),
                          Row(
                            children: [
                              Text("Current City",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 86.0),
                                child: Text(currentCityController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),),
                              ),
                            ],
                          ),

                          Padding(padding: const EdgeInsets.all(2)),
                          Row(
                            children: [
                              Text("Pin Code",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 102.0),
                                child: Text(pinCodeController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),),
                              ),
                            ],
                          ),

                          Padding(padding: const EdgeInsets.all(2)),
                          Row(
                            children: [
                              Text("HomeTown",style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 86.0),
                                child: Text(homeTownController.text,style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
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

            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Verify phone",style:
                  TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0
                  ),),
              ),
            ),

            Container(
              child: Form(
                key: _phoneVerificationKey,
                child: Row(
                  children: [
                    Container(
                    height: 50.0,
                    width: 230.0,
                    child: TextFieldContainer(
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 12.0, height: 1.5, color: Colors.black),
                        textInputAction: TextInputAction.next,
                        cursorColor: kPrimaryColor,

                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 0, right: 3, top: 6, bottom: 12),
                          errorStyle: TextStyle(
                            fontSize: 10.0,
                            height: 0.3,
                          ),
                          icon: Icon(
                            Icons.phone_iphone,
                            //  size: 12.0,
                            color: kPrimaryColor,
                          ),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                          hintText: "Phone Number",
                        ),
                    controller: phoneNumberController,
                        //enableInteractiveSelection: false,
                      keyboardType: TextInputType.number,
                      validator: validateMobile,
                      ),
                    ),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(child: Text("Verify",style: TextStyle(
                        color: Colors.white,
                      ),),
                          color: Colors.deepPurple,
                          onPressed: (){
    if (_phoneVerificationKey.currentState.validate()) {
          _submitPhoneNumber();
          if(_codesent){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return SubmitPhoneOTP();
                },
              ),
            );
          }
    }
                          }),
                    ),
                  ],
                ),
            )
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text("Verify email",style:
                TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0
                ),),
              ),
            ),

            Container(
                child: Form(
                  child: Row(
                    children: [
                      Container(
                        height: 50.0,
                        width: 230.0,
                        child: TextFieldContainer(
                          child: TextFormField(
                            style: TextStyle(
                                fontSize: 12.0, height: 1.5, color: Colors.black),
                            textInputAction: TextInputAction.next,
//                    focusNode: _firstName,
//                    onFieldSubmitted: (term) {
//                      _fieldFocusChange(context, _firstName, _lastName);
//                    },
//                            style: TextStyle(
//                                fontSize: 20.0,
//                                height: 2.0,
//                                color: Colors.black
//                            ),
                            cursorColor: kPrimaryColor,



                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 0, right: 3, top: 6, bottom: 12),
                              errorStyle: TextStyle(
                                fontSize: 10.0,
                                height: 0.3,
                              ),
                              icon: Icon(
                                Icons.alternate_email,
                                //  size: 12.0,
                                color: kPrimaryColor,
                              ),
                              fillColor: Colors.deepPurple.shade50,
                              filled: true,
                              hintText: "Email address",
                            ),
//                    controller: firstNameInputController,
                            //enableInteractiveSelection: false,
                            // keyboardType: TextInputType.name,
//                      validator: emailValidator,
                          ),
                        ),),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RaisedButton(child: Text("Verify",style: TextStyle(
                          color: Colors.white,
                        ),),
                            color: Colors.deepPurple,
                            onPressed: (){}),
                      ),
                    ],
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}

class SubmitPhoneOTP extends StatefulWidget {
  @override
  _SubmitPhoneOTPState createState() => _SubmitPhoneOTPState();
}

class _SubmitPhoneOTPState extends State<SubmitPhoneOTP> {
  TextEditingController _otpController;
  AuthCredential _phoneAuthCredential;
  String _verificationId;

  void _submitOTP() {
    /// get the `smsCode` from the user
    String smsCode = _otpController.text.toString().trim();

    /// when used different phoneNumber other than the current (running) device
    /// we need to use OTP to get `phoneAuthCredential` which is inturn used to signIn/login
    this._phoneAuthCredential = PhoneAuthProvider.getCredential(
        verificationId: this._verificationId, smsCode: smsCode);

  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Form(
        child: Row(
        children: [
        Container(
        height: 50.0,
        width: 250.0,
        child: TextFieldContainer(
          child: TextFormField(
            style: TextStyle(
                fontSize: 12.0, height: 1.5, color: Colors.black),
            textInputAction: TextInputAction.next,
            cursorColor: kPrimaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(
                  left: 0, right: 3, top: 6, bottom: 12),
              errorStyle: TextStyle(
                fontSize: 10.0,
                height: 0.3,
              ),
              icon: Icon(
                Icons.textsms,
                //  size: 12.0,
                color: kPrimaryColor,
              ),
              fillColor: Colors.deepPurple.shade50,
              filled: true,
              hintText: "Enter OTP",
            ),
          ),
        ),),


      Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(child: Text("Verify",style: TextStyle(
      color: Colors.white,
      ),),
      color: Colors.deepPurple,
      onPressed: (){
        _submitOTP();
      })),
      ],
      ),
      ),
      ),
    );
  }
}