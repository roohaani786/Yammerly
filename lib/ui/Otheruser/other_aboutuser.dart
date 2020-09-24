import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:techstagram/components/text_field_container.dart';
import 'package:techstagram/constants.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/services/database.dart';




class AboutOtherUser extends StatefulWidget{
  final String uid;
  final String displayNamecurrentUser;
  final String displayName;

  AboutOtherUser({this.uid,this.displayNamecurrentUser,this.displayName});
  @override
  _AboutOtherUserState createState() => _AboutOtherUserState(uid: uid,displayNamecurrentUser: displayNamecurrentUser,displayName: displayName);
}

class _AboutOtherUserState extends State<AboutOtherUser> {

  final String uid;
  final String displayNamecurrentUser;
  final String displayName;

  _AboutOtherUserState({this.uid,this.displayNamecurrentUser,this.displayName});
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


  bool errordikhaoN = false;
  bool _codesent = false;

//  String validateMobile(String value) {
//// Indian Mobile number are of 10 digit only
//
//    if (value.length == null)
//      return null;
//    else if (value.length > 0 && value.length != 10)
//      setState(() {
//        errordikhaoN = true;
//      });
//    // return 'Mobile Number must be of 10 digit';
//
//    else
//      return null;
//  }

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

    Stream userQuery;
    userQuery = Firestore.instance.collection('users')
        .where('uid', isEqualTo: uid)
        .snapshots();
    // TODO: implement build
    return Scaffold(

      key: _scaffoldKey,
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("About me",style: TextStyle(
            color: Colors.deepPurple
        ),),
      ),
      body: StreamBuilder(
    stream: userQuery,
    builder: (context, snapshot) {
    return snapshot.hasData
    ?
    ListView.builder(
    itemCount: snapshot.data.documents.length,
    itemBuilder: (context, index) {
    DocumentSnapshot sd = snapshot.data.documents[index];
    String photoUrl = snapshot.data.documents[index]["photoUrl"];
    String uid = snapshot.data.documents[index]["uid"];
    String displayName = snapshot.data.documents[index]["displayName"];
    String firstName = snapshot.data.documents[index]["fname"];
    String lastName = snapshot.data.documents[index]["surname"];
    String phoneNumber = snapshot.data.documents[index]["phonenumber"];
    String email = snapshot.data.documents[index]["email"];
    String gender = snapshot.data.documents[index]["gender"];
    String relationship = snapshot.data.documents[index]["relationship"];
    String work = snapshot.data.documents[index]["work"];
    String education = snapshot.data.documents[index]["education"];
    String currentCity = snapshot.data.documents[index]["currentCity"];
    String homeTown = snapshot.data.documents[index]["homeTown"];
    String pinCode = snapshot.data.documents[index]["pincode"];
    String bio = snapshot.data.documents[index]["bio"];
    int followers = snapshot.data.documents[index]["followers"];
    int following = snapshot.data.documents[index]["following"];
    int posts = snapshot.data.documents[index]["posts"];
    return (uid != null || displayName!=null) ?
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top:100.0, left: 10.0, right: 10.0),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                    child: Container(
                      height: 370.0,
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
                                  fontSize: 18.0,
                                  color: kPrimaryColor,
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
                                    Container(
                                      width: 150.0,
                                      child: Text("First Name",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Text(firstName,style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),),
                                  ],
                                ),

                                Padding(padding: const EdgeInsets.all(2)),

                                Row(
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: Text("Last Name",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Text(lastName,style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),),
                                  ],
                                ),


                                Padding(padding: const EdgeInsets.all(2)),
                                Row(
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: Text("Phonenumber",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Text(phoneNumber,style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),),
                                  ],
                                ),

                                Padding(padding: const EdgeInsets.all(2)),
                                Row(
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: Text("Username",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Text(displayName,style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                  ],
                                ),

                                Padding(padding: const EdgeInsets.all(2)),
                                Row(
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: Text("Email",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Container(
                                      width: 100.0,
                                      child: Text(email,style: TextStyle(
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
                                    Container(
                                      width: 150.0,
                                      child: Text("Gender",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    (gender!=null)?Text(gender,style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),):Text("",style: TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                    ),)
                                  ],
                                ),
                                Padding(padding: const EdgeInsets.all(2)),
                                Row(
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: Text("Relationship",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Text((relationship!=null)?relationship:"",style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                  ],
                                ),

                                Padding(padding: const EdgeInsets.all(2)),
                                Row(
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: Text("Work",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Text((work!=null)?work:"",style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                  ],
                                ),
                                Padding(padding: const EdgeInsets.all(2)),
                                Row(
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: Text("Education",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Text((education!=null)?work:"",style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                  ],
                                ),

                                Padding(padding: const EdgeInsets.all(2)),
                                Row(
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: Text("Current City",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Text((currentCity!=null)?currentCity:"",style: TextStyle(
                                      color: kPrimaryColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),),
                                  ],
                                ),

                                Padding(padding: const EdgeInsets.all(2)),
                                Row(
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: Text("Pin Code",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Text((pinCode!=null)?pinCode:"",style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),),
                                  ],
                                ),

                                Padding(padding: const EdgeInsets.all(2)),
                                Row(
                                  children: [
                                    Container(
                                      width: 150.0,
                                      child: Text("HomeTown",style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),),
                                    ),
                                    Text((homeTown!=null)?homeTown:"",style: TextStyle(
                                      color: kPrimaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),),
                                  ],
                                ),
                              ],
                            ),
                          ),




                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ): Container();
    },
    ):Container();
    },
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