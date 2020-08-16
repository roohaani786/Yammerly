import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart' as fl;
import 'package:flutter_svg/svg.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:responsive_layout_builder/responsive_layout_builder.dart';
import 'package:techstagram/Login/components/background.dart';
import 'package:techstagram/Signup/components/or_divider.dart';
import 'package:techstagram/Signup/components/social_icon.dart';
import 'package:techstagram/Signup/signup_screen.dart';
import 'package:techstagram/components/already_have_an_account_acheck.dart';
import 'package:techstagram/components/rounded_button.dart';
import 'package:techstagram/ui/HomePage.dart';

import '../../constants.dart';
import '../../forgotpassword.dart';

class Body extends StatefulWidget {
  final IconData icon;

  const Body({
    Key key,
    this.icon = Icons.email,
  }) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool _obscureText = true;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  TextEditingController emailInputController;
  TextEditingController pwdInputController;
  bool isUserSignedIn = false;

  final FocusNode _email = FocusNode();
  final FocusNode _pwd = FocusNode();

  final FirebaseAuth auth = FirebaseAuth.instance;
  fl.FacebookLogin fbLogin = new fl.FacebookLogin();
  bool isFacebookLoginIn = false;
  String errorMessage = '';
  String successMessage = '';

  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  initState() {
    emailInputController = new TextEditingController();
    pwdInputController = new TextEditingController();
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

  bool errordikhaoL = false;

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
//    var hu = value;
    if (!regex.hasMatch(value) && value.length == null) {
      setState(() {
        errordikhaoL = true;
      });
    } else {
      setState(() {
        errordikhaoL = false;
      });
    }
  }

  //twitter Login method

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

  Future<String> signIn(String email, String password) async {
    FirebaseUser user;
    String errorMessage;

    try {
      if (_loginFormKey.currentState.validate()) {
        AuthResult result = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
            email: emailInputController.text,
            password: pwdInputController.text);
        user = result.user;
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(
                      title: "hello",
                      uid: user.uid,
                    )));
      }
    } catch (error) {
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          errorMessage = "Your email address appears to be malformed.";
          break;
        case "ERROR_WRONG_PASSWORD":
          errorMessage = "Your password is wrong.";
          break;
        case "ERROR_USER_NOT_FOUND":
          errorMessage = "User with this email doesn't exist.";
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
          errorMessage = "An undefined Error happened.";
      }

      Future.error(errorMessage);
    }

    if (errorMessage != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                '$errorMessage',
                style: TextStyle(color: Colors.blue),
              ),
              title: Text("Error"),
            );
          });
    }

    return user.uid;
  }

  //facebook login method

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

  //facebook logout method

  Future<bool> facebookLoginout() async {
    await auth.signOut();
    await fbLogin.logOut();
    return true;
  }

  //Password padlock toggle

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loginfail = false;
    Size size = MediaQuery
        .of(context)
        .size;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: ResponsiveLayoutBuilder(
          builder: (context, size) =>
              Background(
                child: SingleChildScrollView(
                  child: Form(
                    key: _loginFormKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SvgPicture.asset(
                          "assets/icons/login.svg",
                          height: 200.0,
                        ),
                        SizedBox(height: 10.0),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 10.0, top: 30.0, bottom: 0.0, left: 10.0),
                          child: Container(
                            height: 50.0,
                            width: 250.0,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//                              width: size.width * 0.8,
                              decoration: BoxDecoration(
                                color: kPrimaryLightColor,
                                borderRadius: BorderRadius.circular(29),
                                border: Border.all(
                                  color: (errordikhaoL == true)
                                      ? Colors.red
                                      : kPrimaryLightColor,
                                ),
                              ),
                              child: TextFormField(
                                style: TextStyle(
                                    fontSize: 12.0,
                                    height: 2.0,
                                    color: Colors.black),
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
                                    hintText: "Email"),
                                controller: emailInputController,
                                validator: emailValidator,
//                        keyboardType: TextInputType.emailAddress,
//                      validator: emailValidator,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                            height: 50.0,
                            width: 250.0,
                            child: new Theme(
                              data: new ThemeData(
                                primaryColor: Colors.deepPurple,
                              ),
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
//                              width: size.width * 0.8,
                                decoration: BoxDecoration(
                                  color: kPrimaryLightColor,
                                  borderRadius: BorderRadius.circular(29),
//                                  border: Border.all(
//                                    color: (errordikhaoL == true)
//                                        ? Colors.red
//                                        : kPrimaryLightColor,
//                                  ),
                                ),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                          left: 0,
                                          right: 3,
                                          top: 10,
                                          bottom: 8),
                                      errorBorder: OutlineInputBorder(
                                          borderSide:
                                          BorderSide(color: Colors.red)),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          _toggle();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0),
                                          child: new Icon(
                                            _obscureText
                                                ? FontAwesomeIcons.eyeSlash
                                                : FontAwesomeIcons.eye,
                                            size: 15.0,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                      icon: Icon(
                                        Icons.lock,
                                        color: kPrimaryColor,
                                      ),
                                      border: InputBorder.none,
                                      fillColor: Colors.deepPurple.shade50,
                                      errorText:
                                      loginfail ? 'password not match' : null,
                                      filled: true,
                                      hintText: "Password"),
                                  controller: pwdInputController,
                                  obscureText: _obscureText,
                                  focusNode: _pwd,
                                  onFieldSubmitted: (value) {
                                    _pwd.unfocus();
                                    RoundedButton;
                                  },
                                  style: TextStyle(
                                      fontSize: 12.0,
                                      height: 2.0,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ),
                        RoundedButton(
                            text: "LOGIN",
                            press: () {
//                              if (_loginFormKey.currentState.validate()) {
//                                FirebaseAuth.instance
//                                    .signInWithEmailAndPassword(
//                                    email: emailInputController.text,
//                                    password: pwdInputController.text)
//                                    .then((authResult) =>
//                                    Firestore.instance
//                                        .collection("users")
//                                        .document(authResult.user.uid)
//                                        .get()
//                                        .then((DocumentSnapshot result) =>
//                                        Navigator.pushReplacement(
//                                            context,
//                                            MaterialPageRoute(
//                                                builder: (context) =>
//                                                    HomePage(
//                                                      title: "hello",
//                                                      uid: authResult.user.uid,
//                                                    ))))
//                                        .catchError((err) => print(err)))
//                                    .catchError((err) => print(err));
//                              }
                              signIn(emailInputController.text,
                                  pwdInputController.text);
                            }),
                        SizedBox(height: 20.0),
                        AlreadyHaveAnAccountCheck(
                          press: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return SignUpScreen();
                                },
                              ),
                            );
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 0.0, top: 10.0),
                          child: Container(
                            width: double.infinity,
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ForgotScreen()));
                              },
                              child: Text(
                                "Forgot password ?",
                                style: TextStyle(color: Color(0xFF6F35A5)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        OrDivider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SocalIcon(
                                iconSrc: "assets/icons/google-icon.svg",
                                press: () {
//                                  signInWithGoogle(success).whenComplete(() {
//                           if (success == true)
//                                    Navigator.of(context).push(
//                                      MaterialPageRoute(
//                                        builder: (context) {
//                                          return HomePage(
////                                    title: "Welcome",
//                                          );
//                                        },
//                                      ),
//                                    );
//                           else
//                             Navigator.pop(
//                               context
//                             );
//
//                                  });

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
                                loginWithTwitter(context).then((user) {
                                  print('Logged in successfully.');
                                });
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
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