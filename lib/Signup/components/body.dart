import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart' as fl;
import 'package:flutter_svg/svg.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/Signup/components/background.dart';
import 'package:techstagram/Signup/components/or_divider.dart';
import 'package:techstagram/Signup/components/social_icon.dart';
import 'package:techstagram/components/already_have_an_account_acheck.dart';
import 'package:techstagram/components/rounded_button.dart';
import 'package:techstagram/components/text_field_container.dart';
import 'package:techstagram/resources/googlesignin.dart';
import 'package:techstagram/ui/HomePage.dart';

import '../../constants.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController firstNameInputController;
  TextEditingController lastNameInputController;
  TextEditingController phoneNumberController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;
  bool success = false;
  final FocusNode _firstName = FocusNode();
  final FocusNode _lastName = FocusNode();
  final FocusNode _phoneNumber = FocusNode();
  final FocusNode _email = FocusNode();
  final FocusNode _pwd = FocusNode();
  final FocusNode _confirmPwd = FocusNode();

  //final FocusNode _signup = FoucsNode();
  @override
  initState() {
    firstNameInputController = new TextEditingController();
    lastNameInputController = new TextEditingController();
    phoneNumberController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<FirebaseUser> facebookLogin(BuildContext context) async {
    FirebaseUser currentUser;
    // fbLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;
    // if you remove above comment then facebook login will take username and pasword for login in Webview
    try {
      final FacebookLoginResult facebookLoginResult =
      await fbLogin.logIn(['email']);
      if (facebookLoginResult.status == FacebookLoginStatus.loggedIn) {
        FacebookAccessToken facebookAccessToken =
            facebookLoginResult.accessToken;
        final AuthCredential credential = FacebookAuthProvider.getCredential(
            accessToken: facebookAccessToken.token);
        final AuthResult user = await auth.signInWithCredential(credential);
        assert(user.user.email != null);
        assert(user.user.displayName != null);
        assert(!user.user.isAnonymous);
        assert(await user.user.getIdToken() != null);
        currentUser = await auth.currentUser();
        assert(user.user.uid == currentUser.uid);
        return currentUser;
      }
    } catch (e) {
      print(e);
    }
    return currentUser;
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else {
      return null;
    }
  }

  String pwdValidator(String value) {
    if (value.length < 8) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  String validateMobile(String value) {
// Indian Mobile number are of 10 digit only

    if (value.length == null)
      return null;

    else if (value.length > 0 && value.length != 10)
      return 'Mobile Number must be of 10 digit';


    else
      return null;
  }

  String passwordmatchValidator(String value) {
// Indian Mobile number are of 10 digit only
    if (_pwd != _confirmPwd) {
      return 'passwords do not match';
    }
    else {
      return null;
    }
  }

  fl.FacebookLogin fbLogin = new fl.FacebookLogin();
  bool isFacebookLoginIn = false;
  String errorMessage = '';
  String successMessage = '';


  Future<FirebaseUser> loginWithTwitter(BuildContext context) async {
    FirebaseUser currentUser;
    var twitterLogin = new TwitterLogin(
      consumerKey: '5A5BOBPJhlu1PcymNvWYo7PST',
      consumerSecret: 'iKMjVT371WTyZ2nzmbW1YM59uAfIPobWOf1HSxvUHTflaeqdhu',
    );


    final TwitterLoginResult result = await twitterLogin.authorize();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        var session = result.session;
//        final FacebookLoginResult facebookLoginResult =
//        await fbLogin.logIn(['email']);
        final AuthCredential credential = TwitterAuthProvider.getCredential(
            authToken: session.token,
            authTokenSecret: session.secret
        );

        final AuthResult user = await auth.signInWithCredential(credential);
        assert(user.user.email == null);
        assert(user.user.displayName != null);
        assert(!user.user.isAnonymous);
        assert(await user.user.getIdToken() != null);
        currentUser = await auth.currentUser();
        assert(user.user.uid == currentUser.uid);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  HomePage(title:

                  "huhu",
                    uid: "h",
                  )),);
        return currentUser;

        break;
      case TwitterLoginStatus.cancelledByUser:
        break;
      case TwitterLoginStatus.error:
        break;
    }
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Form(
            key: _registerFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "SIGNUP",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: size.height * 0.005),
                SvgPicture.asset(
                  "assets/icons/signup.svg",
                  height: size.height * 0.20,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 10.0, top: 1.0, bottom: 1.0, left: 10.0),
                  child: Container(
                    height: 50.0,
                    width: 250.0,
                    child: TextFieldContainer(
                      child: TextFormField(

                        style: TextStyle(
                            fontSize: 12.0,
                            height: 2.0,
                            color: Colors.black
                        ),
                        textInputAction: TextInputAction.next,
                        focusNode: _firstName,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _firstName, _lastName);
                        },
//                            style: TextStyle(
//                                fontSize: 20.0,
//                                height: 2.0,
//                                color: Colors.black
//                            ),
                        cursorColor: kPrimaryColor,


                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 0, right: 3, top: 10, bottom: 8),
                          errorStyle: TextStyle(

                            fontSize: 10.0,
                            height: 0.3,
                          ),
                          icon: Icon(
                            Icons.person,
                            //  size: 12.0,
                            color: kPrimaryColor,
                          ),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                          hintText: "first name",
                        ),
                        controller: firstNameInputController,
                        // keyboardType: TextInputType.name,
//                      validator: emailValidator,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 10.0, top: 0.0, bottom: 0.0, left: 10.0),
                  child: Container(
                    height: 50.0,
                    width: 250.0,
                    child: TextFieldContainer(
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 12.0,
                            height: 2.0,
                            color: Colors.black
                        ),
                        textInputAction: TextInputAction.next,
                        focusNode: _lastName,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _lastName, _phoneNumber);
                        },
                        cursorColor: kPrimaryColor,


                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 0, right: 3, top: 10, bottom: 8),
                          errorStyle: TextStyle(

                            fontSize: 10.0,
                            height: 0.3,
                          ),
                          icon: Icon(
                            Icons.input,
                            color: kPrimaryColor,
                          ),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                          hintText: "last name",),
                        controller: lastNameInputController,
                        //  keyboardType: TextInputType.name,
//                      validator: emailValidator,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      right: 10.0, top: 0.0, bottom: 0.0, left: 10.0),
                  child: Container(
                    height: 50.0,
                    width: 250.0,
                    child: TextFieldContainer(
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 12.0,
                            height: 2.0,
                            color: Colors.black
                        ),
                        textInputAction: TextInputAction.next,
                        focusNode: _phoneNumber,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _phoneNumber, _email);
                        },
                        cursorColor: kPrimaryColor,

                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 3, top: 10, bottom: 8),
                            errorStyle: TextStyle(

                              fontSize: 10.0,
                              height: 0.3,
                            ),
                            icon: Icon(
                              Icons.phone_android,
                              color: kPrimaryColor,
                            ),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true,
                            hintText: "phone number"),
                        controller: phoneNumberController,
                        validator: validateMobile,
                        keyboardType: TextInputType.number,
//                      validator: emailValidator,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 10.0, top: 0.0, bottom: 0.0, left: 10.0),
                  child: Container(
                    height: 50.0,
                    width: 250.0,
                    child: TextFieldContainer(
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 12.0,
                            height: 2.0,
                            color: Colors.black
                        ),
                        textInputAction: TextInputAction.next,
                        focusNode: _email,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _email, _pwd);
                        },
                        cursorColor: kPrimaryColor,

                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 3, top: 10, bottom: 8),
                            errorStyle: TextStyle(

                              fontSize: 10.0,
                              height: 0.3,
                            ),
                            icon: Icon(
                              Icons.email,
                              color: kPrimaryColor,
                            ),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true,
                            hintText: "email"),
                        controller: emailInputController,
                        validator: emailValidator,
                        keyboardType: TextInputType.emailAddress,
//                      validator: emailValidator,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      right: 10.0, top: 0.0, bottom: 0.0, left: 10.0),
                  child: Container(
                    height: 50.0,
                    width: 250.0,
                    child: TextFieldContainer(
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 12.0,
                            height: 2.0,
                            color: Colors.black
                        ),
                        textInputAction: TextInputAction.next,
                        focusNode: _pwd,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _pwd, _confirmPwd);
                        },
                        cursorColor: kPrimaryColor,

                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 3, top: 10, bottom: 8),
                            errorStyle: TextStyle(

                              fontSize: 9.0,
                              height: 0.3,
                            ),
                            icon: Icon(
                              Icons.lock,
                              color: kPrimaryColor,
                            ),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true,
                            hintText: "create password"),
                        controller: pwdInputController,
                        validator: pwdValidator,
                        obscureText: true,
//                      validator: emailValidator,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(
                      right: 10.0, top: 0.0, bottom: 0.0, left: 10.0),
                  child: Container(
                    height: 50.0,
                    width: 250.0,
                    child: TextFieldContainer(
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 12.0,
                            height: 2.0,
                            color: Colors.black
                        ),
                        textInputAction: TextInputAction.done,
                        focusNode: _confirmPwd,
                        onFieldSubmitted: (value) {
                          _confirmPwd.unfocus();
                          RoundedButton;
                        },
                        cursorColor: kPrimaryColor,

                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 3, top: 10, bottom: 8),
                            errorStyle: TextStyle(

                              fontSize: 10.0,
                              height: 0.3,
                            ),
                            icon: Icon(
                              Icons.lock,
                              color: kPrimaryColor,
                            ),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true,
                            hintText: "confirm password"),
                        controller: confirmPwdInputController,
                        obscureText: true,
                        validator: passwordmatchValidator,
//                      validator: emailValidator,
                      ),
                    ),
                  ),
                ),

                RoundedButton(

                  text: "SIGNUP",
                  press: () {
                    if (_registerFormKey.currentState.validate()) {
                      if (pwdInputController.text ==
                          confirmPwdInputController.text) {
                        FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                            email: emailInputController.text,
                            password: pwdInputController.text)
                            .then((authResult) =>
                            Firestore.instance
                                .collection("users")
                                .document(authResult.user.uid)
                                .setData({
                              "uid": authResult.user.uid,
                              "fname": firstNameInputController.text,
                              "surname": lastNameInputController.text,
                              "phonenumber": phoneNumberController.text,
                              "email": emailInputController.text,
                            })
                                .then((result) =>
                            {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HomePage(
                                          )),
                                      (_) => false),
                              firstNameInputController.clear(),
                              lastNameInputController.clear(),
                              phoneNumberController.clear(),
                              emailInputController.clear(),
                              pwdInputController.clear(),
                              confirmPwdInputController.clear()
                            })
                                .catchError((err) => print(err)))
                            .catchError((err) => print(err));
                      } else {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Error"),
                                content: Text("The passwords do not match"),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text("Close"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      }
                    }
                  },
                ),
                SizedBox(height: size.height * 0.01),
                AlreadyHaveAnAccountCheck(
                  login: false,
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return LoginScreen();
                        },
                      ),
                    );
                  },
                ),
                OrDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SocalIcon(
                        iconSrc: "assets/icons/google-icon.svg",
                        press: () {
                          signInWithGoogle(success).whenComplete(() {
//                            if (success == true)
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return HomePage(
//                                    title: "Welcome",
                                  );
                                },
                              ),
                            );
                          });
                        }),
                    SocalIcon(
                      iconSrc: "assets/icons/facebook.svg",
                      press: () {
                        facebookLogin(context).then((user) {
                          print('Logged in successfully.');

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(title:

                                      "huhu",
                                        uid: "h",
                                      )),
                                  (_) => false);

                          setState(() {
                            isFacebookLoginIn = true;
                            successMessage =
                            'Logged in successfully.\nEmail : ${user
                                .email}\nYou can now navigate to Home Page.';
                          });
                        },);
                      },
                    ),
                    SocalIcon(
                      iconSrc: "assets/icons/twitter.svg",
                      press: () {
//                        Navigator.pushReplacementNamed(context, "/Twit");
                        loginWithTwitter(context).then((user) {
                          print('Logged in successfully.');
                        },
                        );
                      })
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

_fieldFocusChange(BuildContext context, FocusNode currentFocus,
    FocusNode nextFocus) {
  currentFocus.unfocus();
  FocusScope.of(context).requestFocus(nextFocus);
}