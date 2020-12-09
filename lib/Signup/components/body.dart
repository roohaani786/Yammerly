import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart' as fl;
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/Signup/components/background.dart';
import 'package:techstagram/Signup/components/or_divider.dart';
import 'package:techstagram/Signup/components/social_icon.dart';
import 'package:techstagram/components/already_have_an_account_acheck.dart';
import 'package:techstagram/components/rounded_button.dart';
import 'package:techstagram/components/text_field_container.dart';
import 'package:techstagram/resources/auth.dart';
import 'package:techstagram/ui/HomePage.dart';
import 'package:flutter/services.dart';

import '../../constants.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  TextEditingController firstNameInputController;
  TextEditingController lastNameInputController;
  TextEditingController displayNameInputController;
  TextEditingController phoneNumberController;
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  TextEditingController confirmPwdInputController;
  bool success = false;
  final FocusNode _firstName = FocusNode();
  final FocusNode _lastName = FocusNode();
  final FocusNode _displayName = FocusNode();
  final FocusNode _phoneNumber = FocusNode();
  final FocusNode _email = FocusNode();
  final FocusNode _pwd = FocusNode();
  final FocusNode _confirmPwd = FocusNode();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _obscureText = true;
  bool _obscureText1 = true;
  bool isUserSignedIn = false;
  bool facebooksuccess = false;

  //final FocusNode _signup = FoucsNode();
  @override
  initState() {
    firstNameInputController = new TextEditingController();
    lastNameInputController = new TextEditingController();
    displayNameInputController = new TextEditingController();
    phoneNumberController = new TextEditingController();
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
    confirmPwdInputController = new TextEditingController();
    super.initState();
    checkIfUserIsSignedIn();
  }

  void checkIfUserIsSignedIn() async {
    var userSignedIn = await googleSignIn.isSignedIn();

    setState(() {
      isUserSignedIn = userSignedIn;
    });
  }


  void onGoogleSignIn(BuildContext context) async {
    final valid = await usernameCheck(displayNameInputController.text);
    if (!valid) {
      showDialog(
          context: context,
          builder: (BuildContext context) {

            return AlertDialog(
              title: Text("Error"),
              content: Text("Display name already exists!", style: TextStyle(
                  color: Colors.deepPurple
              )),
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
    else {
      FirebaseUser user = await authService.hellogoogleSignIn();
      print(user);
      var userSignedIn = await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false,
      );

      setState(() {
        isUserSignedIn = userSignedIn == null ? true : false;
      });
    }
  }

  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;
  PublishSubject loading = PublishSubject();

  Future<FirebaseUser> facebookLogin(BuildContext context) async {
    loading.add(true);


    var facebookLogin = FacebookLogin();
    var facebookLoginResult =
    await facebookLogin.logIn(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
//        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
//        onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        this.setState(() {
          facebooksuccess = true;
        });
        try {
          FacebookAccessToken facebookAccessToken =
              facebookLoginResult.accessToken;
          final AuthCredential credential = FacebookAuthProvider.getCredential(
              accessToken: facebookAccessToken.token);
          final FirebaseUser user = (await auth.signInWithCredential(
              credential))
              .user;
          (await FirebaseAuth.instance.currentUser()).uid;
//        assert(user.email != null);
//        assert(user.displayName != null);
//        assert(user.isAnonymous);
//        assert(user.getIdToken() != null);
          AuthService().checkuserexists(user.uid, user, user.displayName);
        } catch (e) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Error"),
                  content: Text(e.code, style: TextStyle(
                      color: Colors.deepPurple
                  )),
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
//        onLoginStatusChanged(true);
        break;
    }

  }

  bool errordikhao = false;

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      setState(() {
        errordikhao = true;
      });
    } else {
      setState(() {
        errordikhao = false;
      });
    }
  }

  bool errordikhaoP = false;

  String pwdValidator(String value) {
    if (value.length < 8) {
//      return 'Password must be longer than 8 characters';
      setState(() {
        errordikhaoP = true;
      });
    } else {
      setState(() {
        errordikhaoP = false;
      });
    }
  }

  bool errordikhaoN = false;
  bool errordikhaoDN = false;
  bool isLoading = false;
  int initialindexg;

  String validateDisplayName(String value) {
// Indian Mobile number are of 10 digit only

    if (value.length == 0){
      print(value.length);
      setState(() {
        errordikhaoDN = true;
      });
    }



    // return 'Mobile Number must be of 10 digit';

    else {
      setState(() {
        errordikhaoDN = false;
      });
    }
  }

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

  fl.FacebookLogin fbLogin = new fl.FacebookLogin();
  bool isFacebookLoginIn = false;
  String errorMessage = '';
  String successMessage = '';


  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggle2() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  Future<bool> usernameCheck(String displayName) async {
    final result = await Firestore.instance
        .collection('users')
        .where('displayName', isEqualTo: displayName)
        .getDocuments();
    return result.documents.isEmpty;
  }

  Future<String> signup(String email, String password, String firstname,
      String lastname, String phonenumber, String displayname) async {

    String errorMessage;

    this.setState(() {
      isLoading = true;
    });
    try {

       if (_registerFormKey.currentState.validate()) {
        if (pwdInputController.text ==
            confirmPwdInputController.text) {

          final valid = await usernameCheck(displayNameInputController.text);
          if (!valid) {
            showDialog(
                context: context,
                builder: (BuildContext context) {

                  return AlertDialog(
                    title: Text("Error"),
                    content: Text("Display name already exists!", style: TextStyle(
                        color: Colors.deepPurple
                    )),
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
//          this.setState(() {
//            isLoading = true;
//          });

          else {
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
                  "displayName": displayNameInputController.text.toLowerCase(),
                  'followers': 0,
                  'following': 0,
                  'posts': 0,
                  'photoURL': 'https://w7.pngwing.com/pngs/281/431/png-transparent-computer-icons-avatar-user-profile-online-identity-avatar.png',
                  'bio': "Proud Hashtager",
                  'emailVerified': false,
                  'phoneVerified': false,
                })
                    .then((result) =>
                {


                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                        (Route<dynamic> route) => false,
                  ),
                  firstNameInputController.clear(),
                  lastNameInputController.clear(),
                  phoneNumberController.clear(),
                  emailInputController.clear(),
                  displayNameInputController.clear(),
                  pwdInputController.clear(),
                  confirmPwdInputController.clear()
                })
                    .catchError(

                      (err) =>
//                          print(err.code),
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Error"),
                          content: Text(err.code, style: TextStyle(
                              color: Colors.deepPurple
                          )),
                          actions: <Widget>[
                            FlatButton(
                              child: Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            )
                          ],
                        );
                      }),


                ))
                .catchError((err) =>
                showDialog(

                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text(err.code,
                            style: TextStyle(
                                color: Colors.deepPurple
                            )),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Close"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          )
                        ],
                      );
                    }),
            );
          }
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
    }

    catch (error) {
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Your email or password is wrong.";
          break;
        case "ERROR_USER_EXISTS":
          errorMessage = "User with this email already exist.";
          break;
        case "ERROR_USER_DISABLED":
          errorMessage = "User with this email has been disabled.";
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          errorMessage = "Too many requests. Try again later.";
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          errorMessage = "Signing in with Email and Password is not enabled.";
          break;
        default:
          errorMessage =
          "An error occurred, maybe due to unfilled fields, internet or other issue.";
      }

      Future.error(errorMessage);
    }


    if (errorMessage != null) {
      this.setState(() {
        isLoading = false;
      });
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                'sd',
                style: TextStyle(color: Colors.black),
              ),
              title: Text("Error !", style:
              TextStyle(color: Colors.red),),
            );
          });
    }
    this.setState(() {
      isLoading = false;
    });

//    return user.uid;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Background(
        child: (isLoading == false) ? SingleChildScrollView(
          child: Form(
            key: _registerFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
//                Text(
//                  "SIGNUP",
//                  style: TextStyle(fontWeight: FontWeight.bold),
//                ),
//                SizedBox(height: size.height * 0.001),
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
                            fontSize: 12.0, height: 1.5, color: Colors.black),
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
                              left: 0, right: 3, top: 6, bottom: 12),
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
                          hintText: "First name",
                        ),
                        controller: firstNameInputController,
                        //enableInteractiveSelection: false,
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
                            fontSize: 12.0, height: 1.5, color: Colors.black),
                        textInputAction: TextInputAction.next,
                        focusNode: _lastName,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _lastName, _displayName);
                        },
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
                            Icons.person,
                            color: kPrimaryColor,
                          ),
                          fillColor: Colors.deepPurple.shade50,
                          filled: true,
                          hintText: "Last name",
                        ),
                        controller: lastNameInputController,
                        //enableInteractiveSelection: false,
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
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                padding:
                EdgeInsets.only(top: 5, bottom: 2, right: 5, left: 10),
                width: size.width * 0.8,
                decoration: BoxDecoration(
                  color: kPrimaryLightColor,
                  borderRadius: BorderRadius.circular(29),
                  border: Border.all(
                    color: (errordikhaoDN == true)
                        ? Colors.red
                        : kPrimaryLightColor,
                  ),
                ),

                child: TextFormField(
                  style: TextStyle(
                      fontSize: 12.0, height: 1.5, color: Colors.black),
                  textInputAction: TextInputAction.next,
                  focusNode: _displayName,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, _displayName, _phoneNumber);
                  },
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
                      Icons.person,
                      color: kPrimaryColor,
                    ),
                    fillColor: Colors.deepPurple.shade50,
                    filled: true,
                    hintText: "Display name",
                  ),
                  controller: displayNameInputController,
                  validator: validateDisplayName,
                  //enableInteractiveSelection: false,
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
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding:
                      EdgeInsets.only(top: 5, bottom: 2, right: 5, left: 10),
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        color: kPrimaryLightColor,
                        borderRadius: BorderRadius.circular(29),
                        border: Border.all(
                          color: (errordikhaoN == true)
                              ? Colors.red
                              : kPrimaryLightColor,
                        ),
                      ),
                      child: TextFormField(
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
                        style: TextStyle(
                            fontSize: 12.0, height: 1.5, color: Colors.black),
                        textInputAction: TextInputAction.next,
                        focusNode: _phoneNumber,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _phoneNumber, _email);
                        },
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
                              Icons.phone_android,
                              color: kPrimaryColor,
                            ),
                            fillColor: Colors.deepPurple.shade50,
                            filled: true,
                            hintText: "Phone number (optional)"),
                        controller: phoneNumberController,
                        validator: validateMobile,
                        //enableInteractiveSelection: false,
//                        keyboardType: TextInputType.number,
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
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding:
                      EdgeInsets.only(top: 5, bottom: 2, right: 5, left: 10),
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        color: kPrimaryLightColor,
                        borderRadius: BorderRadius.circular(29),
                        border: Border.all(
                          color: (errordikhao == true)
                              ? Colors.red
                              : kPrimaryLightColor,
                        ),
                      ),
                      child: TextFormField(
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.]'))],
                        style: TextStyle(
                            fontSize: 12.0, height: 1.5, color: Colors.black),
                        textInputAction: TextInputAction.next,
                        focusNode: _email,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _email, _pwd);
                        },
                        cursorColor: kPrimaryColor,

                        decoration: InputDecoration(
                            border: InputBorder.none,
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red,
                                )),
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 3, top: 6, bottom: 12),
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
                            hintText: "Email"),
                        controller: emailInputController,
                        validator: emailValidator,
                        //enableInteractiveSelection: false,
//                        keyboardType: TextInputType.emailAddress,
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
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding:
                      EdgeInsets.only(top: 5, bottom: 2, right: 5, left: 10),
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        color: kPrimaryLightColor,
                        borderRadius: BorderRadius.circular(29),
                        border: Border.all(
                          color: (errordikhaoP == true)
                              ? Colors.red
                              : kPrimaryLightColor,
                        ),
                      ),
                      child: TextFormField(
                        style: TextStyle(
                            fontSize: 12.0, height: 1.5, color: Colors.black),
                        textInputAction: TextInputAction.next,
                        focusNode: _pwd,
                        onFieldSubmitted: (term) {
                          _fieldFocusChange(context, _pwd, _confirmPwd);
                        },
                        cursorColor: kPrimaryColor,
                        obscureText: _obscureText,

                        decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _toggle();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: new Icon(
                                  _obscureText
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye,
                                  size: 15.0,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 3, top: 6, bottom: 12),
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
                            hintText: "Create password"),
                        controller: pwdInputController,
                        validator: pwdValidator,
                       // enableInteractiveSelection: false,
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
                            fontSize: 12.0, height: 1.5, color: Colors.black),
                        textInputAction: TextInputAction.done,
                        focusNode: _confirmPwd,
                        onFieldSubmitted: (value) {
                          _confirmPwd.unfocus();
                          RoundedButtonX();
                        },
                        cursorColor: kPrimaryColor,

                        decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _toggle2();
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5.0),
                                child: new Icon(
                                  _obscureText1
                                      ? FontAwesomeIcons.eyeSlash
                                      : FontAwesomeIcons.eye,
                                  size: 15.0,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ),
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 3, top: 6, bottom: 12),
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
                            hintText: "Confirm password"),
                        controller: confirmPwdInputController,
                        obscureText: _obscureText1,
                        //enableInteractiveSelection: false,
//                      validator: emailValidator,
                      ),
                    ),
                  ),
                ),

                RoundedButtonX(
                  text: "SIGNUP",
                  press: () {
                    signup(emailInputController.text, pwdInputController.text,
                        firstNameInputController.text,
                        lastNameInputController.text,
                        phoneNumberController.text,displayNameInputController.text);

//                    if (_registerFormKey.currentState.validate()) {
//                      if (pwdInputController.text ==
//                          confirmPwdInputController.text) {
//                        FirebaseAuth.instance
//                            .createUserWithEmailAndPassword(
//                            email: emailInputController.text,
//                            password: pwdInputController.text)
//                            .then((authResult) =>
//                            Firestore.instance
//                                .collection("users")
//                                .document(authResult.user.uid)
//                                .setData({
//                              "uid": authResult.user.uid,
//                              "fname": firstNameInputController.text,
//                              "surname": lastNameInputController.text,
//                              "phonenumber": phoneNumberController.text,
//                              "email": emailInputController.text,
//                            })
//                                .then((result) =>
//                            {
//                              Navigator.pushAndRemoveUntil(
//                                  context,
//                                  MaterialPageRoute(
//                                      builder: (context) => HomePage()),
//                                      (_) => false),
//                              firstNameInputController.clear(),
//                              lastNameInputController.clear(),
//                              phoneNumberController.clear(),
//                              emailInputController.clear(),
//                              pwdInputController.clear(),
//                              confirmPwdInputController.clear()
//                            })
//                                .catchError(
//                                    (err) => print(Errors.show(err.code))))
//                            .catchError((err) => print(Errors.show(err)));
//                      } else {
//                        showDialog(
//                            context: context,
//                            builder: (BuildContext context) {
//                              return AlertDialog(
//                                title: Text("Error"),
//                                content: Text("The passwords do not match"),
//                                actions: <Widget>[
//                                  FlatButton(
//                                    child: Text("Close"),
//                                    onPressed: () {
//                                      Navigator.of(context).pop();
//                                    },
//                                  )
//                                ],
//                              );
//                            });
//                      }
//                    }
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
//                          signInWithGoogle(success).whenComplete(() {
////                            if (success == true)
//                            Navigator.of(context).push(
//                              MaterialPageRoute(
//                                builder: (context) {
//                                  return HomePage(
////                                    title: "Welcome",
//                                  );
//                                },
//                              ),
//                            );
//                          });
                          onGoogleSignIn(context);
                        }),
                    SocalIcon(
                      iconSrc: "assets/icons/facebook.svg",
                      press: () {
                        facebookLogin(context).then(
                              (user) {
                            print('Logged in successfully.');

                            facebooksuccess ? Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(
                                          title: "huhu",
                                          uid: "h",
                                        )),
                                    (_) => false) : Navigator.pushNamed(
                                context, "/nayasignup");

                            setState(() {
                              isFacebookLoginIn = true;
                              successMessage =
                              'Logged in successfully.\nEmail : ${user
                                  .email}\nYou can now navigate to Home Page.';
                            });
                          },
                        );
                      },
                    ),
                    SocalIcon(
                        iconSrc: "assets/icons/twitter.svg",
                        press: () {
//                        Navigator.pushReplacementNamed(context, "/Twit");
//                          loginWithTwitter(context).then(
//                                (user) {
//                              print('Logged in successfully.');
//                            },
//                          );
                        print("hello");
                        })
                  ],
                )
              ],
            ),
          ),
        ) : CircularProgressIndicator(
          strokeWidth: 5.0,
          semanticsLabel: 'loading...',
          semanticsValue: 'loading...',
          backgroundColor: Colors.deepPurpleAccent,
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.deepPurple),
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

class Errors {
  static String show(String errorCode) {
    switch (errorCode) {
      case 'ERROR_EMAIL_ALREADY_IN_USE':
        return "This e-mail address is already in use, please use a different e-mail address.";

      case 'ERROR_INVALID_EMAIL':
        return "The email address is badly formatted.";

      case 'ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL':
        return "The e-mail address in your Facebook account has been registered in the system before. Please login by trying other methods with this e-mail address.";

      case 'ERROR_WRONG_PASSWORD':
        return "E-mail address or password is incorrect.";

      default:
        return "An error has occurred";
    }
  }
}
