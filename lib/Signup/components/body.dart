import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart' as fl;
import 'package:flutter_svg/svg.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:techstagram/Login/login_screen.dart';
import 'package:techstagram/Signup/components/background.dart';
import 'package:techstagram/Signup/components/or_divider.dart';
import 'package:techstagram/Signup/components/social_icon.dart';
import 'package:techstagram/components/already_have_an_account_acheck.dart';
import 'package:techstagram/components/rounded_button.dart';
import 'package:techstagram/components/text_field_container.dart';
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
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _obscureText = true;
  bool _obscureText1 = true;
  bool isUserSignedIn = false;

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
    checkIfUserIsSignedIn();
  }

  void checkIfUserIsSignedIn() async {
    var userSignedIn = await googleSignIn.isSignedIn();

    setState(() {
      isUserSignedIn = userSignedIn;
    });
  }

  Future<FirebaseUser> _handleSignIn() async {
    FirebaseUser user;
    bool userSignedIn = await googleSignIn.isSignedIn();

    setState(() {
      isUserSignedIn = userSignedIn;
    });

    if (isUserSignedIn) {
      user = await auth.currentUser();
    } else {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      user = (await auth.signInWithCredential(credential)).user;
      userSignedIn = await googleSignIn.isSignedIn();
      setState(() {
        isUserSignedIn = userSignedIn;
      });
    }

    return user;
  }

  void onGoogleSignIn(BuildContext context) async {
    FirebaseUser user = await _handleSignIn();
    var userSignedIn = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              HomePage(
//               user,
//                 _googleSignIn
              )),
    );

    setState(() {
      isUserSignedIn = userSignedIn == null ? true : false;
    });
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
            authToken: session.token, authTokenSecret: session.secret);

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
                  HomePage(
                    title: "huhu",
                    uid: "h",
                  )),
        );
        return currentUser;

        break;
      case TwitterLoginStatus.cancelledByUser:
        break;
      case TwitterLoginStatus.error:
        break;
    }
  }

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
                        cursorHeight: 18.0,


                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 0, right: 3, top: 13, bottom: 8),
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
                        enableInteractiveSelection: false,
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
                          _fieldFocusChange(context, _lastName, _phoneNumber);
                        },
                        cursorColor: kPrimaryColor,

                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 0, right: 3, top: 13, bottom: 8),
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
                        enableInteractiveSelection: false,
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
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                left: 0, right: 3, top: 14, bottom: 8),
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
                        enableInteractiveSelection: false,
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
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                left: 0, right: 3, top: 14, bottom: 8),
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
                        enableInteractiveSelection: false,
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
                      EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                                left: 0, right: 3, top: 14, bottom: 8),
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
                        enableInteractiveSelection: false,
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
                          RoundedButton;
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
                                left: 0, right: 3, top: 14, bottom: 8),
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
                        enableInteractiveSelection: false,
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
                                      builder: (context) => HomePage()),
                                      (_) => false),
                              firstNameInputController.clear(),
                              lastNameInputController.clear(),
                              phoneNumberController.clear(),
                              emailInputController.clear(),
                              pwdInputController.clear(),
                              confirmPwdInputController.clear()
                            })
                                .catchError(
                                    (err) => print(Errors.show(err.code))))
                            .catchError((err) => print(Errors.show(err)));
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

                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HomePage(
                                          title: "huhu",
                                          uid: "h",
                                        )),
                                    (_) => false);

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
                          loginWithTwitter(context).then(
                                (user) {
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
